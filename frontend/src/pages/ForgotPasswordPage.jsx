import { useState } from "react";
import { Link } from "react-router-dom";
import logoImage from "../assets/john-logo.png";
import { requestPasswordReset } from "../services/authService";
import "../styles/authPages.css";

function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");

    if (!email) {
      setError("Please enter your email address.");
      return;
    }

    try {
      setLoading(true);
      await requestPasswordReset(email);
      setSuccess(true);
    } catch (err) {
      setError(err.message || "Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-page">
      <div className="auth-shell">
        <div className="auth-left">
          <span className="auth-badge">🔒 Password Reset</span>
          <h1 className="auth-title">Forgot Password?</h1>
          <p className="auth-subtitle">
            No worries! Enter your email address and we'll send you a secure link to reset your password.
          </p>

          {success ? (
            <div className="success-box">
              <div className="success-icon">📬</div>
              <h3 className="success-title">Check your inbox!</h3>
              <p className="success-text">
                We sent a reset link to <strong>{email}</strong>. It expires in 1 hour.
              </p>
              <p className="success-hint">
                Didn't receive it? Check your spam folder or{" "}
                <button className="link-btn" onClick={() => { setSuccess(false); setEmail(""); }}>
                  try again
                </button>.
              </p>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="auth-form">
              <div className="auth-field">
                <label htmlFor="email">Email Address</label>
                <input
                  id="email"
                  type="email"
                  placeholder="Enter your email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="auth-input"
                />
                <p className="field-hint">We'll send a reset link to this address</p>
              </div>

              {error && <p className="auth-error">{error}</p>}

              <button type="submit" className="primary-btn full-width" disabled={loading}>
                {loading ? (
                  <span className="btn-loading">
                    <span className="spinner" />
                    Sending...
                  </span>
                ) : "Send Reset Link"}
              </button>
            </form>
          )}

          <p className="auth-footer">
            Remembered your password? <Link to="/signin">Sign in</Link>
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

export default ForgotPasswordPage;
