import { useState } from "react";
import { Link } from "react-router-dom";
import logoImage from "../assets/john-logo.png";
import { requestPasswordReset } from "../services/authService";
import "../styles/authPages.css";

function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setMessage("");
    setError("");

    if (!email) {
      setError("Please enter your email address.");
      return;
    }

    try {
      setLoading(true);

      const data = await requestPasswordReset(email);
      setMessage(data.message || "If an account exists, a reset link has been sent.");
    } catch (err) {
      setError(err.message || "Failed to request password reset.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-page">
      <div className="auth-shell">
        <div className="auth-left">
          <span className="auth-badge">Password Help</span>
          <h1 className="auth-title">Forgot Password</h1>
          <p className="auth-subtitle">
            Enter your email and we will send you a link to reset your password.
          </p>

          <form onSubmit={handleSubmit} className="auth-form">
            <div className="auth-field">
              <label htmlFor="email">Email</label>
              <input
                id="email"
                type="email"
                name="email"
                placeholder="Enter your email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="auth-input"
              />
            </div>

            {error && <p className="auth-error">{error}</p>}

            {message && (
              <p
                style={{
                  color: "#166534",
                  background: "#dcfce7",
                  padding: "12px",
                  borderRadius: "12px",
                  fontWeight: "600",
                }}
              >
                {message}
              </p>
            )}

            <button type="submit" className="primary-btn full-width" disabled={loading}>
              {loading ? "Sending..." : "Send Reset Link"}
            </button>
          </form>

          <p className="auth-footer">
            Remembered your password? <Link to="/signin">Sign in</Link>
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

export default ForgotPasswordPage;