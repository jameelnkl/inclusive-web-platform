import { useNavigate } from "react-router-dom";
import logoImage from "../assets/john-logo.png";
import "../styles/authPages.css";

function WelcomePage() {
  const navigate = useNavigate();

  return (
    <div className="auth-page">
      <div className="auth-shell auth-shell--welcome">
        <div className="auth-left">
          <span className="auth-badge">Join Hospitality</span>

          <h1 className="auth-heading">
            Inclusive Hospitality starts with the right opportunity.
          </h1>

          <p className="auth-text">
            A professional and accessible platform designed to connect people
            and possibilities in hospitality.
          </p>

          <div className="welcome-actions">
            <button
              className="primary-btn"
              onClick={() => navigate("/signup")}
            >
              Create Account
            </button>

            <button
              className="secondary-btn"
              onClick={() => navigate("/signin")}
            >
              Sign In
            </button>
          </div>
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

export default WelcomePage;