import { useNavigate } from "react-router-dom";
import "./WelcomePage.css";

function WelcomePage() {
  const navigate = useNavigate();

  return (
    <div className="welcome-page">
      <div className="overlay">
        <div className="content">
          <h1>Welcome!</h1>
          <p>Your journey starts here</p>

          <div className="button-group">
            <button
              className="cool-button signup-btn"
              onClick={() => navigate("/signup")}
            >
              Sign Up
            </button>

            <button
              className="cool-button signin-btn"
              onClick={() => navigate("/signin")}
            >
              Sign In
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default WelcomePage;