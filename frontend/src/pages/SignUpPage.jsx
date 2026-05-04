import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import logoImage from "../assets/john-logo.png";
import { registerUser } from "../services/authService";
import "../styles/authPages.css";

function EyeIcon({ hidden }) {
  return hidden ? (
    <svg className="eye-icon" viewBox="0 0 24 24" fill="none">
      <path d="M4 4L20 20" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path d="M9.8 9.8A3 3 0 0 0 14.2 14.2" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path d="M10.7 5.2C11.1 5.1 11.6 5.1 12 5.1C17.1 5.1 20.7 9.1 22 12C21.6 13 20.8 14.2 19.7 15.3" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M6.3 6.7C4.3 8 2.9 10 2 12C3.3 14.9 6.9 18.9 12 18.9C13.4 18.9 14.7 18.6 15.9 18" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  ) : (
    <svg className="eye-icon" viewBox="0 0 24 24" fill="none">
      <path d="M2 12C3.3 9.1 6.9 5.1 12 5.1C17.1 5.1 20.7 9.1 22 12C20.7 14.9 17.1 18.9 12 18.9C6.9 18.9 3.3 14.9 2 12Z" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="12" cy="12" r="3.1" stroke="currentColor" strokeWidth="1.9" />
      <circle cx="12" cy="12" r="1.15" fill="currentColor" />
    </svg>
  );
}

function SignUpPage() {
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    username: "",
    email: "",
    password: "",
    accountType: "candidate",
  });

  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  function handleChange(e) {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  }

  function handleAccountTypeChange(accountType) {
    setFormData({
      ...formData,
      accountType,
    });
  }

  const passwordChecks = {
    length: formData.password.length >= 8,
    lowercase: /[a-z]/.test(formData.password),
    uppercase: /[A-Z]/.test(formData.password),
    symbol: /[\W_]/.test(formData.password),
  };

  const passwordScore = Object.values(passwordChecks).filter(Boolean).length;

  const passwordStrength =
    passwordScore === 0
      ? { label: "", className: "", width: "0%" }
      : passwordScore === 1
      ? { label: "Weak", className: "weak", width: "25%" }
      : passwordScore === 2
      ? { label: "Fair", className: "fair", width: "50%" }
      : passwordScore === 3
      ? { label: "Good", className: "good", width: "75%" }
      : { label: "Strong", className: "strong", width: "100%" };

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setSuccess("");

    if (!formData.username || !formData.email || !formData.password || !formData.accountType) {
      setError("Please fill in all fields.");
      return;
    }

    try {
      setLoading(true);
      await registerUser(formData);

      setSuccess(
        "Account created successfully. Please check your email and verify your account before signing in."
      );

      setTimeout(() => {
        navigate("/signin");
      }, 2000);
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
          <span className="auth-badge">Join Hospitality</span>
          <h1 className="auth-title">Sign Up</h1>
          <p className="auth-subtitle">
            Create your account and begin your journey in a more inclusive
            hospitality experience.
          </p>

          <form onSubmit={handleSubmit} className="auth-form">
            <div className="auth-field">
              <label>I am a...</label>

              <div className="account-type-options">
                <button
                  type="button"
                  className={
                    formData.accountType === "candidate"
                      ? "account-type-card selected"
                      : "account-type-card"
                  }
                  onClick={() => handleAccountTypeChange("candidate")}
                >
                  <span className="account-type-icon">🧑‍💼</span>
                  <strong>Candidate</strong>
                  <small>Looking for opportunities</small>
                </button>

                <button
                  type="button"
                  className={
                    formData.accountType === "employer"
                      ? "account-type-card selected"
                      : "account-type-card"
                  }
                  onClick={() => handleAccountTypeChange("employer")}
                >
                  <span className="account-type-icon">🏢</span>
                  <strong>Employer</strong>
                  <small>Hiring for my business</small>
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
                  <EyeIcon hidden={showPassword} />
                </button>
              </div>

              <div className="password-strength-row">
                <div className="password-strength-track">
                  <div
                    className={`password-strength-fill ${passwordStrength.className}`}
                    style={{ width: passwordStrength.width }}
                  ></div>
                </div>

                <span className={`password-strength-label ${passwordStrength.className}`}>
                  {passwordStrength.label}
                </span>
              </div>

              <div className="password-hints">
                <p className="password-hints-title">Password must contain:</p>
                <ul className="password-rules">
                  <li className={passwordChecks.length ? "rule valid" : "rule"}>
                    At least 8 characters
                  </li>
                  <li className={passwordChecks.lowercase ? "rule valid" : "rule"}>
                    At least one lowercase letter
                  </li>
                  <li className={passwordChecks.uppercase ? "rule valid" : "rule"}>
                    At least one uppercase letter
                  </li>
                  <li className={passwordChecks.symbol ? "rule valid" : "rule"}>
                    At least one symbol
                  </li>
                </ul>
              </div>
            </div>

            {error && <p className="auth-error">{error}</p>}
            {success && <p className="auth-success">{success}</p>}

            <button type="submit" className="primary-btn full-width" disabled={loading}>
              {loading ? "Creating account..." : "Sign Up"}
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