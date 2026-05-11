import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
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
  const [touched, setTouched] = useState({});
  const [loading, setLoading] = useState(false);
  const [serverError, setServerError] = useState("");
  const [success, setSuccess] = useState("");

  function handleChange(e) {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setServerError("");
  }

  function handleBlur(e) {
    setTouched({ ...touched, [e.target.name]: true });
  }

  function handleAccountTypeChange(accountType) {
    setFormData({ ...formData, accountType });
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

  const errors = {
    username:
      touched.username && !formData.username.trim()
        ? "Please enter a username."
        : "",
    email:
      touched.email && !formData.email.trim()
        ? "Please enter your email address."
        : touched.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)
        ? "Please enter a valid email address, like name@example.com."
        : "",
    password:
      touched.password && !formData.password
        ? "Please create a password."
        : touched.password && passwordScore < 4
        ? "Your password must meet all requirements below."
        : "",
  };

  function validateForm() {
    setTouched({ username: true, email: true, password: true });

    if (!formData.username.trim()) return false;
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) return false;
    if (passwordScore < 4) return false;

    return true;
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setServerError("");
    setSuccess("");

    if (!validateForm()) return;

    try {
      setLoading(true);
      await registerUser(formData);

      setSuccess(
        "Account created successfully. Please check your email to verify your account before signing in."
      );

      setTimeout(() => {
        navigate("/signin");
      }, 2000);
    } catch (err) {
      setServerError(err.message || "We could not create your account. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-page signup-page">
      <div className="signup-card">
        <div className="signup-header">
          <span className="auth-badge signup-badge">Join Hospitality</span>

          <h1 className="signup-title">Sign Up</h1>

          <div className="signup-header-spacer"></div>
        </div>

        <p className="signup-subtitle">
          Start your journey in a more inclusive hospitality experience.
        </p>

        <form onSubmit={handleSubmit} className="auth-form signup-form" noValidate>
          <div className="auth-field">
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
              onBlur={handleBlur}
              className={errors.username ? "auth-input input-error" : "auth-input"}
            />
            {errors.username && <p className="field-error">{errors.username}</p>}
          </div>

          <div className="auth-field">
            <label htmlFor="email">Email</label>
            <input
              id="email"
              type="email"
              name="email"
              placeholder="name@example.com"
              value={formData.email}
              onChange={handleChange}
              onBlur={handleBlur}
              className={errors.email ? "auth-input input-error" : "auth-input"}
            />
            {errors.email && <p className="field-error">{errors.email}</p>}
          </div>

          <div className="auth-field">
            <label htmlFor="password">Password</label>

            <div className="password-input-wrapper">
              <input
                id="password"
                type={showPassword ? "text" : "password"}
                name="password"
                placeholder="Create a secure password"
                value={formData.password}
                onChange={handleChange}
                onBlur={handleBlur}
                className={
                  errors.password
                    ? "auth-input password-input input-error"
                    : "auth-input password-input"
                }
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

            {errors.password && <p className="field-error">{errors.password}</p>}

            <div className="password-hints compact">
              <p className="password-hints-title">Password must contain:</p>

              <ul className="password-rules">
                <li className={passwordChecks.length ? "rule valid" : "rule"}>
                  8+ characters
                </li>
                <li className={passwordChecks.lowercase ? "rule valid" : "rule"}>
                  Lowercase letter
                </li>
                <li className={passwordChecks.uppercase ? "rule valid" : "rule"}>
                  Uppercase letter
                </li>
                <li className={passwordChecks.symbol ? "rule valid" : "rule"}>
                  Symbol
                </li>
              </ul>
            </div>
          </div>

          {serverError && <p className="auth-error">{serverError}</p>}
          {success && <p className="auth-success">{success}</p>}

          <button type="submit" className="primary-btn full-width" disabled={loading}>
            {loading ? "Creating account..." : "Create Account"}
          </button>
        </form>

        <p className="auth-footer">
          Already have an account? <Link to="/signin">Sign in</Link>
        </p>
      </div>
    </div>
  );
}

export default SignUpPage;