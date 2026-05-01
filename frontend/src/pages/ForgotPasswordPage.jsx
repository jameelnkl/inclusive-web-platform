import { useState } from "react";
import { Link } from "react-router-dom";
import logoImage from "../assets/john-logo.png";
import { forgotPassword } from "../services/authService";
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
      await forgotPassword(email);
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
          <span className="auth-badge">Password Reset</span>
          <h1 className="auth-title">Forgot Password?</h1>
          <p className="auth-subtitle">
            No worries! Enter your email address and we'll send you a link to reset your password.
          </p>

          {success ? (
            <div className="reset-success-box">
              <p className="auth-success">
                ✅ Reset link sent! Check your email inbox and follow the instructions.
              </p>
              <p className="auth-footer" style={{ marginTop: "12px" }}>
                Didn't receive it? Check your spam folder or{" "}
                <button
                  className="link-btn"
                  onClick={() => { setSuccess(false); setEmail(""); }}
                >
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
              </div>

              {error && <p className="auth-error">{error}</p>}

              <button
                type="submit"
                className="primary-btn full-width"
                disabled={loading}
              >
                {loading ? "Sending..." : "Send Reset Link"}
              </button>
            </form>
          )}

          <p className="auth-footer">
            Remember your password? <Link to="/signin">Sign in</Link>
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
