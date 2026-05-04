import { useState } from "react";
import { Link } from "react-router-dom";
import logoImage from "../assets/john-logo.png";
import { requestPasswordReset } from "../services/authService";
import "../styles/authPages.css";

function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [sentEmail, setSentEmail] = useState("");
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
      setSentEmail(email);
      setMessage(data.message || "We sent a reset link to your email.");
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
          <span className="auth-badge">🔐 Password Reset</span>
          <h1 className="auth-title">Forgot Password?</h1>
          <p className="auth-subtitle">
            No worries! Enter your email address and we&apos;ll send you a secure
            link to reset your password.
          </p>

          {!message ? (
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

              <button type="submit" className="primary-btn full-width" disabled={loading}>
                {loading ? "Sending..." : "Send Reset Link"}
              </button>
            </form>
          ) : (
            <div className="reset-success-card">
              <div className="reset-success-icon">📬</div>

              <h3>Check your inbox!</h3>

              <p>
                We sent a reset link to <strong>{sentEmail}</strong>. It expires in
                1 hour.
              </p>

              <p className="reset-success-note">
                Didn&apos;t receive it? Check your spam folder or{" "}
                <button
                  type="button"
                  onClick={() => {
                    setMessage("");
                    setError("");
                  }}
                >
                  try again
                </button>
              </p>
            </div>
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