import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import logoImage from "../assets/john-logo.png";
import {
  loginUser,
  saveToken,
  getRoleFromToken,
} from "../services/authService";
import "../styles/authPages.css";

function SignInPage() {
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    email: "",
    password: "",
  });

  const [showPassword, setShowPassword] = useState(false);
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
    <div className="auth-page">
      <div className="auth-shell">
        <div className="auth-left">
          <span className="auth-badge">Welcome Back</span>
          <h1 className="auth-title">Sign In</h1>
          <p className="auth-subtitle">
            Access your account and continue your journey with John Hospitality.
          </p>

          <form onSubmit={handleSubmit} className="auth-form">
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
                  placeholder="Enter your password"
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

              <div className="forgot-password-link">
                <Link to="/forgot-password">Forgot password?</Link>
              </div>
            </div>

            {error && <p className="auth-error">{error}</p>}

            <button type="submit" className="primary-btn full-width" disabled={loading}>
              {loading ? "Signing in..." : "Sign In"}
            </button>
          </form>

          <p className="auth-footer">
            Don&apos;t have an account? <Link to="/signup">Create one</Link>
          </p>
        </div>

        <div className="auth-right">
          <div className="logo-panel">
            <div className="logo-glow"></div>
            <img
              src={logoImage}
              alt="John Hospitality logo"
              className="logo-image"
            />
          </div>
        </div>
      </div>
    </div>
  );
}

export default SignInPage;
