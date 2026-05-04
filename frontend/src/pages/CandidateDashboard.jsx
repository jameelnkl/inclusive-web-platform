import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { getToken, logout } from "../services/authService";

const API_BASE_URL = "https://fyp-backend-cbaa.onrender.com/api";

const disabilities = [
  { name: "Ankle", image: "/Disabilities/Ankle.png" },
  { name: "Arm", image: "/Disabilities/Arm.png" },
  { name: "Both Ankles", image: "/Disabilities/BothAnkles.png" },
  { name: "Both Arms", image: "/Disabilities/BothArms.png" },
  { name: "Both Forearms", image: "/Disabilities/BothForearms.png" },
  { name: "Both Hands", image: "/Disabilities/BothHands.png" },
  { name: "Both Knees", image: "/Disabilities/BothKnees.png" },
  { name: "Both Legs", image: "/Disabilities/BothLegs.png" },
  { name: "CVA", image: "/Disabilities/CVA.png" },
  { name: "Forearm", image: "/Disabilities/Forearm.png" },
  { name: "Knee", image: "/Disabilities/Knee.png" },
  { name: "Leg", image: "/Disabilities/Leg.png" },
  {
    name: "Pelvis Legs Wheelchair",
    image: "/Disabilities/PelvisLegsWheelchair.png",
  },
  { name: "Waist Wheelchair", image: "/Disabilities/WaistWheelchair.png" },
  { name: "Wheelchair", image: "/Disabilities/Wheelchair.png" },
];

function CandidateDashboard() {
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState("PROFILE");
  const [selectedDisabilities, setSelectedDisabilities] = useState([]);
  const [remainingAbilities, setRemainingAbilities] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [loadingProfile, setLoadingProfile] = useState(true);
  const [savingProfile, setSavingProfile] = useState(false);

  useEffect(() => {
    fetchCandidateProfile();
  }, []);

  const filteredDisabilities = disabilities.filter((disability) =>
    disability.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  async function fetchCandidateProfile() {
    try {
      setLoadingProfile(true);
      setErrorMessage("");

      const token = getToken();

      if (!token) {
        navigate("/signin");
        return;
      }

      const response = await fetch(`${API_BASE_URL}/candidate/profile`, {
        method: "GET",
        headers: {
          "X-Auth-Token": token,
        },
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        throw new Error(data.message || "Failed to load profile.");
      }

      setSelectedDisabilities(data.profile?.selectedDisabilities || []);
      setRemainingAbilities(data.profile?.remainingAbilities || []);
    } catch (err) {
      setErrorMessage(err.message || "Something went wrong while loading profile.");
    } finally {
      setLoadingProfile(false);
    }
  }

  function handleDisabilityChange(disabilityName) {
    setSuccessMessage("");
    setErrorMessage("");

    setSelectedDisabilities((previousDisabilities) => {
      if (previousDisabilities.includes(disabilityName)) {
        return previousDisabilities.filter((item) => item !== disabilityName);
      }

      return [...previousDisabilities, disabilityName];
    });
  }

  async function handleSaveProfile() {
    try {
      setSavingProfile(true);
      setSuccessMessage("");
      setErrorMessage("");

      const token = getToken();

      if (!token) {
        navigate("/signin");
        return;
      }

      const response = await fetch(`${API_BASE_URL}/candidate/profile`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-Auth-Token": token,
        },
        body: JSON.stringify({
          selectedDisabilities,
        }),
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        throw new Error(data.message || "Failed to save profile.");
      }

      setSelectedDisabilities(data.profile?.selectedDisabilities || []);
      setRemainingAbilities(data.profile?.remainingAbilities || []);
      setSuccessMessage(data.message || "Profile saved successfully.");
    } catch (err) {
      setErrorMessage(err.message || "Something went wrong while saving profile.");
    } finally {
      setSavingProfile(false);
    }
  }

  function handleLogout() {
    logout();
    navigate("/signin");
  }

  return (
    <div style={styles.page}>
      <header style={styles.header}>
        <div>
          <h1 style={styles.logo}>Candidate Dashboard</h1>
        </div>

        <button onClick={handleLogout} style={styles.logoutButton}>
          Logout
        </button>
      </header>

      <nav style={styles.tabs}>
        <button
          onClick={() => setActiveTab("PROFILE")}
          style={{
            ...styles.tabButton,
            ...(activeTab === "PROFILE" ? styles.activeTab : {}),
          }}
        >
          My Profile
        </button>

        <button
          onClick={() => setActiveTab("JOBS")}
          style={{
            ...styles.tabButton,
            ...(activeTab === "JOBS" ? styles.activeTab : {}),
          }}
        >
          Jobs
        </button>

        <button
          onClick={() => setActiveTab("APPLICATIONS")}
          style={{
            ...styles.tabButton,
            ...(activeTab === "APPLICATIONS" ? styles.activeTab : {}),
          }}
        >
          My Applications
        </button>
      </nav>

      <main style={styles.main}>
        {activeTab === "PROFILE" && (
          <section style={styles.profileGrid}>
            <div style={styles.card}>
              <h2 style={styles.sectionTitle}>My Profile</h2>

              <p style={styles.text}>
                Select the disability or disabilities that apply to you.
              </p>

              {loadingProfile && <p style={styles.infoText}>Loading profile...</p>}
              {errorMessage && <p style={styles.errorText}>{errorMessage}</p>}

              <input
                type="text"
                placeholder="Search disability..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                style={styles.searchInput}
              />

              <div style={styles.disabilityGrid}>
                {filteredDisabilities.map((disability) => {
                  const isSelected = selectedDisabilities.includes(disability.name);

                  return (
                    <button
                      key={disability.name}
                      onClick={() => handleDisabilityChange(disability.name)}
                      style={{
                        ...styles.disabilityCard,
                        ...(isSelected ? styles.selectedDisabilityCard : {}),
                      }}
                    >
                      {isSelected && (
                        <span style={styles.selectedBadge}>Selected</span>
                      )}

                      <div style={styles.imageWrapper}>
                        <img
                          src={disability.image}
                          alt={disability.name}
                          style={styles.disabilityImage}
                        />
                      </div>

                      <span style={styles.disabilityName}>{disability.name}</span>
                    </button>
                  );
                })}
              </div>

              <button
                onClick={handleSaveProfile}
                style={styles.saveButton}
                disabled={savingProfile}
              >
                {savingProfile ? "Saving..." : "Save Profile"}
              </button>

              {successMessage && (
                <p style={styles.successText}>{successMessage}</p>
              )}
            </div>

            <div style={styles.card}>
              <h2 style={styles.sectionTitle}>Remaining Abilities</h2>

              <div style={styles.emptyBox}>
                {remainingAbilities.length > 0
                  ? remainingAbilities.join(", ")
                  : "Remaining abilities will appear here after analysis."}
              </div>

              {selectedDisabilities.length > 0 && (
                <div style={styles.selectedBox}>
                  <h3 style={styles.smallTitle}>Selected Disabilities</h3>

                  {selectedDisabilities.map((item) => (
                    <span key={item} style={styles.selectedChip}>
                      {item}
                    </span>
                  ))}
                </div>
              )}
            </div>
          </section>
        )}

        {activeTab === "JOBS" && (
          <section style={styles.card}>
            <h2 style={styles.sectionTitle}>Available Jobs</h2>
            <p style={styles.text}>Chocolaterie job will appear here.</p>
          </section>
        )}

        {activeTab === "APPLICATIONS" && (
          <section style={styles.card}>
            <h2 style={styles.sectionTitle}>My Applications</h2>
            <p style={styles.text}>Applications will appear here later.</p>
          </section>
        )}
      </main>
    </div>
  );
}

const styles = {
  page: {
    minHeight: "100vh",
    background: "#f5f7fb",
    color: "#111827",
    fontFamily: "Inter, system-ui, Arial, sans-serif",
  },

  header: {
    background: "white",
    padding: "28px 48px 14px",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    boxShadow: "0 4px 18px rgba(15, 23, 42, 0.06)",
  },

  logo: {
    margin: 0,
    fontSize: "30px",
    fontWeight: "800",
    color: "#111827",
    letterSpacing: "-0.3px",
    lineHeight: "1.15",
  },

  logoutButton: {
    border: "none",
    background: "#ef4444",
    color: "white",
    padding: "10px 18px",
    borderRadius: "12px",
    cursor: "pointer",
    fontWeight: "700",
  },

  tabs: {
    background: "white",
    padding: "0 48px 10px",
    display: "flex",
    gap: "12px",
    borderBottom: "1px solid #e5e7eb",
  },

  tabButton: {
    background: "#f8fafc",
    border: "1px solid #e5e7eb",
    padding: "11px 18px",
    cursor: "pointer",
    fontSize: "15px",
    fontWeight: "800",
    color: "#64748b",
    borderRadius: "999px",
    transition: "all 0.2s ease",
  },

  activeTab: {
    color: "#1d4ed8",
    background: "#eff6ff",
    border: "1px solid #bfdbfe",
    boxShadow: "0 8px 18px rgba(29, 78, 216, 0.16)",
  },

  main: {
    padding: "36px 48px 36px 20px",
  },

  profileGrid: {
    display: "grid",
    gridTemplateColumns: "1.4fr 0.6fr",
    gap: "24px",
  },

  card: {
    background: "white",
    borderRadius: "20px",
    padding: "28px",
    boxShadow: "0 10px 25px rgba(15, 23, 42, 0.08)",
  },

  sectionTitle: {
    margin: "0 0 12px",
    fontSize: "24px",
    fontWeight: "800",
    color: "#111827",
  },

  text: {
    color: "#4b5563",
    fontSize: "15px",
    lineHeight: "1.6",
  },

  searchInput: {
    width: "100%",
    marginTop: "18px",
    marginBottom: "20px",
    padding: "13px 15px",
    borderRadius: "14px",
    border: "1px solid #d1d5db",
    fontSize: "15px",
    outline: "none",
    boxSizing: "border-box",
  },

  disabilityGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(3, 1fr)",
    gap: "18px",
  },

  disabilityCard: {
    position: "relative",
    border: "1px solid #e5e7eb",
    background: "#f9fafb",
    borderRadius: "20px",
    padding: "12px",
    cursor: "pointer",
    minHeight: "255px",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "space-between",
    transition: "all 0.2s ease",
  },

  selectedDisabilityCard: {
    border: "2px solid #1d4ed8",
    background: "#eff6ff",
    boxShadow: "0 10px 24px rgba(29, 78, 216, 0.18)",
  },

  selectedBadge: {
    position: "absolute",
    top: "12px",
    right: "12px",
    background: "#1d4ed8",
    color: "white",
    fontSize: "11px",
    fontWeight: "800",
    padding: "5px 9px",
    borderRadius: "999px",
  },

  imageWrapper: {
    width: "100%",
    height: "200px",
    background: "white",
    borderRadius: "16px",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden",
  },

  disabilityImage: {
    width: "100%",
    height: "100%",
    objectFit: "contain",
  },

  disabilityName: {
    marginTop: "10px",
    fontSize: "16px",
    fontWeight: "800",
    color: "#1f2937",
    textAlign: "center",
  },

  saveButton: {
    marginTop: "24px",
    border: "none",
    background: "#1d4ed8",
    color: "white",
    padding: "12px 18px",
    borderRadius: "12px",
    cursor: "pointer",
    fontWeight: "700",
  },

  successText: {
    marginTop: "14px",
    color: "#166534",
    fontWeight: "700",
  },

  errorText: {
    marginTop: "12px",
    color: "#dc2626",
    fontWeight: "700",
  },

  infoText: {
    color: "#6b7280",
    fontWeight: "600",
  },

  emptyBox: {
    marginTop: "18px",
    minHeight: "180px",
    border: "2px dashed #d1d5db",
    borderRadius: "16px",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    textAlign: "center",
    color: "#6b7280",
    padding: "20px",
  },

  selectedBox: {
    marginTop: "22px",
  },

  smallTitle: {
    fontSize: "16px",
    marginBottom: "12px",
    color: "#111827",
  },

  selectedChip: {
    display: "inline-block",
    background: "#eef2ff",
    color: "#3730a3",
    padding: "7px 10px",
    borderRadius: "999px",
    fontSize: "13px",
    fontWeight: "700",
    margin: "0 8px 8px 0",
  },
};

export default CandidateDashboard;