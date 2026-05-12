import { useNavigate } from "react-router-dom";
import logoImage from "../assets/john-logo.png";
import "../styles/authPages.css";

function WelcomePage() {
  const navigate = useNavigate();

  return (
    <div className="auth-page">
      <div className="auth-shell auth-shell--welcome">
        <div className="auth-left auth-left--welcome">
          <span className="auth-badge">
            Jo<span className="badge-i">I</span>n Hospitality
          </span>

          <h1 className="auth-heading">
            <span>Inclusive Hospitality</span> starts with the right opportunity.
          </h1>

          <p className="auth-text">
            A professional and accessible platform designed to connect people
            and possibilities in hospitality.
          </p>

          <div className="welcome-stats">
            <div className="welcome-stat-card">
              <div className="stat-icon stat-icon-blue">
                <svg viewBox="0 0 24 24" fill="none">
                  <path d="M12 3L19 6V11C19 15.5 16.2 19.4 12 21C7.8 19.4 5 15.5 5 11V6L12 3Z" />
                  <path d="M9 12L11 14L15.5 9.5" />
                </svg>
              </div>
              <strong>100%</strong>
              <span>Inclusive</span>
            </div>

            <div className="welcome-stat-card">
              <div className="stat-icon stat-icon-green">
                <svg viewBox="0 0 24 24" fill="none">
                  <circle cx="12" cy="8" r="4" />
                  <path d="M5 21C5.8 16.8 8.6 14.5 12 14.5C15.4 14.5 18.2 16.8 19 21" />
                </svg>
              </div>
              <strong>Accessible</strong>
              <span>Opportunities</span>
            </div>

            <div className="welcome-stat-card">
              <div className="stat-icon stat-icon-purple">
                <svg viewBox="0 0 24 24" fill="none">
                  <circle cx="9" cy="9" r="3.2" />
                  <circle cx="16.5" cy="10.5" r="2.6" />
                  <path d="M3.8 21C4.4 17.5 6.4 15.6 9 15.6C11.6 15.6 13.6 17.5 14.2 21" />
                  <path d="M13.5 16.4C15.8 16.6 17.5 18.1 18.1 21" />
                </svg>
              </div>
              <strong>Meaningful</strong>
              <span>Connections</span>
            </div>
          </div>

          <div className="welcome-actions">
            <button className="primary-btn" onClick={() => navigate("/signup")}>
              <span>Create Account</span>
              <span className="btn-arrow">→</span>
            </button>

            <button className="secondary-btn" onClick={() => navigate("/signin")}>
              Sign In
            </button>
          </div>
        </div>

        <div className="auth-right">
          <div className="logo-panel">
            <div className="logo-orb logo-orb-1"></div>
            <div className="logo-orb logo-orb-2"></div>
            <div className="logo-glow"></div>
            <img src={logoImage} alt="JoIn Hospitality logo" className="logo-image" />
          </div>
        </div>
      </div>
    </div>
  );
}

export default WelcomePage;
