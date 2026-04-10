import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { loginUser, saveToken, getRoleFromToken } from "../services/authService";

function SignInPage() {
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    email: "",
    password: "",
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  function handleChange(e) {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");

    if (!formData.email || !formData.password) {
      setError("Please enter your email and password.");
      return;
    }

    try {
      setLoading(true);

      const data = await loginUser(formData);
      const token = data.token;

      if (!token) {
        throw new Error("No token returned from backend.");
      }

      saveToken(token);

      const role = getRoleFromToken(token);

      if (role === "ROLE_ADMIN") {
        navigate("/admin");
      } else if (role === "ROLE_EMPLOYER") {
        navigate("/employer");
      } else {
        navigate("/candidate");
      }
    } catch (err) {
      setError(err.message || "Invalid credentials or email not verified.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <h1 style={styles.title}>Sign In</h1>
        <p style={styles.subtitle}>Welcome back</p>

        <form onSubmit={handleSubmit} style={styles.form}>
          <input
            type="email"
            name="email"
            placeholder="Email address"
            value={formData.email}
            onChange={handleChange}
            style={styles.input}
          />

          <input
            type="password"
            name="password"
            placeholder="Password"
            value={formData.password}
            onChange={handleChange}
            style={styles.input}
          />

          {error && <p style={styles.error}>{error}</p>}

          <button type="submit" style={styles.button} disabled={loading}>
            {loading ? "Signing in..." : "Sign In"}
          </button>
        </form>
      </div>
    </div>
  );
}

const styles = {
  page: {
    minHeight: "100vh",
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    background: "linear-gradient(135deg, #dff4ff, #eef7ff)",
    padding: "20px",
  },
  card: {
    backgroundColor: "white",
    padding: "40px",
    borderRadius: "24px",
    boxShadow: "0 10px 30px rgba(0,0,0,0.12)",
    width: "100%",
    maxWidth: "420px",
  },
  title: {
    margin: 0,
    marginBottom: "10px",
    textAlign: "center",
  },
  subtitle: {
    textAlign: "center",
    color: "#666",
    marginBottom: "25px",
  },
  form: {
    display: "flex",
    flexDirection: "column",
    gap: "14px",
  },
  input: {
    padding: "14px",
    borderRadius: "14px",
    border: "1px solid #ddd",
    fontSize: "16px",
  },
  button: {
    padding: "14px",
    border: "none",
    borderRadius: "18px 8px 18px 8px",
    background: "linear-gradient(135deg, #4facfe, #00c6ff)",
    color: "white",
    fontSize: "16px",
    fontWeight: "bold",
    cursor: "pointer",
  },
  error: {
    color: "#d11a2a",
    margin: 0,
    fontSize: "14px",
  },
};

export default SignInPage;