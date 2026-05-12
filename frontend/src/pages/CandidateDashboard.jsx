import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  getToken,
  logout,
  applyToJob,
  getCandidateApplications,
} from "../services/authService";

const API_BASE_URL = "https://fyp-backend-cbaa.onrender.com/api";
const BACKEND_BASE_URL = "https://fyp-backend-cbaa.onrender.com";

const disabilities = [
  { name: "Ankle", image: "/Disabilities/Ankle.png" },
  { name: "Arm", image: "/Disabilities/Arm.png" },
  { name: "Both Ankles", image: "/Disabilities/BothAnkles.png" },
  { name: "Both Arms", image: "/Disabilities/BothArms.png" },
  { name: "Both Forearms", image: "/Disabilities/BothForearms.png" },
  { name: "Both Hands", image: "/Disabilities/BothHands.png" },
  { name: "Both Knees", image: "/Disabilities/BothKnees.png" },
  { name: "Both Legs", image: "/Disabilities/BothLegs.png" },
  { name: "CVA", image: "/Disabilities/CVA.png" },
  { name: "Forearm", image: "/Disabilities/Forearm.png" },
  { name: "Knee", image: "/Disabilities/Knee.png" },
  { name: "Leg", image: "/Disabilities/Leg.png" },
  { name: "Pelvis Legs Wheelchair", image: "/Disabilities/PelvisLegsWheelchair.png" },
  { name: "Waist Wheelchair", image: "/Disabilities/WaistWheelchair.png" },
  { name: "Wheelchair", image: "/Disabilities/Wheelchair.png" },
];

const disabilityFeasibilityRules = {
  Wheelchair: {
    difficult: ["move around", "cleaning", "display"],
    notFeasible: ["stand", "walk", "lift heavy", "carry heavy", "climb"],
  },
  "Waist Wheelchair": {
    difficult: ["move around", "cleaning", "display"],
    notFeasible: ["stand", "walk", "lift heavy", "carry heavy", "climb"],
  },
  "Pelvis Legs Wheelchair": {
    difficult: ["move around", "cleaning", "display"],
    notFeasible: ["stand", "walk", "lift heavy", "carry heavy", "climb"],
  },
  Leg: {
    difficult: ["move around", "cleaning", "display"],
    notFeasible: ["stand for long", "walk for long", "lift heavy", "carry heavy"],
  },
  "Both Legs": {
    difficult: ["move around", "cleaning", "display"],
    notFeasible: ["stand", "walk", "lift heavy", "carry heavy", "climb"],
  },
  Knee: {
    difficult: ["move around", "cleaning", "display"],
    notFeasible: ["stand for long", "walk for long", "climb"],
  },
  "Both Knees": {
    difficult: ["move around", "cleaning", "display"],
    notFeasible: ["stand", "walk", "climb", "carry heavy"],
  },
  Ankle: {
    difficult: ["move around", "display"],
    notFeasible: ["stand for long", "walk for long", "carry heavy"],
  },
  "Both Ankles": {
    difficult: ["move around", "display", "cleaning"],
    notFeasible: ["stand", "walk", "carry heavy"],
  },
  Arm: {
    difficult: ["use one hand", "precise hand", "repetitive hand", "package", "cleaning"],
    notFeasible: ["lift heavy", "carry heavy"],
  },
  "Both Arms": {
    difficult: ["communicate", "read", "count"],
    notFeasible: ["use one hand", "precise hand", "repetitive hand", "package", "handle lightweight", "handle money", "cleaning"],
  },
  Forearm: {
    difficult: ["use one hand", "precise hand", "repetitive hand", "package", "cleaning"],
    notFeasible: ["lift heavy", "carry heavy"],
  },
  "Both Forearms": {
    difficult: ["communicate", "read", "count"],
    notFeasible: ["use one hand", "precise hand", "repetitive hand", "package", "handle lightweight", "handle money", "cleaning"],
  },
  "Both Hands": {
    difficult: ["communicate", "read", "count"],
    notFeasible: ["use one hand", "precise hand", "repetitive hand", "package", "handle lightweight", "handle money", "cleaning"],
  },
  CVA: {
    difficult: ["use one hand", "precise hand", "repetitive hand", "communicate", "move around", "cleaning"],
    notFeasible: ["carry heavy", "lift heavy"],
  },
};

function BriefcaseIcon({ size = 22 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M9 7V6.2C9 5.54 9.54 5 10.2 5H13.8C14.46 5 15 5.54 15 6.2V7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
      <path d="M5.6 8H18.4C19.28 8 20 8.72 20 9.6V17.4C20 18.28 19.28 19 18.4 19H5.6C4.72 19 4 18.28 4 17.4V9.6C4 8.72 4.72 8 5.6 8Z" stroke="currentColor" strokeWidth="2" />
      <path d="M4 12.2H20" stroke="currentColor" strokeWidth="2" />
      <path d="M10.8 12.2H13.2V13.6C13.2 14.26 12.66 14.8 12 14.8C11.34 14.8 10.8 14.26 10.8 13.6V12.2Z" fill="currentColor" />
    </svg>
  );
}

function BuildingIcon({ size = 30 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M5 21V5.8C5 4.81 5.81 4 6.8 4H13.2C14.19 4 15 4.81 15 5.8V21" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path d="M15 10H17.2C18.19 10 19 10.81 19 11.8V21" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path d="M8 8H9.8" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
      <path d="M8 11H9.8" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
      <path d="M8 14H9.8" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
      <path d="M12 8H12.1" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" />
      <path d="M12 11H12.1" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" />
      <path d="M12 14H12.1" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" />
      <path d="M3.5 21H20.5" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
    </svg>
  );
}

function LocationIcon({ size = 17 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M12 21C12 21 18 15.5 18 10.5C18 7.19 15.31 4.5 12 4.5C8.69 4.5 6 7.19 6 10.5C6 15.5 12 21 12 21Z" stroke="currentColor" strokeWidth="1.9" />
      <circle cx="12" cy="10.5" r="2.2" stroke="currentColor" strokeWidth="1.9" />
    </svg>
  );
}

function JobTypeIcon({ size = 17 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M9 7V6.2C9 5.54 9.54 5 10.2 5H13.8C14.46 5 15 5.54 15 6.2V7" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path d="M5.5 8H18.5C19.33 8 20 8.67 20 9.5V17.5C20 18.33 19.33 19 18.5 19H5.5C4.67 19 4 18.33 4 17.5V9.5C4 8.67 4.67 8 5.5 8Z" stroke="currentColor" strokeWidth="1.9" />
      <path d="M4 12H20" stroke="currentColor" strokeWidth="1.9" />
    </svg>
  );
}

function CalendarIcon({ size = 17 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M7 5V8" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path d="M17 5V8" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path d="M5.8 7H18.2C19.19 7 20 7.81 20 8.8V18.2C20 19.19 19.19 20 18.2 20H5.8C4.81 20 4 19.19 4 18.2V8.8C4 7.81 4.81 7 5.8 7Z" stroke="currentColor" strokeWidth="1.9" />
      <path d="M4 11H20" stroke="currentColor" strokeWidth="1.9" />
    </svg>
  );
}

function CompanySmallIcon({ size = 16 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M6 20V5.8C6 4.81 6.81 4 7.8 4H14.2C15.19 4 16 4.81 16 5.8V20" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
      <path d="M16 10H18.2C19.19 10 20 10.81 20 11.8V20" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
      <path d="M9 8H10.4" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" />
      <path d="M9 11H10.4" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" />
      <path d="M9 14H10.4" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" />
      <path d="M4 20H21" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  );
}

function getCompanyInitial(companyName) {
  return companyName ? companyName.charAt(0).toUpperCase() : "J";
}

function getCompanyLogoUrl(item) {
  const logoUrl =
    item?.companyLogoUrl ||
    item?.employerProfile?.logoUrl ||
    item?.logoUrl ||
    "";
  if (!logoUrl) return "";
  if (logoUrl.startsWith("http")) return logoUrl;
  if (logoUrl.startsWith("/uploads")) return `${BACKEND_BASE_URL}${logoUrl}`;
  return logoUrl;
}

function CompanyLogo({ item, size = "small" }) {
  const logoUrl = getCompanyLogoUrl(item);
  const isLarge = size === "large";
  const wrapperStyle = isLarge ? styles.companyLogoLarge : styles.companyLogo;
  const imageStyle = isLarge ? styles.companyLogoLargeImage : styles.companyLogoImage;
  if (logoUrl) {
    return (
      <div style={wrapperStyle}>
        <img src={logoUrl} alt={`${item?.companyName || "Company"} logo`} style={imageStyle} />
      </div>
    );
  }
  return <div style={wrapperStyle}>{getCompanyInitial(item?.companyName)}</div>;
}

function CandidateDashboard() {
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState("PROFILE");
  const [candidateName, setCandidateName] = useState("Candidate");
  const [selectedDisabilities, setSelectedDisabilities] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [successMessage, setSuccessMessage] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [loadingProfile, setLoadingProfile] = useState(true);
  const [savingProfile, setSavingProfile] = useState(false);
  const [aiResults, setAiResults] = useState(null);
  const [aiLoading, setAiLoading] = useState(false);
  const [aiError, setAiError] = useState("");

  const [jobs, setJobs] = useState([]);
  const [loadingJobs, setLoadingJobs] = useState(false);
  const [jobsError, setJobsError] = useState("");
  const [selectedJob, setSelectedJob] = useState(null);

  const [selectedCompany, setSelectedCompany] = useState(null);
  const [companyModalTab, setCompanyModalTab] = useState("PROFILE");

  const [applicationDocument, setApplicationDocument] = useState(null);
  const [recommendationLetter, setRecommendationLetter] = useState(null);
  const [submittingApplication, setSubmittingApplication] = useState(false);

  const [candidateApplications, setCandidateApplications] = useState([]);
  const [loadingApplications, setLoadingApplications] = useState(false);
  const [applicationsError, setApplicationsError] = useState("");
  const [applicationStatusFilter, setApplicationStatusFilter] = useState("all");

  useEffect(() => {
    fetchCandidateProfile();
  }, []);

  useEffect(() => {
    if (activeTab === "JOBS") fetchJobs();
    if (activeTab === "APPLICATIONS") fetchCandidateApplications();
  }, [activeTab]);

  const filteredDisabilities = disabilities.filter((disability) =>
    disability.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const filteredApplications =
    applicationStatusFilter === "all"
      ? candidateApplications
      : candidateApplications.filter(
          (application) => application.status === applicationStatusFilter
        );

  function getCompanyKey(item) {
    return (
      item?.employerProfile?.companyName ||
      item?.companyName ||
      item?.company ||
      ""
    );
  }

  function getCompanyJobs(companyItem) {
    const key = getCompanyKey(companyItem).toLowerCase();
    return jobs.filter((job) => getCompanyKey(job).toLowerCase() === key);
  }

  function openCompanyProfile(item) {
    setSelectedCompany(item);
    setCompanyModalTab("PROFILE");
  }

  function openJobFromCompany(job) {
    setSelectedJob(job);
    setSelectedCompany(null);
    setApplicationDocument(null);
    setRecommendationLetter(null);
    setSuccessMessage("");
    setErrorMessage("");
    setActiveTab("JOBS");
  }

  async function fetchCandidateProfile() {
    try {
      setLoadingProfile(true);
      setErrorMessage("");
      const token = getToken();
      if (!token) {
        navigate("/signin");
        return;
      }
      const response = await fetch(`${API_BASE_URL}/candidate/profile`, {
        method: "GET",
        headers: { "X-Auth-Token": token },
      });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) {
        throw new Error(data.message || "Failed to load profile.");
      }
      const profile = data.profile || data;
      setCandidateName(
        profile.username ||
          profile.name ||
          profile.fullName ||
          profile.email?.split("@")[0] ||
          "Candidate"
      );
      setSelectedDisabilities(profile.selectedDisabilities || []);
    } catch (err) {
      setErrorMessage(err.message || "Something went wrong while loading profile.");
    } finally {
      setLoadingProfile(false);
    }
  }

  async function fetchJobs() {
    try {
      setLoadingJobs(true);
      setJobsError("");
      const response = await fetch(`${API_BASE_URL}/jobs`);
      const data = await response.json().catch(() => ({}));
      if (!response.ok) {
        throw new Error(data.message || "Failed to load jobs.");
      }
      setJobs(data.jobs || []);
    } catch (err) {
      setJobsError(err.message || "Something went wrong while loading jobs.");
    } finally {
      setLoadingJobs(false);
    }
  }

  async function fetchCandidateApplications() {
    try {
      setLoadingApplications(true);
      setApplicationsError("");
      const data = await getCandidateApplications();
      setCandidateApplications(data.applications || []);
    } catch (err) {
      setApplicationsError(err.message || "Failed to load applications.");
    } finally {
      setLoadingApplications(false);
    }
  }

  function getTaskRequiredAbilities(task) {
    if (Array.isArray(task.requiredAbilities) && task.requiredAbilities.length > 0) {
      return task.requiredAbilities.map((item) => String(item).trim()).filter(Boolean);
    }
    if (typeof task.requiredAbilities === "string" && task.requiredAbilities.trim() !== "") {
      return task.requiredAbilities.split(/,|\n|-/).map((item) => item.trim()).filter(Boolean);
    }
    const text = `${task.taskName || ""} ${task.description || ""}`.toLowerCase();
    const inferred = [];
    if (text.includes("customer") || text.includes("sale") || text.includes("payment")) {
      inferred.push("Can communicate with customers", "Can count", "Can handle money");
    }
    if (text.includes("package") || text.includes("label") || text.includes("wrap")) {
      inferred.push("Can package finished products", "Can handle lightweight materials", "Can use one hand");
    }
    if (text.includes("clean") || text.includes("hygiene") || text.includes("sanitize")) {
      inferred.push("Can follow hygiene rules", "Can perform light cleaning tasks", "Can use one hand");
    }
    if (text.includes("chocolate") || text.includes("mold") || text.includes("coat") || text.includes("prepare") || text.includes("mix")) {
      inferred.push("Can use one hand", "Can perform repetitive hand movements", "Can handle lightweight materials", "Can work seated");
    }
    if (text.includes("display") || text.includes("arrange")) {
      inferred.push("Can read", "Can handle lightweight materials", "Can move around while seated");
    }
    return [...new Set(inferred)];
  }

  function calculateTaskFeasibility(task) {
    const requiredAbilities = getTaskRequiredAbilities(task);
    if (requiredAbilities.length === 0) {
      return { label: "Not calculated", score: 0, status: "not_calculated" };
    }
    if (selectedDisabilities.length === 0) {
      return { label: "Select disabilities first", score: 0, status: "not_calculated" };
    }
    let totalScore = 0;
    requiredAbilities.forEach((ability) => {
      const normalizedAbility = ability.toLowerCase();
      let abilityScore = 1;
      selectedDisabilities.forEach((disability) => {
        const rules = disabilityFeasibilityRules[disability];
        if (!rules) return;
        const isNotFeasible = rules.notFeasible.some((keyword) => normalizedAbility.includes(keyword));
        const isDifficult = rules.difficult.some((keyword) => normalizedAbility.includes(keyword));
        if (isNotFeasible) {
          abilityScore = Math.min(abilityScore, 0);
        } else if (isDifficult) {
          abilityScore = Math.min(abilityScore, 0.5);
        }
      });
      totalScore += abilityScore;
    });
    const score = totalScore / requiredAbilities.length;
    const percentage = Math.round(score * 100);
    if (score >= 0.75) return { label: "Feasible", score: percentage, status: "feasible" };
    if (score >= 0.4) return { label: "Feasible with assistance", score: percentage, status: "assistance" };
    return { label: "Not feasible", score: percentage, status: "not_feasible" };
  }

  function getFeasibilityBadgeStyle(status) {
    if (status === "feasible") return { ...styles.feasibilityBadge, background: "#dcfce7", color: "#166534" };
    if (status === "assistance") return { ...styles.feasibilityBadge, background: "#fef3c7", color: "#92400e" };
    if (status === "not_feasible") return { ...styles.feasibilityBadge, background: "#fee2e2", color: "#991b1b" };
    return { ...styles.feasibilityBadge, background: "#e5e7eb", color: "#374151" };
  }

  function getStatusLabel(status) {
    if (!status) return "Pending";
    return status.replace("_", " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
  }

  function getStatusBadgeStyle(status) {
    if (status === "accepted") return { ...styles.applicationStatusBadge, background: "#ecfdf3", color: "#047857" };
    if (status === "rejected") return { ...styles.applicationStatusBadge, background: "#fef2f2", color: "#b91c1c" };
    if (status === "in_review") return { ...styles.applicationStatusBadge, background: "#eef2ff", color: "#312e81" };
    return { ...styles.applicationStatusBadge, background: "#fff7ed", color: "#c2410c" };
  }

  function handleDisabilityChange(disabilityName) {
    setSuccessMessage("");
    setErrorMessage("");
    setSelectedDisabilities((previousDisabilities) => {
      if (previousDisabilities.includes(disabilityName)) {
        return previousDisabilities.filter((item) => item !== disabilityName);
      }
      return [...previousDisabilities, disabilityName];
    });
  }

  async function handleGetAiMatch() {
    if (selectedDisabilities.length === 0) {
      setAiError("Please select at least one disability first.");
      return;
    }
    try {
      setAiLoading(true);
      setAiError("");
      setAiResults(null);
      const response = await fetch(`https://fyp-ai-service-tiyi.onrender.com/predict`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ disabilities: selectedDisabilities }),
      });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) {
        throw new Error(data.message || "AI match failed.");
      }
      setAiResults(data);
    } catch (err) {
      setAiError(err.message || "Something went wrong.");
    } finally {
      setAiLoading(false);
    }
  }

  async function handleSaveProfile() {
    try {
      setSavingProfile(true);
      setSuccessMessage("");
      setErrorMessage("");
      const token = getToken();
      if (!token) {
        navigate("/signin");
        return;
      }
      const response = await fetch(`${API_BASE_URL}/candidate/profile`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-Auth-Token": token,
        },
        body: JSON.stringify({ selectedDisabilities }),
      });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) {
        throw new Error(data.message || "Failed to save profile.");
      }
      setSelectedDisabilities(data.profile?.selectedDisabilities || []);
      setSuccessMessage(data.message || "Profile saved successfully.");
    } catch (err) {
      setErrorMessage(err.message || "Something went wrong while saving profile.");
    } finally {
      setSavingProfile(false);
    }
  }

  async function handleSubmitApplication() {
    if (!selectedJob) return;
    try {
      setSubmittingApplication(true);
      setErrorMessage("");
      setSuccessMessage("");
      await applyToJob(selectedJob.id, applicationDocument, recommendationLetter);
      setSuccessMessage("Application submitted successfully.");
      setApplicationDocument(null);
      setRecommendationLetter(null);
      setActiveTab("APPLICATIONS");
      setSelectedJob(null);
    } catch (err) {
      setErrorMessage(err.message || "Failed to submit application.");
    } finally {
      setSubmittingApplication(false);
    }
  }

  function handleLogout() {
    logout();
    navigate("/signin");
  }

  function getUserInitials(name) {
    if (!name) return "C";
    const parts = name.trim().split(" ").filter(Boolean);
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
    }
    return parts[0]?.slice(0, 2).toUpperCase() || "C";
  }

  const selectedCompanyProfile = selectedCompany?.employerProfile || {};
  const companyJobs = selectedCompany ? getCompanyJobs(selectedCompany) : [];

  return (
    <div style={styles.page}>
      <header style={styles.header}>
        <div>
          <h1 style={styles.logo}>Candidate Dashboard</h1>
          <p style={styles.headerSubtitle}>
            Hello, {candidateName}! Here&apos;s what&apos;s happening with your applications.
          </p>
        </div>
        <div style={styles.userBox}>
          <div style={styles.userAvatar}>{getUserInitials(candidateName)}</div>
          <div>
            <p style={styles.userName}>{candidateName}</p>
            <p style={styles.userRole}>Candidate</p>
          </div>
          <button onClick={handleLogout} style={styles.logoutTextButton}>Logout</button>
        </div>
      </header>

      <nav style={styles.tabs}>
        <button
          onClick={() => setActiveTab("PROFILE")}
          style={{ ...styles.tabButton, ...(activeTab === "PROFILE" ? styles.activeTab : {}) }}
        >
          My Profile
        </button>
        <button
          onClick={() => { setActiveTab("JOBS"); setSelectedJob(null); }}
          style={{ ...styles.tabButton, ...(activeTab === "JOBS" ? styles.activeTab : {}) }}
        >
          Jobs
        </button>
        <button
          onClick={() => setActiveTab("APPLICATIONS")}
          style={{ ...styles.tabButton, ...(activeTab === "APPLICATIONS" ? styles.activeTab : {}) }}
        >
          My Applications
        </button>
      </nav>

      <main style={styles.main}>
        {activeTab === "PROFILE" && (
          <section style={styles.profileGrid}>

            {/* LEFT CARD */}
            <div style={styles.card}>
              <h2 style={styles.sectionTitle}>My Profile</h2>
              <p style={styles.text}>Select the disability or disabilities that apply to you.</p>
              {loadingProfile && <p style={styles.infoText}>Loading profile...</p>}
              {errorMessage && <p style={styles.errorText}>{errorMessage}</p>}
              <input
                type="text"
                placeholder="Search disability..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                style={styles.searchInput}
              />
              <div style={styles.disabilityGrid}>
                {filteredDisabilities.map((disability) => {
                  const isSelected = selectedDisabilities.includes(disability.name);
                  return (
                    <button
                      key={disability.name}
                      onClick={() => handleDisabilityChange(disability.name)}
                      style={{ ...styles.disabilityCard, ...(isSelected ? styles.selectedDisabilityCard : {}) }}
                    >
                      {isSelected && <span style={styles.selectedBadge}>Selected</span>}
                      <div style={styles.imageWrapper}>
                        <img src={disability.image} alt={disability.name} style={styles.disabilityImage} />
                      </div>
                      <span style={styles.disabilityName}>{disability.name}</span>
                    </button>
                  );
                })}
              </div>
              <button onClick={handleSaveProfile} style={styles.saveButton} disabled={savingProfile}>
                {savingProfile ? "Saving..." : "Save Profile"}
              </button>
              {successMessage && <p style={styles.successText}>{successMessage}</p>}
            </div>

            {/* RIGHT CARD — AI Job Match */}
            <div style={styles.card}>
              <h2 style={styles.sectionTitle}>AI Job Match</h2>
              <p style={styles.text}>
                Select your disabilities and click below to get your personalized job compatibility scores.
              </p>

              <button
                onClick={handleGetAiMatch}
                disabled={aiLoading}
                style={{
                  ...styles.saveButton,
                  marginTop: "18px",
                  background: aiLoading ? "#94a3b8" : "#2563eb",
                  width: "100%",
                }}
              >
                {aiLoading ? "Analyzing..." : "Get AI Job Match ✨"}
              </button>

              {aiError && <p style={styles.errorText}>{aiError}</p>}

              {aiResults && (
                <div style={{ marginTop: "24px" }}>

                  {/* Best Match Banner */}
                  <div style={{
                    background: "#eef9f0",
                    border: "1.5px solid #86efac",
                    borderRadius: "16px",
                    padding: "18px",
                    marginBottom: "18px",
                    textAlign: "center",
                  }}>
                    <p style={{ margin: 0, fontSize: "13px", color: "#166534", fontWeight: "700" }}>
                      BEST MATCH
                    </p>
                    <p style={{ margin: "6px 0 0", fontSize: "26px", fontWeight: "900", color: "#15803d" }}>
                      {aiResults.bestMatch.job}
                    </p>
                    <p style={{ margin: "4px 0 0", fontSize: "20px", fontWeight: "800", color: "#166534" }}>
                      {aiResults.bestMatch.compatibility}% Compatible
                    </p>
                  </div>

                  {/* All Jobs Ranked */}
                  {aiResults.results.map((result, index) => (
                    <div key={result.job} style={{
                      border: "1px solid #e5e7eb",
                      borderRadius: "14px",
                      padding: "16px",
                      marginBottom: "12px",
                      background: index === 0 ? "#f0fdf4" : "#f8fafc",
                    }}>
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        <p style={{ margin: 0, fontWeight: "800", fontSize: "16px", color: "#0f172a" }}>
                          {index + 1}. {result.job}
                        </p>
                        <span style={{
                          background: index === 0 ? "#dcfce7" : "#e0e7ff",
                          color: index === 0 ? "#166534" : "#3730a3",
                          padding: "6px 14px",
                          borderRadius: "999px",
                          fontWeight: "800",
                          fontSize: "15px",
                        }}>
                          {result.compatibility}%
                        </span>
                      </div>

                      {/* Progress bar */}
                      <div style={{
                        marginTop: "10px",
                        height: "8px",
                        background: "#e5e7eb",
                        borderRadius: "999px",
                        overflow: "hidden",
                      }}>
                        <div style={{
                          width: `${result.compatibility}%`,
                          height: "100%",
                          background: index === 0 ? "#22c55e" : "#6366f1",
                          borderRadius: "999px",
                        }} />
                      </div>

                      {/* Remaining abilities */}
                      <div style={{ marginTop: "12px" }}>
                        <p style={{ margin: "0 0 8px", fontSize: "13px", fontWeight: "700", color: "#64748b" }}>
                          Remaining abilities ({result.remainingAbilities.length}):
                        </p>
                        <div style={{ display: "flex", flexWrap: "wrap", gap: "6px" }}>
                          {result.remainingAbilities.map((ability) => (
                            <span key={ability} style={{
                              background: "#eef2ff",
                              color: "#3730a3",
                              padding: "5px 10px",
                              borderRadius: "999px",
                              fontSize: "12px",
                              fontWeight: "700",
                            }}>
                              ✓ {ability}
                            </span>
                          ))}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

          </section>
        )}

        {activeTab === "JOBS" && (
          <section style={styles.card}>
            {!selectedJob ? (
              <>
                <h2 style={styles.sectionTitle}>Available Jobs</h2>
                <p style={styles.text}>Browse posted jobs and click a card to view full details.</p>
                {loadingJobs && <p style={styles.infoText}>Loading jobs...</p>}
                {jobsError && <p style={styles.errorText}>{jobsError}</p>}
                {!loadingJobs && jobs.length === 0 && (
                  <div style={styles.emptyJobsBox}>No jobs have been posted yet.</div>
                )}
                <div style={styles.jobsGrid}>
                  {jobs.map((job) => (
                    <button
                      key={job.id}
                      style={styles.jobCard}
                      onClick={() => {
                        setSelectedJob(job);
                        setApplicationDocument(null);
                        setRecommendationLetter(null);
                        setSuccessMessage("");
                        setErrorMessage("");
                      }}
                    >
                      <CompanyLogo item={job} />
                      <div style={styles.jobCardContent}>
                        <h3 style={styles.jobTitle}>{job.title}</h3>
                        <span
                          role="button"
                          tabIndex={0}
                          style={styles.companyNameButton}
                          onClick={(e) => { e.stopPropagation(); openCompanyProfile(job); }}
                          onKeyDown={(e) => { if (e.key === "Enter") { e.stopPropagation(); openCompanyProfile(job); } }}
                        >
                          {job.companyName}
                        </span>
                      </div>
                    </button>
                  ))}
                </div>
              </>
            ) : (
              <>
                <button style={styles.backButton} onClick={() => setSelectedJob(null)}>
                  ← Back to jobs
                </button>
                <div style={styles.jobDetailsHeader}>
                  <CompanyLogo item={selectedJob} size="large" />
                  <div>
                    <h2 style={styles.jobDetailsTitle}>{selectedJob.title}</h2>
                    <button type="button" style={styles.companyNameLink} onClick={() => openCompanyProfile(selectedJob)}>
                      {selectedJob.companyName}
                    </button>
                    <p style={styles.jobMeta}>
                      {selectedJob.location} · {selectedJob.jobType} · {selectedJob.workMode}
                    </p>
                  </div>
                </div>
                <div style={styles.detailsGrid}>
                  <div style={styles.detailBox}>
                    <strong>Application deadline</strong>
                    <span>{selectedJob.applicationDeadline || "Not specified"}</span>
                  </div>
                </div>
                <h3 style={styles.detailsSectionTitle}>Job Description</h3>
                <p style={styles.detailsText}>{selectedJob.description}</p>
                {selectedJob.requirements && (
                  <>
                    <h3 style={styles.detailsSectionTitle}>Requirements</h3>
                    <p style={styles.detailsText}>{selectedJob.requirements}</p>
                  </>
                )}
                <h3 style={styles.detailsSectionTitle}>Tasks</h3>
                <div style={styles.taskList}>
                  {(selectedJob.tasks || []).map((task, index) => {
                    const feasibility = calculateTaskFeasibility(task);
                    return (
                      <div key={task.id || index} style={styles.taskItem}>
                        <div style={styles.taskHeader}>
                          <strong>{index + 1}. {task.taskName}</strong>
                          <span style={getFeasibilityBadgeStyle(feasibility.status)}>
                            {feasibility.status === "not_feasible"
                              ? feasibility.label
                              : `${feasibility.label} · ${feasibility.score}%`}
                          </span>
                        </div>
                        {task.description && <p>{task.description}</p>}
                        {getTaskRequiredAbilities(task).length > 0 && (
                          <div style={styles.abilityChips}>
                            {getTaskRequiredAbilities(task).map((ability) => (
                              <span key={ability} style={styles.abilityChip}>{ability}</span>
                            ))}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
                <div style={styles.applicationBox}>
                  <h3 style={styles.detailsSectionTitle}>Application Documents</h3>
                  {successMessage && <p style={styles.successText}>{successMessage}</p>}
                  {errorMessage && <p style={styles.errorText}>{errorMessage}</p>}
                  <label style={styles.uploadLabel}>
                    Upload Application Document {selectedJob.cvRequired ? "*" : ""}
                    <input
                      type="file"
                      accept=".pdf,.doc,.docx"
                      style={styles.fileInput}
                      required={selectedJob.cvRequired}
                      onChange={(e) => setApplicationDocument(e.target.files?.[0] || null)}
                    />
                  </label>
                  <label style={styles.uploadLabel}>
                    Upload Recommendation Letter {selectedJob.coverLetterRequired ? "*" : ""}
                    <input
                      type="file"
                      accept=".pdf,.doc,.docx"
                      style={styles.fileInput}
                      required={selectedJob.coverLetterRequired}
                      onChange={(e) => setRecommendationLetter(e.target.files?.[0] || null)}
                    />
                  </label>
                  <button
                    type="button"
                    style={styles.applyButton}
                    onClick={handleSubmitApplication}
                    disabled={submittingApplication}
                  >
                    {submittingApplication ? "Submitting..." : "Submit Application"}
                  </button>
                </div>
              </>
            )}
          </section>
        )}

        {activeTab === "APPLICATIONS" && (
          <section style={styles.applicationsShell}>
            <div style={styles.applicationsHeader}>
              <div style={styles.applicationsHeaderLeft}>
                <div style={styles.applicationsIcon}>
                  <BriefcaseIcon size={23} />
                </div>
                <div>
                  <h2 style={styles.applicationsTitle}>My Applications</h2>
                  <p style={styles.applicationsSubtitle}>Track and manage your job applications</p>
                </div>
              </div>
              <select
                value={applicationStatusFilter}
                onChange={(e) => setApplicationStatusFilter(e.target.value)}
                style={styles.statusFilterSelect}
              >
                <option value="all">All Status</option>
                <option value="pending">Pending</option>
                <option value="in_review">In Review</option>
                <option value="accepted">Accepted</option>
                <option value="rejected">Rejected</option>
              </select>
            </div>
            {loadingApplications && <p style={styles.infoText}>Loading applications...</p>}
            {applicationsError && <p style={styles.errorText}>{applicationsError}</p>}
            {!loadingApplications && candidateApplications.length === 0 && (
              <div style={styles.emptyJobsBox}>You have not submitted any applications yet.</div>
            )}
            {!loadingApplications && candidateApplications.length > 0 && filteredApplications.length === 0 && (
              <div style={styles.emptyJobsBox}>No applications match this status.</div>
            )}
            <div style={styles.applicationCards}>
              {filteredApplications.map((application) => (
                <div key={application.id} style={styles.applicationCard}>
                  {getCompanyLogoUrl(application) ? (
                    <div style={styles.applicationCompanyIcon}>
                      <img
                        src={getCompanyLogoUrl(application)}
                        alt={`${application.companyName || "Company"} logo`}
                        style={styles.applicationCompanyLogoImage}
                      />
                    </div>
                  ) : (
                    <div style={styles.applicationCompanyIcon}>
                      <BuildingIcon size={31} />
                    </div>
                  )}
                  <div style={styles.applicationInfo}>
                    <h3 style={styles.applicationJobTitle}>{application.jobTitle}</h3>
                    <button
                      type="button"
                      style={styles.applicationCompanyButton}
                      onClick={() => {
                        const relatedJob =
                          jobs.find(
                            (job) =>
                              job.companyName === application.companyName ||
                              job.title === application.jobTitle
                          ) || application;
                        openCompanyProfile(relatedJob);
                      }}
                    >
                      <CompanySmallIcon size={16} />
                      {application.companyName}
                    </button>
                    <div style={styles.applicationMetaRow}>
                      <span style={styles.metaItem}>
                        <LocationIcon size={17} />
                        {application.location || "Location not specified"}
                      </span>
                      <span style={styles.metaItem}>
                        <JobTypeIcon size={17} />
                        {application.jobType || "Job application"}
                      </span>
                      <span style={styles.metaItem}>
                        <CalendarIcon size={17} />
                        Applied on{" "}
                        {application.createdAt
                          ? new Date(application.createdAt).toLocaleDateString("en-US", {
                              month: "short",
                              day: "numeric",
                              year: "numeric",
                            })
                          : "Not specified"}
                      </span>
                    </div>
                  </div>
                  <span style={getStatusBadgeStyle(application.status)}>
                    {getStatusLabel(application.status)}
                  </span>
                  <span style={styles.applicationArrow}>›</span>
                </div>
              ))}
            </div>
          </section>
        )}
      </main>

      {selectedCompany && (
        <div style={styles.companyOverlay}>
          <div style={styles.companyModal}>
            <button type="button" style={styles.companyCloseButton} onClick={() => setSelectedCompany(null)}>
              ×
            </button>
            <div style={styles.companyModalHeader}>
              <CompanyLogo item={selectedCompany} size="large" />
              <div>
                <h2 style={styles.companyModalTitle}>
                  {selectedCompany.employerProfile?.companyName ||
                    selectedCompany.companyName ||
                    "Company Profile"}
                </h2>
                <p style={styles.companyModalSubtitle}>
                  {selectedCompany.employerProfile?.industry || "Hospitality"}
                  {selectedCompany.employerProfile?.location
                    ? ` · ${selectedCompany.employerProfile.location}`
                    : selectedCompany.location
                    ? ` · ${selectedCompany.location}`
                    : ""}
                </p>
              </div>
            </div>
            <div style={styles.companyTabs}>
              <button
                type="button"
                style={{ ...styles.companyTabButton, ...(companyModalTab === "PROFILE" ? styles.companyTabActive : {}) }}
                onClick={() => setCompanyModalTab("PROFILE")}
              >
                Profile
              </button>
              <button
                type="button"
                style={{ ...styles.companyTabButton, ...(companyModalTab === "JOBS" ? styles.companyTabActive : {}) }}
                onClick={() => setCompanyModalTab("JOBS")}
              >
                Job Openings
              </button>
            </div>
            {companyModalTab === "PROFILE" && (
              <div style={styles.companyProfileContent}>
                <div style={styles.companyInfoBox}>
                  <h3 style={styles.companyInfoTitle}>About</h3>
                  <p style={styles.companyInfoText}>
                    {selectedCompanyProfile.description || "No company description has been added yet."}
                  </p>
                </div>
                <div style={styles.companyInfoBox}>
                  <h3 style={styles.companyInfoTitle}>Accessibility Statement</h3>
                  <p style={styles.companyInfoText}>
                    {selectedCompanyProfile.accessibilityStatement || "No accessibility statement has been added yet."}
                  </p>
                </div>
                <div style={styles.companyMiniGrid}>
                  <div style={styles.companyMiniBox}>
                    <strong>Location</strong>
                    <span>{selectedCompanyProfile.location || selectedCompany.location || "Not specified"}</span>
                  </div>
                  <div style={styles.companyMiniBox}>
                    <strong>Website</strong>
                    {selectedCompanyProfile.website ? (
                      <a
                        href={selectedCompanyProfile.website.startsWith("http") ? selectedCompanyProfile.website : `https://${selectedCompanyProfile.website}`}
                        target="_blank"
                        rel="noreferrer"
                        style={styles.companyWebsiteLink}
                      >
                        {selectedCompanyProfile.website}
                      </a>
                    ) : (
                      <span>Not specified</span>
                    )}
                  </div>
                  <div style={styles.companyMiniBox}>
                    <strong>Open Jobs</strong>
                    <span>{companyJobs.length}</span>
                  </div>
                </div>
              </div>
            )}
            {companyModalTab === "JOBS" && (
              <div style={styles.companyJobsList}>
                {companyJobs.length === 0 && (
                  <div style={styles.emptyJobsBox}>No open jobs are currently available for this company.</div>
                )}
                {companyJobs.map((job) => (
                  <div key={job.id} style={styles.companyJobCard}>
                    <div>
                      <h3 style={styles.companyJobTitle}>{job.title}</h3>
                      <p style={styles.companyJobMeta}>{job.location} · {job.jobType} · {job.workMode}</p>
                    </div>
                    <button type="button" style={styles.companyApplyButton} onClick={() => openJobFromCompany(job)}>
                      View & Apply
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

const styles = {
  page: {
    minHeight: "100vh",
    background: "#f8fafc",
    color: "#0f172a",
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif',
    WebkitFontSmoothing: "antialiased",
    MozOsxFontSmoothing: "grayscale",
  },
  header: { background: "#ffffff", padding: "30px 54px 28px", display: "flex", justifyContent: "space-between", alignItems: "center", borderBottom: "1px solid #e8edf5" },
  logo: { margin: 0, fontSize: "32px", fontWeight: "800", color: "#081f49", letterSpacing: "-0.7px", lineHeight: "1.12" },
  headerSubtitle: { margin: "14px 0 0", color: "#64748b", fontSize: "16px", fontWeight: "500" },
  userBox: { display: "flex", alignItems: "center", gap: "12px" },
  userAvatar: { width: "52px", height: "52px", borderRadius: "50%", background: "#edf4ff", color: "#2563eb", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "15px", fontWeight: "800" },
  userName: { margin: 0, color: "#0f172a", fontSize: "15px", fontWeight: "800", lineHeight: "1.2" },
  userRole: { margin: "6px 0 0", color: "#64748b", fontSize: "14px", fontWeight: "500" },
  logoutTextButton: { marginLeft: "10px", border: "none", background: "transparent", color: "#ef4444", cursor: "pointer", fontSize: "15px", fontWeight: "800", padding: "6px 0" },
  tabs: { background: "#ffffff", padding: "0 54px", display: "flex", gap: "76px", borderBottom: "1px solid #e8edf5" },
  tabButton: { background: "transparent", border: "none", padding: "22px 0 18px", cursor: "pointer", fontSize: "15px", fontWeight: "700", color: "#334155", borderBottom: "2px solid transparent", transition: "0.2s ease", borderRadius: 0, boxShadow: "none" },
  activeTab: { color: "#2563eb", borderBottom: "2px solid #2563eb", fontWeight: "800" },
  main: { padding: "28px 30px" },
  profileGrid: { display: "grid", gridTemplateColumns: "1.4fr 0.6fr", gap: "22px" },
  card: { background: "#ffffff", borderRadius: "22px", padding: "28px", boxShadow: "0 14px 36px rgba(15, 23, 42, 0.07)" },
  sectionTitle: { margin: "0 0 10px", fontSize: "24px", fontWeight: "800", color: "#071936", letterSpacing: "-0.35px" },
  text: { color: "#64748b", fontSize: "15px", lineHeight: "1.6", fontWeight: "500" },
  searchInput: { width: "100%", marginTop: "18px", marginBottom: "20px", padding: "13px 15px", borderRadius: "14px", border: "1px solid #d1d5db", fontSize: "15px", outline: "none", boxSizing: "border-box" },
  disabilityGrid: { display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: "18px" },
  disabilityCard: { position: "relative", border: "1px solid #e5e7eb", background: "#f9fafb", borderRadius: "18px", padding: "12px", cursor: "pointer", minHeight: "255px", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "space-between", transition: "all 0.2s ease" },
  selectedDisabilityCard: { border: "2px solid #2563eb", background: "#eff6ff", boxShadow: "0 10px 24px rgba(37, 99, 235, 0.16)" },
  selectedBadge: { position: "absolute", top: "12px", right: "12px", background: "#2563eb", color: "#ffffff", fontSize: "11px", fontWeight: "800", padding: "5px 9px", borderRadius: "999px" },
  imageWrapper: { width: "100%", height: "200px", background: "#ffffff", borderRadius: "16px", display: "flex", alignItems: "center", justifyContent: "center", overflow: "hidden" },
  disabilityImage: { width: "100%", height: "100%", objectFit: "contain" },
  disabilityName: { marginTop: "10px", fontSize: "15px", fontWeight: "800", color: "#1f2937", textAlign: "center" },
  saveButton: { marginTop: "24px", border: "none", background: "#2563eb", color: "#ffffff", padding: "12px 18px", borderRadius: "12px", cursor: "pointer", fontWeight: "800" },
  successText: { marginTop: "14px", color: "#166534", fontWeight: "800" },
  errorText: { marginTop: "12px", color: "#dc2626", fontWeight: "800" },
  infoText: { color: "#64748b", fontWeight: "600" },
  emptyBox: { marginTop: "18px", minHeight: "180px", border: "2px dashed #d1d5db", borderRadius: "16px", display: "flex", alignItems: "center", justifyContent: "center", textAlign: "center", color: "#64748b", padding: "20px" },
  selectedBox: { marginTop: "22px" },
  smallTitle: { fontSize: "16px", marginBottom: "12px", color: "#0f172a" },
  selectedChip: { display: "inline-block", background: "#eef2ff", color: "#3730a3", padding: "7px 10px", borderRadius: "999px", fontSize: "13px", fontWeight: "800", margin: "0 8px 8px 0" },
  jobsGrid: { marginTop: "24px", display: "grid", gridTemplateColumns: "repeat(3, minmax(0, 1fr))", gap: "18px" },
  jobCard: { border: "1px solid #e5e7eb", background: "#ffffff", borderRadius: "18px", padding: "18px", cursor: "pointer", textAlign: "left", display: "flex", gap: "14px", alignItems: "center", transition: "all 0.2s ease" },
  companyLogo: { width: "54px", height: "54px", borderRadius: "14px", background: "#eff6ff", color: "#2563eb", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: "800", fontSize: "22px", flexShrink: 0, overflow: "hidden" },
  companyLogoImage: { width: "100%", height: "100%", objectFit: "cover" },
  jobCardContent: { minWidth: 0 },
  jobTitle: { margin: "0 0 6px", fontSize: "18px", color: "#0f172a", fontWeight: "800" },
  companyName: { margin: 0, color: "#64748b", fontSize: "14px", fontWeight: "600" },
  companyNameButton: { color: "#64748b", fontSize: "14px", fontWeight: "700", textDecoration: "underline", textUnderlineOffset: "3px", cursor: "pointer" },
  companyNameLink: { border: "none", background: "transparent", padding: 0, margin: 0, color: "#2563eb", fontSize: "16px", fontWeight: "800", textDecoration: "underline", textUnderlineOffset: "4px", cursor: "pointer" },
  companyWebsiteLink: { color: "#2563eb", fontWeight: "800", textDecoration: "underline", textUnderlineOffset: "4px", wordBreak: "break-word" },
  emptyJobsBox: { marginTop: "20px", border: "2px dashed #d1d5db", borderRadius: "16px", padding: "30px", textAlign: "center", color: "#64748b", fontWeight: "700" },
  backButton: { border: "none", background: "#eef2ff", color: "#2563eb", padding: "10px 14px", borderRadius: "12px", cursor: "pointer", fontWeight: "800", marginBottom: "22px" },
  jobDetailsHeader: { display: "flex", alignItems: "center", gap: "18px", marginBottom: "24px" },
  companyLogoLarge: { width: "76px", height: "76px", borderRadius: "18px", background: "#eff6ff", color: "#2563eb", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: "800", fontSize: "30px", flexShrink: 0, overflow: "hidden" },
  companyLogoLargeImage: { width: "100%", height: "100%", objectFit: "cover" },
  jobDetailsTitle: { margin: "0 0 6px", color: "#0f172a", fontSize: "28px", fontWeight: "800" },
  jobMeta: { margin: "8px 0 0", color: "#64748b", fontWeight: "600" },
  detailsGrid: { display: "grid", gridTemplateColumns: "repeat(1, minmax(0, 1fr))", gap: "14px", marginBottom: "26px", maxWidth: "320px" },
  detailBox: { background: "#f8fafc", border: "1px solid #e5e7eb", borderRadius: "16px", padding: "16px", display: "flex", flexDirection: "column", gap: "8px", color: "#374151" },
  detailsSectionTitle: { margin: "24px 0 10px", color: "#0f172a", fontSize: "20px", fontWeight: "800" },
  detailsText: { color: "#64748b", lineHeight: "1.7", margin: 0 },
  taskList: { display: "flex", flexDirection: "column", gap: "12px" },
  taskItem: { background: "#f8fafc", border: "1px solid #e5e7eb", borderRadius: "16px", padding: "16px", color: "#374151" },
  taskHeader: { display: "flex", justifyContent: "space-between", alignItems: "center", gap: "12px" },
  feasibilityBadge: { padding: "6px 10px", borderRadius: "999px", fontSize: "12px", fontWeight: "800", whiteSpace: "nowrap" },
  abilityChips: { display: "flex", flexWrap: "wrap", gap: "8px", marginTop: "10px" },
  abilityChip: { background: "#eef2ff", color: "#3730a3", padding: "6px 10px", borderRadius: "999px", fontSize: "12px", fontWeight: "800" },
  applicationBox: { marginTop: "28px", background: "#f8fafc", border: "1px solid #e5e7eb", borderRadius: "18px", padding: "22px" },
  uploadLabel: { display: "flex", flexDirection: "column", gap: "10px", color: "#0f172a", fontWeight: "800", marginBottom: "18px" },
  fileInput: { padding: "12px", borderRadius: "12px", border: "1px solid #d1d5db", background: "#ffffff", cursor: "pointer" },
  applyButton: { marginTop: "8px", border: "none", background: "#2563eb", color: "#ffffff", padding: "13px 20px", borderRadius: "12px", cursor: "pointer", fontWeight: "800" },
  applicationsShell: { background: "#ffffff", borderRadius: "22px", padding: "36px 36px 34px", boxShadow: "0 18px 45px rgba(15, 23, 42, 0.075)" },
  applicationsHeader: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "30px" },
  applicationsHeaderLeft: { display: "flex", alignItems: "center", gap: "18px" },
  applicationsIcon: { width: "52px", height: "52px", borderRadius: "14px", background: "#eef3ff", color: "#2563eb", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 },
  applicationsTitle: { margin: 0, fontSize: "28px", fontWeight: "800", color: "#071936", letterSpacing: "-0.45px", lineHeight: "1.15" },
  applicationsSubtitle: { margin: "8px 0 0", color: "#64748b", fontSize: "16px", fontWeight: "500" },
  statusFilterSelect: { border: "1px solid #dfe5ef", background: "#ffffff", color: "#475569", padding: "12px 16px", borderRadius: "9px", fontSize: "15px", fontWeight: "700", cursor: "pointer", outline: "none", minWidth: "132px", height: "50px" },
  applicationCards: { display: "flex", flexDirection: "column", gap: "16px" },
  applicationCard: { border: "1px solid #dfe7f1", borderRadius: "18px", padding: "34px 34px", background: "#ffffff", display: "flex", alignItems: "center", gap: "26px", boxShadow: "0 10px 26px rgba(15, 23, 42, 0.04)" },
  applicationCompanyIcon: { width: "64px", height: "64px", borderRadius: "16px", background: "#eff4fb", color: "#2563eb", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, overflow: "hidden" },
  applicationCompanyLogoImage: { width: "100%", height: "100%", objectFit: "cover" },
  applicationInfo: { flex: 1, textAlign: "left", minWidth: 0 },
  applicationJobTitle: { margin: "0 0 10px", fontSize: "20px", fontWeight: "700", color: "#071936", letterSpacing: "-0.35px", lineHeight: "1.15" },
  applicationCompanyButton: { border: "none", background: "transparent", margin: "0 0 24px", padding: 0, color: "#64748b", fontSize: "16px", fontWeight: "700", display: "flex", alignItems: "center", gap: "10px", cursor: "pointer", textDecoration: "underline", textUnderlineOffset: "4px" },
  applicationMetaRow: { display: "flex", flexWrap: "wrap", alignItems: "center", gap: "30px", color: "#64748b", fontSize: "14px", fontWeight: "600" },
  metaItem: { display: "inline-flex", alignItems: "center", gap: "8px", color: "#64748b", whiteSpace: "nowrap" },
  applicationStatusBadge: { padding: "10px 20px", borderRadius: "999px", fontSize: "16px", fontWeight: "800", textTransform: "capitalize", whiteSpace: "nowrap" },
  applicationArrow: { color: "#94a3b8", fontSize: "30px", fontWeight: "300", lineHeight: 1, marginLeft: "2px" },
  companyOverlay: { position: "fixed", inset: 0, background: "rgba(15, 23, 42, 0.5)", display: "flex", alignItems: "center", justifyContent: "center", padding: "24px", zIndex: 999 },
  companyModal: { width: "900px", maxWidth: "95vw", maxHeight: "88vh", overflowY: "auto", background: "#ffffff", borderRadius: "24px", padding: "30px", boxShadow: "0 24px 70px rgba(15, 23, 42, 0.28)", position: "relative" },
  companyCloseButton: { position: "absolute", top: "18px", right: "20px", width: "36px", height: "36px", borderRadius: "999px", border: "none", background: "#f1f5f9", color: "#0f172a", fontSize: "24px", fontWeight: "800", cursor: "pointer" },
  companyModalHeader: { display: "flex", alignItems: "center", gap: "18px", paddingRight: "46px" },
  companyModalTitle: { margin: 0, color: "#071936", fontSize: "28px", fontWeight: "900" },
  companyModalSubtitle: { margin: "8px 0 0", color: "#64748b", fontSize: "15px", fontWeight: "700" },
  companyTabs: { display: "flex", gap: "18px", borderBottom: "1px solid #e5e7eb", marginTop: "28px" },
  companyTabButton: { border: "none", background: "transparent", padding: "14px 0", color: "#64748b", fontWeight: "800", fontSize: "15px", cursor: "pointer", borderBottom: "2px solid transparent" },
  companyTabActive: { color: "#2563eb", borderBottom: "2px solid #2563eb" },
  companyProfileContent: { marginTop: "24px", display: "flex", flexDirection: "column", gap: "16px" },
  companyInfoBox: { background: "#f8fafc", border: "1px solid #e5e7eb", borderRadius: "18px", padding: "18px" },
  companyInfoTitle: { margin: "0 0 8px", color: "#0f172a", fontSize: "18px", fontWeight: "900" },
  companyInfoText: { margin: 0, color: "#64748b", lineHeight: "1.7", fontWeight: "600" },
  companyMiniGrid: { display: "grid", gridTemplateColumns: "repeat(3, minmax(0, 1fr))", gap: "14px" },
  companyMiniBox: { background: "#ffffff", border: "1px solid #e5e7eb", borderRadius: "16px", padding: "16px", display: "flex", flexDirection: "column", gap: "8px", color: "#64748b", fontWeight: "700" },
  companyJobsList: { marginTop: "24px", display: "flex", flexDirection: "column", gap: "14px" },
  companyJobCard: { border: "1px solid #e5e7eb", borderRadius: "18px", padding: "18px", display: "flex", justifyContent: "space-between", alignItems: "center", gap: "18px", background: "#f8fafc" },
  companyJobTitle: { margin: "0 0 8px", color: "#0f172a", fontSize: "18px", fontWeight: "900" },
  companyJobMeta: { margin: 0, color: "#64748b", fontSize: "14px", fontWeight: "700" },
  companyApplyButton: { border: "none", background: "#2563eb", color: "#ffffff", padding: "11px 16px", borderRadius: "999px", cursor: "pointer", fontWeight: "900", whiteSpace: "nowrap" },
};

export default CandidateDashboard;
