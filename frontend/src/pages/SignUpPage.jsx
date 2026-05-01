import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import logoImage from "../assets/john-logo.png";
import { registerUser } from "../services/authService";
import "../styles/authPages.css";

function SignUpPage() {
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    username: "",
    email: "",
    password: "",
    role: "",
  });

  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  function handleChange(e) {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  }

  function handleRoleSelect(role) {
    setFormData({ ...formData, role });
  }

  const passwordChecks = {
    length: formData.password.length >= 8,
    lowercase: /[a-z]/.test(formData.password),
    uppercase: /[A-Z]/.test(formData.password),
    symbol: /[\W_]/.test(formData.password),
  };

  const strengthScore = Object.values(passwordChecks).filter(Boolean).length;
  const strengthLabel = ["", "Weak", "Fair", "Good", "Strong"][strengthScore];
  const strengthColor = ["", "#e53935", "#fb8c00", "#43a047", "#1f4fbf"][strengthScore];

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setSuccess("");

    if (!formData.username || !formData.email || !formData.password) {
      setError("Please fill in all fields.");
      return;
    }

    if (!formData.role) {
      setError("Please select your role.");
      return;
    }

    try {
      setLoading(true);
      await registerUser({
        username: formData.username,
        email: formData.email,
        password: formData.password,
        role: formData.role,
      });

      setSuccess("Account created! Please check your email to verify your account.");
      setTimeout(() => navigate("/signin"), 2500);
    } catch (err) {
      setError(err.message || "Something went wrong during sign up.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-page">
      <div className="auth-shell">
        <div className="auth-left">
          <span className="auth-badge">JoIn Hospitality</span>
          <h1 className="auth-title">Sign Up</h1>
          <p className="auth-subtitle">
            Create your account and begin your journey in a more inclusive hospitality experience.
          </p>

          <form onSubmit={handleSubmit} className="auth-form">
            <div className="auth-field">
              <label>I am a...</label>
              <div className="role-selector">
                <button
                  type="button"
                  className={`role-btn ${formData.role === "ROLE_CANDIDATE" ? "role-btn--active" : ""}`}
                  onClick={() => handleRoleSelect("ROLE_CANDIDATE")}
                >
                  <span className="role-icon">🧑‍💼</span>
                  <span className="role-label">Candidate</span>
                  <span className="role-desc">Looking for opportunities</span>
                </button>
                <button
                  type="button"
                  className={`role-btn ${formData.role === "ROLE_EMPLOYER" ? "role-btn--active" : ""}`}
                  onClick={() => handleRoleSelect("ROLE_EMPLOYER")}
                >
                  <span className="role-icon">🏨</span>
                  <span className="role-label">Employer</span>
                  <span className="role-desc">Hiring for my business</span>
                </button>
              </div>
            </div>

            <div className="auth-field">
              <label htmlFor="username">Username</label>
              <input
                id="username"
                type="text"
                name="username"
                placeholder="Choose a username"
                value={formData.username}
                onChange={handleChange}
                className="auth-input"
              />
            </div>

            <div className="auth-field">
              <label htmlFor="email">Email</label>
              <input
                id="email"
                type="email"
                name="email"
                placeholder="Enter your email"
                value={formData.email}
                onChange={handleChange}
                className="auth-input"
              />
            </div>

            <div className="auth-field">
              <label htmlFor="password">Password</label>
              <div className="password-input-wrapper">
                <input
                  id="password"
                  type={showPassword ? "text" : "password"}
                  name="password"
                  placeholder="Create a password"
                  value={formData.password}
                  onChange={handleChange}
                  className="auth-input password-input"
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowPassword(!showPassword)}
                  aria-label={showPassword ? "Hide password" : "Show password"}
                >
                  {showPassword ? "🙈" : "👁️"}
                </button>
              </div>

              {formData.password.length > 0 && (
                <div className="strength-bar-wrapper">
                  <div className="strength-bar-track">
                    <div
                      className="strength-bar-fill"
                      style={{
                        width: `${(strengthScore / 4) * 100}%`,
                        background: strengthColor,
                      }}
                    />
                  </div>
                  <span className="strength-label" style={{ color: strengthColor }}>
                    {strengthLabel}
                  </span>
                </div>
              )}

              <div className="password-hints">
                <p className="password-hints-title">Password must contain:</p>
                <ul className="password-rules">
                  {[
                    { key: "length", label: "At least 8 characters" },
                    { key: "lowercase", label: "At least one lowercase letter" },
                    { key: "uppercase", label: "At least one uppercase letter" },
                    { key: "symbol", label: "At least one symbol" },
                  ].map(({ key, label }) => (
                    <li key={key} className={passwordChecks[key] ? "rule valid" : "rule"}>
                      <span className="rule-check">{passwordChecks[key] ? "✅" : "○"}</span>
                      {label}
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            {error && <p className="auth-error">{error}</p>}
            {success && <p className="auth-success">{success}</p>}

            <button type="submit" className="primary-btn full-width" disabled={loading}>
              {loading ? (
                <span className="btn-loading">
                  <span className="spinner" />
                  Creating account...
                </span>
              ) : "Sign Up"}
            </button>
          </form>

          <p className="auth-footer">
            Already have an account? <Link to="/signin">Sign in</Link>
          </p>
        </div>

        <div className="auth-right">
          <div className="logo-panel">
            <div className="logo-glow"></div>
            <img src={logoImage} alt="John Hospitality logo" className="logo-image" />
          </div>
        </div>
      </div>
    </div>
  );
}

export default SignUpPage;
