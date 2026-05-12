#  AI Job Matching Microservice
#  Run with: python app.py
#  Listens on: http://localhost:5001

from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
import os

app = Flask(__name__)
CORS(app)

# Load models once at startup
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

score_model        = joblib.load(os.path.join(BASE_DIR, "model_compatibility_score.pkl"))
ability_models     = joblib.load(os.path.join(BASE_DIR, "model_remaining_abilities.pkl"))
CONSTANT_ABILITIES = joblib.load(os.path.join(BASE_DIR, "model_constant_abilities.pkl"))

# Map frontend disability names → model column names
DISABILITY_MAP = {
    "CVA"                   : "has_H_1_AVC",
    "Forearm"               : "has_H_1_Avant_bras",
    "Arm"                   : "has_H_1_Bras",
    "Ankle"                 : "has_H_1_Cheville",
    "Leg"                   : "has_H_1_Cheville_jambe",
    "Knee"                  : "has_H_1_Pieds",
    "Hand"                  : "has_H_1_main",
    "Both Forearms"         : "has_H_2_Avant_bras",
    "Both Arms"             : "has_H_2_Bras",
    "Both Ankles"           : "has_H_2_Chevilles",
    "Both Legs"             : "has_H_2_Chevilles_Jambes",
    "Both Hands"            : "has_H_2_Mains",
    "Wheelchair"            : "has_H_Fauteuil",
    "Waist Wheelchair"      : "has_H_Fauteuil_sangl",
    "Pelvis Legs Wheelchair": "has_H_Fauteuil_ventre_m",
}

DISABILITY_COLUMNS = [
    "number_of_disabilities",
    "has_H_1_AVC", "has_H_1_Avant_bras", "has_H_1_Bras",
    "has_H_1_Cheville", "has_H_1_Cheville_jambe", "has_H_1_Pieds", "has_H_1_main",
    "has_H_2_Avant_bras", "has_H_2_Bras", "has_H_2_Chevilles", "has_H_2_Chevilles_Jambes",
    "has_H_2_Mains", "has_H_Fauteuil", "has_H_Fauteuil_sangl", "has_H_Fauteuil_ventre_m",
    "job_Glacerie", "job_Chocolaterie", "job_Boulangerie_Patisserie",
]

JOBS      = ["job_Glacerie", "job_Chocolaterie", "job_Boulangerie_Patisserie"]
JOB_NAMES = ["Glacerie", "Chocolaterie", "Boulangerie Patisserie"]


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})


@app.route("/predict", methods=["POST"])
def predict():
    """
    Expects JSON body:
    {
        "disabilities": ["Wheelchair", "Hand"]
    }

    Returns:
    {
        "results": [
            {
                "job": "Chocolaterie",
                "compatibility": 76.1,
                "remainingAbilities": ["read instructions", "measure or weigh", ...]
            },
            ...
        ],
        "bestMatch": {
            "job": "Chocolaterie",
            "compatibility": 76.1
        }
    }
    """
    try:
        body = request.get_json()

        if not body or "disabilities" not in body:
            return jsonify({"error": "Missing 'disabilities' in request body"}), 400

        selected = body["disabilities"]

        if not isinstance(selected, list):
            return jsonify({"error": "'disabilities' must be an array"}), 400

        # Map frontend names to model column names
        mapped = {}
        for name in selected:
            col = DISABILITY_MAP.get(name)
            if col:
                mapped[col] = 1

        results = []

        for job_col, job_name in zip(JOBS, JOB_NAMES):
            row = {col: 0 for col in DISABILITY_COLUMNS}
            row["number_of_disabilities"] = len(mapped)
            for col in mapped:
                row[col] = 1
            row[job_col] = 1

            inp = pd.DataFrame([row])

            score = round(float(score_model.predict(inp)[0]), 1)

            # Remaining abilities
            remaining = []
            for ability, clf in ability_models.items():
                if int(clf.predict(inp)[0]) == 1:
                    label = (
                        ability
                        .replace("target_", "")
                        .replace("can_", "")
                        .replace("_", " ")
                    )
                    remaining.append(label)

            # Add constant abilities
            for ca in CONSTANT_ABILITIES:
                label = (
                    ca
                    .replace("target_", "")
                    .replace("can_", "")
                    .replace("_", " ")
                )
                if label not in remaining:
                    remaining.append(label)

            results.append({
                "job"              : job_name,
                "compatibility"    : score,
                "remainingAbilities": remaining,
            })

        results.sort(key=lambda x: x["compatibility"], reverse=True)

        return jsonify({
            "results"  : results,
            "bestMatch": {
                "job"          : results[0]["job"],
                "compatibility": results[0]["compatibility"],
            },
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    print("AI Job Matching Service running on http://localhost:5001")
    app.run(host="0.0.0.0", port=5001, debug=False)
