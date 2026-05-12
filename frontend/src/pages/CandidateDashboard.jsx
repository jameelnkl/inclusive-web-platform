import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { getToken, logout, applyToJob, getCandidateApplications } from "../services/authService";

const API_BASE_URL = "https://fyp-backend-cbaa.onrender.com/api";
const BACKEND_BASE_URL = "https://fyp-backend-cbaa.onrender.com";
const AI_SERVICE_URL = "https://fyp-ai-service-tiyi.onrender.com/predict";

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
  Wheelchair: { difficult: ["move around", "cleaning", "display"], notFeasible: ["stand", "walk", "lift heavy", "carry heavy", "climb"] },
  "Waist Wheelchair": { difficult: ["move around", "cleaning", "display"], notFeasible: ["stand", "walk", "lift heavy", "carry heavy", "climb"] },
  "Pelvis Legs Wheelchair": { difficult: ["move around", "cleaning", "display"], notFeasible: ["stand", "walk", "lift heavy", "carry heavy", "climb"] },
  Leg: { difficult: ["move around", "cleaning", "display"], notFeasible: ["stand for long", "walk for long", "lift heavy", "carry heavy"] },
  "Both Legs": { difficult: ["move around", "cleaning", "display"], notFeasible: ["stand", "walk", "lift heavy", "carry heavy", "climb"] },
  Knee: { difficult: ["move around", "cleaning", "display"], notFeasible: ["stand for long", "walk for long", "climb"] },
  "Both Knees": { difficult: ["move around", "cleaning", "display"], notFeasible: ["stand", "walk", "climb", "carry heavy"] },
  Ankle: { difficult: ["move around", "display"], notFeasible: ["stand for long", "walk for long", "carry heavy"] },
  "Both Ankles": { difficult: ["move around", "display", "cleaning"], notFeasible: ["stand", "walk", "carry heavy"] },
  Arm: { difficult: ["use one hand", "precise hand", "repetitive hand", "package", "cleaning"], notFeasible: ["lift heavy", "carry heavy"] },
  "Both Arms": { difficult: ["communicate", "read", "count"], notFeasible: ["use one hand", "precise hand", "repetitive hand", "package", "handle lightweight", "handle money", "cleaning"] },
  Forearm: { difficult: ["use one hand", "precise hand", "repetitive hand", "package", "cleaning"], notFeasible: ["lift heavy", "carry heavy"] },
  "Both Forearms": { difficult: ["communicate", "read", "count"], notFeasible: ["use one hand", "precise hand", "repetitive hand", "package", "handle lightweight", "handle money", "cleaning"] },
  "Both Hands": { difficult: ["communicate", "read", "count"], notFeasible: ["use one hand", "precise hand", "repetitive hand", "package", "handle lightweight", "handle money", "cleaning"] },
  CVA: { difficult: ["use one hand", "precise hand", "repetitive hand", "communicate", "move around", "cleaning"], notFeasible: ["carry heavy", "lift heavy"] },
};

function BriefcaseIcon({ size = 22 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M9 7V6.2C9 5.54 9.54 5 10.2 5H13.8C14.46 5 15 5.54 15 6.2V7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
      <path d="M5.6 8H18.4C19.28 8 20 8.72 20 9.6V17.4C20 18.28 19.28 19 18.4 19H5.6C4.72 19 4 18.28 4 17.4V9.6C4 8.72 4.72 8 5.6 8Z" stroke="currentColor" strokeWidth="2" />
      <path d="M4 12.2H20" stroke="currentColor" strokeWidth="2" />
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

function CircleProgress({ percent, size = 110, color = "#2563eb" }) {
  const r = 44;
  const circ = 2 * Math.PI * r;
  const offset = circ - (percent / 100) * circ;
  return (
    <svg width={size} height={size} viewBox="0 0 100 100">
      <circle cx="50" cy="50" r={r} fill="none" stroke="#e0e7ff" strokeWidth="9" />
      <circle
        cx="50" cy="50" r={r} fill="none"
        stroke={color} strokeWidth="9"
        strokeDasharray={circ}
        strokeDashoffset={offset}
        strokeLinecap="round"
        transform="rotate(-90 50 50)"
        style={{ transition: "stroke-dashoffset 1s ease" }}
      />
      <text x="50" y="46" textAnchor="middle" fontSize="18" fontWeight="800" fill={color}>{percent}%</text>
      <text x="50" y="62" textAnchor="middle" fontSize="9" fill="#64748b" fontWeight="600">match</text>
    </svg>
  );
}

function JobResultCard({ result, index }) {
  const [expanded, setExpanded] = useState(false);
  const colors = ["#2563eb", "#0ea5e9", "#6366f1"];
  const bgColors = ["#eff6ff", "#f0f9ff", "#eef2ff"];
  const color = colors[index] || "#2563eb";
  const bg = bgColors[index] || "#eff6ff";

  return (
    <div style={{
      border: `1.5px solid ${index === 0 ? color : "#e5e7eb"}`,
      borderRadius: "20px",
      padding: "20px",
      marginBottom: "14px",
      background: index === 0 ? bg : "#fafafa",
      transition: "all 0.2s ease",
    }}>
      <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
        <CircleProgress percent={result.compatibility} size={90} color={color} />
        <div style={{ flex: 1 }}>
          <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "4px" }}>
            {index === 0 && (
              <span style={{ background: color, color: "#fff", fontSize: "10px", fontWeight: "800", padding: "3px 8px", borderRadius: "999px" }}>
                BEST MATCH
              </span>
            )}
            <span style={{ fontSize: "11px", fontWeight: "700", color: "#94a3b8" }}>#{index + 1}</span>
          </div>
          <p style={{ margin: 0, fontSize: "20px", fontWeight: "900", color: "#0f172a", letterSpacing: "-0.3px" }}>
            {result.job}
          </p>
          <div style={{ marginTop: "10px", height: "6px", background: "#e2e8f0", borderRadius: "999px", overflow: "hidden" }}>
            <div style={{
              width: `${result.compatibility}%`,
              height: "100%",
              background: `linear-gradient(90deg, ${color}, ${color}cc)`,
              borderRadius: "999px",
              transition: "width 1s ease",
            }} />
          </div>
        </div>
      </div>

      <button
        onClick={() => setExpanded(!expanded)}
        style={{
          marginTop: "14px",
          width: "100%",
          background: "transparent",
          border: `1px solid ${color}40`,
          borderRadius: "10px",
          padding: "8px",
          color: color,
          fontWeight: "700",
          fontSize: "13px",
          cursor: "pointer",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          gap: "6px",
        }}
      >
        {expanded ? "▲ Hide" : "▼ Show"} abilities ({result.remainingAbilities.length})
      </button>

      {expanded && (
        <div style={{ marginTop: "12px", display: "flex", flexWrap: "wrap", gap: "6px" }}>
          {result.remainingAbilities.map((ability) => (
            <span key={ability} style={{
              background: `${color}15`,
              color: color,
              padding: "5px 10px",
              borderRadius: "999px",
              fontSize: "11px",
              fontWeight: "700",
              border: `1px solid ${color}30`,
            }}>
              ✓ {ability}
            </span>
          ))}
        </div>
      )}
    </div>
  );
}

function getCompanyInitial(companyName) {
  return companyName ? companyName.charAt(0).toUpperCase() : "J";
}

function getCompanyLogoUrl(item) {
  const logoUrl = item?.companyLogoUrl || item?.employerProfile?.logoUrl || item?.logoUrl || "";
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

  useEffect(() => { fetchCandidateProfile(); }, []);
  useEffect(() => {
    if (activeTab === "JOBS") fetchJobs();
    if (activeTab === "APPLICATIONS") fetchCandidateApplications();
  }, [activeTab]);

  const filteredDisabilities = disabilities.filter((d) => d.name.toLowerCase().includes(searchTerm.toLowerCase()));
  const filteredApplications = applicationStatusFilter === "all" ? candidateApplications : candidateApplications.filter((a) => a.status === applicationStatusFilter);

  function getCompanyKey(item) { return item?.employerProfile?.companyName || item?.companyName || item?.company || ""; }
  function getCompanyJobs(companyItem) { const key = getCompanyKey(companyItem).toLowerCase(); return jobs.filter((job) => getCompanyKey(job).toLowerCase() === key); }
  function openCompanyProfile(item) { setSelectedCompany(item); setCompanyModalTab("PROFILE"); }
  function openJobFromCompany(job) { setSelectedJob(job); setSelectedCompany(null); setApplicationDocument(null); setRecommendationLetter(null); setSuccessMessage(""); setErrorMessage(""); setActiveTab("JOBS"); }

  async function fetchCandidateProfile() {
    try {
      setLoadingProfile(true);
      const token = getToken();
      if (!token) { navigate("/signin"); return; }
      const response = await fetch(`${API_BASE_URL}/candidate/profile`, { method: "GET", headers: { "X-Auth-Token": token } });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(data.message || "Failed to load profile.");
      const profile = data.profile || data;
      setCandidateName(profile.username || profile.name || profile.fullName || profile.email?.split("@")[0] || "Candidate");
      setSelectedDisabilities(profile.selectedDisabilities || []);
    } catch (err) {
      setErrorMessage(err.message || "Something went wrong.");
    } finally {
      setLoadingProfile(false);
    }
  }

  async function fetchJobs() {
    try {
      setLoadingJobs(true);
      const response = await fetch(`${API_BASE_URL}/jobs`);
      const data = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(data.message || "Failed to load jobs.");
      setJobs(data.jobs || []);
    } catch (err) { setJobsError(err.message); } finally { setLoadingJobs(false); }
  }

  async function fetchCandidateApplications() {
    try {
      setLoadingApplications(true);
      const data = await getCandidateApplications();
      setCandidateApplications(data.applications || []);
    } catch (err) { setApplicationsError(err.message); } finally { setLoadingApplications(false); }
  }

  function getTaskRequiredAbilities(task) {
    if (Array.isArray(task.requiredAbilities) && task.requiredAbilities.length > 0) return task.requiredAbilities.map((i) => String(i).trim()).filter(Boolean);
    if (typeof task.requiredAbilities === "string" && task.requiredAbilities.trim() !== "") return task.requiredAbilities.split(/,|\n|-/).map((i) => i.trim()).filter(Boolean);
    const text = `${task.taskName || ""} ${task.description || ""}`.toLowerCase();
    const inferred = [];
    if (text.includes("customer") || text.includes("sale") || text.includes("payment")) inferred.push("Can communicate with customers", "Can count", "Can handle money");
    if (text.includes("package") || text.includes("label") || text.includes("wrap")) inferred.push("Can package finished products", "Can handle lightweight materials", "Can use one hand");
    if (text.includes("clean") || text.includes("hygiene") || text.includes("sanitize")) inferred.push("Can follow hygiene rules", "Can perform light cleaning tasks", "Can use one hand");
    if (text.includes("chocolate") || text.includes("mold") || text.includes("coat") || text.includes("prepare") || text.includes("mix")) inferred.push("Can use one hand", "Can perform repetitive hand movements", "Can handle lightweight materials", "Can work seated");
    if (text.includes("display") || text.includes("arrange")) inferred.push("Can read", "Can handle lightweight materials", "Can move around while seated");
    return [...new Set(inferred)];
  }

  function calculateTaskFeasibility(task) {
    const req = getTaskRequiredAbilities(task);
    if (req.length === 0) return { label: "Not calculated", score: 0, status: "not_calculated" };
    if (selectedDisabilities.length === 0) return { label: "Select disabilities first", score: 0, status: "not_calculated" };
    let total = 0;
    req.forEach((ability) => {
      const n = ability.toLowerCase(); let s = 1;
      selectedDisabilities.forEach((dis) => {
        const rules = disabilityFeasibilityRules[dis];
        if (!rules) return;
        if (rules.notFeasible.some((k) => n.includes(k))) s = Math.min(s, 0);
        else if (rules.difficult.some((k) => n.includes(k))) s = Math.min(s, 0.5);
      });
      total += s;
    });
    const score = total / req.length;
    const pct = Math.round(score * 100);
    if (score >= 0.75) return { label: "Feasible", score: pct, status: "feasible" };
    if (score >= 0.4) return { label: "Feasible with assistance", score: pct, status: "assistance" };
    return { label: "Not feasible", score: pct, status: "not_feasible" };
  }

  function getFeasibilityBadgeStyle(status) {
    if (status === "feasible") return { ...styles.feasibilityBadge, background: "#dcfce7", color: "#166534" };
    if (status === "assistance") return { ...styles.feasibilityBadge, background: "#fef3c7", color: "#92400e" };
    if (status === "not_feasible") return { ...styles.feasibilityBadge, background: "#fee2e2", color: "#991b1b" };
    return { ...styles.feasibilityBadge, background: "#e5e7eb", color: "#374151" };
  }

  function getStatusLabel(status) { if (!status) return "Pending"; return status.replace("_", " ").replace(/\b\w/g, (l) => l.toUpperCase()); }
  function getStatusBadgeStyle(status) {
    if (status === "accepted") return { ...styles.applicationStatusBadge, background: "#ecfdf3", color: "#047857" };
    if (status === "rejected") return { ...styles.applicationStatusBadge, background: "#fef2f2", color: "#b91c1c" };
    if (status === "in_review") return { ...styles.applicationStatusBadge, background: "#eef2ff", color: "#312e81" };
    return { ...styles.applicationStatusBadge, background: "#fff7ed", color: "#c2410c" };
  }

  function handleDisabilityChange(name) {
    setSuccessMessage(""); setErrorMessage("");
    setSelectedDisabilities((prev) => prev.includes(name) ? prev.filter((i) => i !== name) : [...prev, name]);
  }

  async function handleGetAiMatch() {
    if (selectedDisabilities.length === 0) { setAiError("Please select at least one disability first."); return; }
    try {
      setAiLoading(true); setAiError(""); setAiResults(null);
      const response = await fetch(AI_SERVICE_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ disabilities: selectedDisabilities }),
      });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(data.message || "AI match failed.");
      setAiResults(data);
    } catch (err) { setAiError(err.message || "Something went wrong."); } finally { setAiLoading(false); }
  }

  async function handleSaveProfile() {
    try {
      setSavingProfile(true); setSuccessMessage(""); setErrorMessage("");
      const token = getToken();
      if (!token) { navigate("/signin"); return; }
      const response = await fetch(`${API_BASE_URL}/candidate/profile`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", "X-Auth-Token": token },
        body: JSON.stringify({ selectedDisabilities }),
      });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(data.message || "Failed to save profile.");
      setSelectedDisabilities(data.profile?.selectedDisabilities || []);
      setSuccessMessage("Profile saved successfully.");
    } catch (err) { setErrorMessage(err.message); } finally { setSavingProfile(false); }
  }

  async function handleSubmitApplication() {
    if (!selectedJob) return;
    try {
      setSubmittingApplication(true); setErrorMessage(""); setSuccessMessage("");
      await applyToJob(selectedJob.id, applicationDocument, recommendationLetter);
      setSuccessMessage("Application submitted successfully.");
      setApplicationDocument(null); setRecommendationLetter(null);
      setActiveTab("APPLICATIONS"); setSelectedJob(null);
    } catch (err) { setErrorMessage(err.message); } finally { setSubmittingApplication(false); }
  }

  function handleLogout() { logout(); navigate("/signin"); }
  function getUserInitials(name) {
    if (!name) return "C";
    const parts = name.trim().split(" ").filter(Boolean);
    if (parts.length >= 2) return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
    return parts[0]?.slice(0, 2).toUpperCase() || "C";
  }

  const selectedCompanyProfile = selectedCompany?.employerProfile || {};
  const companyJobs = selectedCompany ? getCompanyJobs(selectedCompany) : [];

  return (
    <div style={styles.page}>
      {/* HEADER */}
      <header style={styles.header}>
        <div>
          <h1 style={styles.logo}>Candidate Dashboard</h1>
          <p style={styles.headerSubtitle}>Hello, {candidateName}! Here&apos;s what&apos;s happening with your applications.</p>
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

      {/* TABS */}
      <nav style={styles.tabs}>
        {["PROFILE", "JOBS", "APPLICATIONS"].map((tab) => (
          <button key={tab} onClick={() => { setActiveTab(tab); if (tab === "JOBS") setSelectedJob(null); }}
            style={{ ...styles.tabButton, ...(activeTab === tab ? styles.activeTab : {}) }}>
            {tab === "PROFILE" ? "My Profile" : tab === "JOBS" ? "Jobs" : "My Applications"}
          </button>
        ))}
      </nav>

      <main style={styles.main}>
        {activeTab === "PROFILE" && (
          <div>
            {/* STEP INDICATOR */}
            <div style={styles.stepRow}>
              {["Select Disabilities", "Get AI Match", "Apply to Jobs"].map((step, i) => (
                <div key={step} style={styles.stepItem}>
                  <div style={{ ...styles.stepCircle, background: i === 0 ? "#2563eb" : i === 1 && aiResults ? "#2563eb" : "#e2e8f0", color: i === 0 || (i === 1 && aiResults) ? "#fff" : "#94a3b8" }}>
                    {i + 1}
                  </div>
                  <span style={{ ...styles.stepLabel, color: i === 0 ? "#2563eb" : "#94a3b8" }}>{step}</span>
                  {i < 2 && <div style={styles.stepLine} />}
                </div>
              ))}
            </div>

            <section style={styles.profileGrid}>
              {/* LEFT — Disability Selection */}
              <div style={styles.card}>
                <div style={styles.cardHeader}>
                  <div>
                    <h2 style={styles.sectionTitle}>Select Your Disabilities</h2>
                    <p style={styles.text}>Choose all that apply to get accurate job recommendations.</p>
                  </div>
                  <div style={styles.selectedCountBadge}>
                    <span style={styles.selectedCountNumber}>{selectedDisabilities.length}</span>
                    <span style={styles.selectedCountLabel}>selected</span>
                  </div>
                </div>

                {loadingProfile && <p style={styles.infoText}>Loading profile...</p>}
                {errorMessage && <p style={styles.errorText}>{errorMessage}</p>}

                <div style={styles.searchWrapper}>
                  <span style={styles.searchIcon}>🔍</span>
                  <input
                    type="text"
                    placeholder="Search disability..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    style={styles.searchInput}
                  />
                </div>

                {selectedDisabilities.length > 0 && (
                  <div style={styles.selectedChipsRow}>
                    {selectedDisabilities.map((d) => (
                      <span key={d} style={styles.selectedChip}>
                        {d}
                        <button onClick={() => handleDisabilityChange(d)} style={styles.chipRemove}>×</button>
                      </span>
                    ))}
                    <button onClick={() => setSelectedDisabilities([])} style={styles.resetBtn}>Reset all</button>
                  </div>
                )}

                <div style={styles.disabilityGrid}>
                  {filteredDisabilities.map((disability) => {
                    const isSelected = selectedDisabilities.includes(disability.name);
                    return (
                      <button key={disability.name} onClick={() => handleDisabilityChange(disability.name)}
                        style={{ ...styles.disabilityCard, ...(isSelected ? styles.selectedDisabilityCard : {}) }}>
                        {isSelected && (
                          <div style={styles.selectedCheck}>✓</div>
                        )}
                        <div style={styles.imageWrapper}>
                          <img src={disability.image} alt={disability.name} style={styles.disabilityImage} />
                        </div>
                        <span style={{ ...styles.disabilityName, color: isSelected ? "#2563eb" : "#1f2937" }}>
                          {disability.name}
                        </span>
                      </button>
                    );
                  })}
                </div>

                <div style={styles.saveRow}>
                  <button onClick={handleSaveProfile} style={styles.saveButton} disabled={savingProfile}>
                    {savingProfile ? "Saving..." : "💾 Save Profile"}
                  </button>
                  {successMessage && <p style={styles.successText}>✓ {successMessage}</p>}
                </div>
              </div>

              {/* RIGHT — AI Job Match */}
              <div style={styles.aiCard}>
                {/* AI Card Header */}
                <div style={styles.aiCardHeader}>
                  <div style={styles.aiIconWrapper}>
                    <span style={{ fontSize: "22px" }}>✨</span>
                  </div>
                  <div>
                    <h2 style={styles.aiTitle}>AI Job Match</h2>
                    <p style={styles.aiSubtitle}>Powered by machine learning</p>
                  </div>
                </div>

                <p style={styles.aiDescription}>
                  Select your disabilities on the left, then click below to get personalized job compatibility scores based on your abilities.
                </p>

                <button onClick={handleGetAiMatch} disabled={aiLoading} style={{ ...styles.aiButton, opacity: aiLoading ? 0.7 : 1 }}>
                  {aiLoading ? (
                    <span>⏳ Analyzing your profile...</span>
                  ) : (
                    <span>Get My Job Match ✨</span>
                  )}
                </button>

                {aiError && (
                  <div style={styles.aiErrorBox}>
                    <span>⚠️ {aiError}</span>
                  </div>
                )}

                {aiResults && (
                  <div style={{ marginTop: "24px" }}>
                    <div style={styles.aiResultsHeader}>
                      <span style={styles.aiResultsTitle}>Your Results</span>
                      <span style={styles.aiResultsSubtitle}>{selectedDisabilities.length} disability{selectedDisabilities.length !== 1 ? "ies" : "y"} analyzed</span>
                    </div>
                    {aiResults.results.map((result, index) => (
                      <JobResultCard key={result.job} result={result} index={index} />
                    ))}
                  </div>
                )}

                {!aiResults && !aiLoading && (
                  <div style={styles.aiEmptyState}>
                    <div style={styles.aiEmptyIcon}>🎯</div>
                    <p style={styles.aiEmptyText}>Your job compatibility scores will appear here</p>
                  </div>
                )}
              </div>
            </section>
          </div>
        )}

        {activeTab === "JOBS" && (
          <section style={styles.card}>
            {!selectedJob ? (
              <>
                <h2 style={styles.sectionTitle}>Available Jobs</h2>
                <p style={styles.text}>Browse posted jobs and click a card to view full details.</p>
                {loadingJobs && <p style={styles.infoText}>Loading jobs...</p>}
                {jobsError && <p style={styles.errorText}>{jobsError}</p>}
                {!loadingJobs && jobs.length === 0 && <div style={styles.emptyJobsBox}>No jobs have been posted yet.</div>}
                <div style={styles.jobsGrid}>
                  {jobs.map((job) => (
                    <button key={job.id} style={styles.jobCard} onClick={() => { setSelectedJob(job); setApplicationDocument(null); setRecommendationLetter(null); setSuccessMessage(""); setErrorMessage(""); }}>
                      <CompanyLogo item={job} />
                      <div style={styles.jobCardContent}>
                        <h3 style={styles.jobTitle}>{job.title}</h3>
                        <span role="button" tabIndex={0} style={styles.companyNameButton}
                          onClick={(e) => { e.stopPropagation(); openCompanyProfile(job); }}
                          onKeyDown={(e) => { if (e.key === "Enter") { e.stopPropagation(); openCompanyProfile(job); } }}>
                          {job.companyName}
                        </span>
                      </div>
                    </button>
                  ))}
                </div>
              </>
            ) : (
              <>
                <button style={styles.backButton} onClick={() => setSelectedJob(null)}>← Back to jobs</button>
                <div style={styles.jobDetailsHeader}>
                  <CompanyLogo item={selectedJob} size="large" />
                  <div>
                    <h2 style={styles.jobDetailsTitle}>{selectedJob.title}</h2>
                    <button type="button" style={styles.companyNameLink} onClick={() => openCompanyProfile(selectedJob)}>{selectedJob.companyName}</button>
                    <p style={styles.jobMeta}>{selectedJob.location} · {selectedJob.jobType} · {selectedJob.workMode}</p>
                  </div>
                </div>
                <div style={styles.detailsGrid}>
                  <div style={styles.detailBox}><strong>Application deadline</strong><span>{selectedJob.applicationDeadline || "Not specified"}</span></div>
                </div>
                <h3 style={styles.detailsSectionTitle}>Job Description</h3>
                <p style={styles.detailsText}>{selectedJob.description}</p>
                {selectedJob.requirements && (<><h3 style={styles.detailsSectionTitle}>Requirements</h3><p style={styles.detailsText}>{selectedJob.requirements}</p></>)}
                <h3 style={styles.detailsSectionTitle}>Tasks</h3>
                <div style={styles.taskList}>
                  {(selectedJob.tasks || []).map((task, index) => {
                    const feasibility = calculateTaskFeasibility(task);
                    return (
                      <div key={task.id || index} style={styles.taskItem}>
                        <div style={styles.taskHeader}>
                          <strong>{index + 1}. {task.taskName}</strong>
                          <span style={getFeasibilityBadgeStyle(feasibility.status)}>
                            {feasibility.status === "not_feasible" ? feasibility.label : `${feasibility.label} · ${feasibility.score}%`}
                          </span>
                        </div>
                        {task.description && <p>{task.description}</p>}
                        {getTaskRequiredAbilities(task).length > 0 && (
                          <div style={styles.abilityChips}>
                            {getTaskRequiredAbilities(task).map((ability) => (<span key={ability} style={styles.abilityChip}>{ability}</span>))}
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
                  <label style={styles.uploadLabel}>Upload Application Document {selectedJob.cvRequired ? "*" : ""}
                    <input type="file" accept=".pdf,.doc,.docx" style={styles.fileInput} required={selectedJob.cvRequired} onChange={(e) => setApplicationDocument(e.target.files?.[0] || null)} />
                  </label>
                  <label style={styles.uploadLabel}>Upload Recommendation Letter {selectedJob.coverLetterRequired ? "*" : ""}
                    <input type="file" accept=".pdf,.doc,.docx" style={styles.fileInput} required={selectedJob.coverLetterRequired} onChange={(e) => setRecommendationLetter(e.target.files?.[0] || null)} />
                  </label>
                  <button type="button" style={styles.applyButton} onClick={handleSubmitApplication} disabled={submittingApplication}>
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
                <div style={styles.applicationsIcon}><BriefcaseIcon size={23} /></div>
                <div>
                  <h2 style={styles.applicationsTitle}>My Applications</h2>
                  <p style={styles.applicationsSubtitle}>Track and manage your job applications</p>
                </div>
              </div>
              <select value={applicationStatusFilter} onChange={(e) => setApplicationStatusFilter(e.target.value)} style={styles.statusFilterSelect}>
                <option value="all">All Status</option>
                <option value="pending">Pending</option>
                <option value="in_review">In Review</option>
                <option value="accepted">Accepted</option>
                <option value="rejected">Rejected</option>
              </select>
            </div>
            {loadingApplications && <p style={styles.infoText}>Loading applications...</p>}
            {applicationsError && <p style={styles.errorText}>{applicationsError}</p>}
            {!loadingApplications && candidateApplications.length === 0 && <div style={styles.emptyJobsBox}>You have not submitted any applications yet.</div>}
            {!loadingApplications && candidateApplications.length > 0 && filteredApplications.length === 0 && <div style={styles.emptyJobsBox}>No applications match this status.</div>}
            <div style={styles.applicationCards}>
              {filteredApplications.map((application) => (
                <div key={application.id} style={styles.applicationCard}>
                  {getCompanyLogoUrl(application) ? (
                    <div style={styles.applicationCompanyIcon}><img src={getCompanyLogoUrl(application)} alt={`${application.companyName || "Company"} logo`} style={styles.applicationCompanyLogoImage} /></div>
                  ) : (
                    <div style={styles.applicationCompanyIcon}><BuildingIcon size={31} /></div>
                  )}
                  <div style={styles.applicationInfo}>
                    <h3 style={styles.applicationJobTitle}>{application.jobTitle}</h3>
                    <button type="button" style={styles.applicationCompanyButton} onClick={() => { const relatedJob = jobs.find((job) => job.companyName === application.companyName || job.title === application.jobTitle) || application; openCompanyProfile(relatedJob); }}>
                      <CompanySmallIcon size={16} />{application.companyName}
                    </button>
                    <div style={styles.applicationMetaRow}>
                      <span style={styles.metaItem}><LocationIcon size={17} />{application.location || "Location not specified"}</span>
                      <span style={styles.metaItem}><JobTypeIcon size={17} />{application.jobType || "Job application"}</span>
                      <span style={styles.metaItem}><CalendarIcon size={17} />Applied on {application.createdAt ? new Date(application.createdAt).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }) : "Not specified"}</span>
                    </div>
                  </div>
                  <span style={getStatusBadgeStyle(application.status)}>{getStatusLabel(application.status)}</span>
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
            <button type="button" style={styles.companyCloseButton} onClick={() => setSelectedCompany(null)}>×</button>
            <div style={styles.companyModalHeader}>
              <CompanyLogo item={selectedCompany} size="large" />
              <div>
                <h2 style={styles.companyModalTitle}>{selectedCompany.employerProfile?.companyName || selectedCompany.companyName || "Company Profile"}</h2>
                <p style={styles.companyModalSubtitle}>{selectedCompany.employerProfile?.industry || "Hospitality"}{selectedCompany.employerProfile?.location ? ` · ${selectedCompany.employerProfile.location}` : selectedCompany.location ? ` · ${selectedCompany.location}` : ""}</p>
              </div>
            </div>
            <div style={styles.companyTabs}>
              {["PROFILE", "JOBS"].map((t) => (
                <button key={t} type="button" style={{ ...styles.companyTabButton, ...(companyModalTab === t ? styles.companyTabActive : {}) }} onClick={() => setCompanyModalTab(t)}>
                  {t === "PROFILE" ? "Profile" : "Job Openings"}
                </button>
              ))}
            </div>
            {companyModalTab === "PROFILE" && (
              <div style={styles.companyProfileContent}>
                <div style={styles.companyInfoBox}><h3 style={styles.companyInfoTitle}>About</h3><p style={styles.companyInfoText}>{selectedCompanyProfile.description || "No company description has been added yet."}</p></div>
                <div style={styles.companyInfoBox}><h3 style={styles.companyInfoTitle}>Accessibility Statement</h3><p style={styles.companyInfoText}>{selectedCompanyProfile.accessibilityStatement || "No accessibility statement has been added yet."}</p></div>
                <div style={styles.companyMiniGrid}>
                  <div style={styles.companyMiniBox}><strong>Location</strong><span>{selectedCompanyProfile.location || selectedCompany.location || "Not specified"}</span></div>
                  <div style={styles.companyMiniBox}><strong>Website</strong>{selectedCompanyProfile.website ? (<a href={selectedCompanyProfile.website.startsWith("http") ? selectedCompanyProfile.website : `https://${selectedCompanyProfile.website}`} target="_blank" rel="noreferrer" style={styles.companyWebsiteLink}>{selectedCompanyProfile.website}</a>) : (<span>Not specified</span>)}</div>
                  <div style={styles.companyMiniBox}><strong>Open Jobs</strong><span>{companyJobs.length}</span></div>
                </div>
              </div>
            )}
            {companyModalTab === "JOBS" && (
              <div style={styles.companyJobsList}>
                {companyJobs.length === 0 && <div style={styles.emptyJobsBox}>No open jobs are currently available for this company.</div>}
                {companyJobs.map((job) => (
                  <div key={job.id} style={styles.companyJobCard}>
                    <div><h3 style={styles.companyJobTitle}>{job.title}</h3><p style={styles.companyJobMeta}>{job.location} · {job.jobType} · {job.workMode}</p></div>
                    <button type="button" style={styles.companyApplyButton} onClick={() => openJobFromCompany(job)}>View & Apply</button>
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
  page: { minHeight: "100vh", background: "#f0f4ff", color: "#0f172a", fontFamily: '"Inter", "SF Pro Display", -apple-system, BlinkMacSystemFont, sans-serif', WebkitFontSmoothing: "antialiased" },
  header: { background: "linear-gradient(135deg, #1e40af 0%, #2563eb 50%, #3b82f6 100%)", padding: "28px 54px", display: "flex", justifyContent: "space-between", alignItems: "center", boxShadow: "0 4px 24px rgba(37,99,235,0.25)" },
  logo: { margin: 0, fontSize: "28px", fontWeight: "800", color: "#ffffff", letterSpacing: "-0.5px" },
  headerSubtitle: { margin: "8px 0 0", color: "#bfdbfe", fontSize: "15px", fontWeight: "500" },
  userBox: { display: "flex", alignItems: "center", gap: "12px" },
  userAvatar: { width: "48px", height: "48px", borderRadius: "50%", background: "rgba(255,255,255,0.2)", backdropFilter: "blur(8px)", border: "2px solid rgba(255,255,255,0.4)", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "15px", fontWeight: "800" },
  userName: { margin: 0, color: "#ffffff", fontSize: "15px", fontWeight: "800" },
  userRole: { margin: "4px 0 0", color: "#bfdbfe", fontSize: "13px" },
  logoutTextButton: { marginLeft: "8px", border: "1px solid rgba(255,255,255,0.3)", background: "rgba(255,255,255,0.1)", color: "#fff", cursor: "pointer", fontSize: "13px", fontWeight: "700", padding: "8px 14px", borderRadius: "8px", backdropFilter: "blur(4px)" },
  tabs: { background: "#ffffff", padding: "0 54px", display: "flex", gap: "8px", borderBottom: "1px solid #e2e8f0", boxShadow: "0 1px 8px rgba(0,0,0,0.04)" },
  tabButton: { background: "transparent", border: "none", padding: "18px 16px", cursor: "pointer", fontSize: "14px", fontWeight: "600", color: "#64748b", borderBottom: "3px solid transparent", transition: "all 0.2s ease", borderRadius: 0 },
  activeTab: { color: "#2563eb", borderBottom: "3px solid #2563eb", fontWeight: "800" },
  main: { padding: "28px 30px" },

  // Step indicator
  stepRow: { display: "flex", alignItems: "center", justifyContent: "center", marginBottom: "28px", gap: "0" },
  stepItem: { display: "flex", alignItems: "center", gap: "8px" },
  stepCircle: { width: "32px", height: "32px", borderRadius: "50%", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "13px", fontWeight: "800", transition: "all 0.3s ease", flexShrink: 0 },
  stepLabel: { fontSize: "13px", fontWeight: "700", whiteSpace: "nowrap" },
  stepLine: { width: "60px", height: "2px", background: "#e2e8f0", margin: "0 8px" },

  profileGrid: { display: "grid", gridTemplateColumns: "1.3fr 0.7fr", gap: "24px" },

  card: { background: "#ffffff", borderRadius: "24px", padding: "32px", boxShadow: "0 4px 24px rgba(15,23,42,0.06)", border: "1px solid #e8edf5" },
  cardHeader: { display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "20px" },
  sectionTitle: { margin: "0 0 6px", fontSize: "22px", fontWeight: "800", color: "#0f172a", letterSpacing: "-0.3px" },
  text: { color: "#64748b", fontSize: "14px", lineHeight: "1.6", margin: 0 },

  selectedCountBadge: { background: "linear-gradient(135deg, #2563eb, #3b82f6)", borderRadius: "16px", padding: "10px 16px", textAlign: "center", minWidth: "64px", boxShadow: "0 4px 12px rgba(37,99,235,0.3)" },
  selectedCountNumber: { display: "block", fontSize: "24px", fontWeight: "900", color: "#fff", lineHeight: "1" },
  selectedCountLabel: { display: "block", fontSize: "10px", fontWeight: "700", color: "#bfdbfe", textTransform: "uppercase", letterSpacing: "0.5px" },

  searchWrapper: { position: "relative", marginBottom: "16px" },
  searchIcon: { position: "absolute", left: "14px", top: "50%", transform: "translateY(-50%)", fontSize: "14px" },
  searchInput: { width: "100%", padding: "12px 14px 12px 40px", borderRadius: "12px", border: "1.5px solid #e2e8f0", fontSize: "14px", outline: "none", boxSizing: "border-box", background: "#f8fafc", transition: "border-color 0.2s", fontFamily: "inherit" },

  selectedChipsRow: { display: "flex", flexWrap: "wrap", gap: "6px", marginBottom: "16px", alignItems: "center" },
  selectedChip: { display: "inline-flex", alignItems: "center", gap: "6px", background: "#eff6ff", color: "#2563eb", padding: "5px 10px", borderRadius: "999px", fontSize: "12px", fontWeight: "700", border: "1px solid #bfdbfe" },
  chipRemove: { background: "none", border: "none", color: "#2563eb", cursor: "pointer", fontSize: "14px", fontWeight: "900", padding: "0", lineHeight: "1" },
  resetBtn: { background: "none", border: "1px solid #e2e8f0", color: "#94a3b8", cursor: "pointer", fontSize: "11px", fontWeight: "700", padding: "5px 10px", borderRadius: "999px" },

  disabilityGrid: { display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: "14px" },
  disabilityCard: { position: "relative", border: "1.5px solid #e5e7eb", background: "#f9fafb", borderRadius: "16px", padding: "12px", cursor: "pointer", minHeight: "220px", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "space-between", transition: "all 0.2s ease", outline: "none" },
  selectedDisabilityCard: { border: "2px solid #2563eb", background: "linear-gradient(135deg, #eff6ff, #dbeafe)", boxShadow: "0 8px 24px rgba(37,99,235,0.18)", transform: "translateY(-2px)" },
  selectedCheck: { position: "absolute", top: "10px", right: "10px", width: "22px", height: "22px", borderRadius: "50%", background: "#2563eb", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "11px", fontWeight: "900" },
  imageWrapper: { width: "100%", height: "160px", background: "#ffffff", borderRadius: "12px", display: "flex", alignItems: "center", justifyContent: "center", overflow: "hidden" },
  disabilityImage: { width: "100%", height: "100%", objectFit: "contain" },
  disabilityName: { marginTop: "8px", fontSize: "13px", fontWeight: "800", textAlign: "center" },

  saveRow: { display: "flex", alignItems: "center", gap: "16px", marginTop: "24px", flexWrap: "wrap" },
  saveButton: { border: "none", background: "linear-gradient(135deg, #1d4ed8, #2563eb)", color: "#ffffff", padding: "12px 24px", borderRadius: "12px", cursor: "pointer", fontWeight: "800", fontSize: "14px", boxShadow: "0 4px 14px rgba(37,99,235,0.3)", transition: "all 0.2s ease" },
  successText: { color: "#16a34a", fontWeight: "700", fontSize: "14px", margin: 0 },
  errorText: { color: "#dc2626", fontWeight: "700", fontSize: "14px", margin: 0 },
  infoText: { color: "#64748b", fontWeight: "600", fontSize: "14px" },

  // AI Card
  aiCard: { background: "#ffffff", borderRadius: "24px", padding: "28px", boxShadow: "0 4px 24px rgba(15,23,42,0.06)", border: "1px solid #e8edf5", position: "relative", overflow: "hidden" },
  aiCardHeader: { display: "flex", alignItems: "center", gap: "14px", marginBottom: "16px" },
  aiIconWrapper: { width: "48px", height: "48px", borderRadius: "14px", background: "linear-gradient(135deg, #2563eb, #3b82f6)", display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 4px 12px rgba(37,99,235,0.3)", flexShrink: 0 },
  aiTitle: { margin: 0, fontSize: "20px", fontWeight: "900", color: "#0f172a" },
  aiSubtitle: { margin: "2px 0 0", fontSize: "12px", color: "#64748b", fontWeight: "600" },
  aiDescription: { color: "#64748b", fontSize: "13px", lineHeight: "1.6", marginBottom: "20px" },
  aiButton: { width: "100%", border: "none", background: "linear-gradient(135deg, #1d4ed8, #2563eb, #3b82f6)", color: "#ffffff", padding: "14px", borderRadius: "14px", cursor: "pointer", fontWeight: "800", fontSize: "15px", boxShadow: "0 6px 20px rgba(37,99,235,0.35)", transition: "all 0.2s ease", letterSpacing: "0.2px" },
  aiErrorBox: { marginTop: "12px", background: "#fef2f2", border: "1px solid #fecaca", borderRadius: "10px", padding: "12px", color: "#dc2626", fontSize: "13px", fontWeight: "600" },
  aiResultsHeader: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "14px" },
  aiResultsTitle: { fontSize: "15px", fontWeight: "800", color: "#0f172a" },
  aiResultsSubtitle: { fontSize: "12px", color: "#64748b", fontWeight: "600" },
  aiEmptyState: { textAlign: "center", padding: "40px 20px" },
  aiEmptyIcon: { fontSize: "40px", marginBottom: "12px" },
  aiEmptyText: { color: "#94a3b8", fontSize: "13px", fontWeight: "600", lineHeight: "1.5", margin: 0 },

  jobsGrid: { marginTop: "24px", display: "grid", gridTemplateColumns: "repeat(3, minmax(0, 1fr))", gap: "18px" },
  jobCard: { border: "1px solid #e5e7eb", background: "#ffffff", borderRadius: "18px", padding: "18px", cursor: "pointer", textAlign: "left", display: "flex", gap: "14px", alignItems: "center", transition: "all 0.2s ease" },
  companyLogo: { width: "54px", height: "54px", borderRadius: "14px", background: "#eff6ff", color: "#2563eb", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: "800", fontSize: "22px", flexShrink: 0, overflow: "hidden" },
  companyLogoImage: { width: "100%", height: "100%", objectFit: "cover" },
  jobCardContent: { minWidth: 0 },
  jobTitle: { margin: "0 0 6px", fontSize: "18px", color: "#0f172a", fontWeight: "800" },
  companyNameButton: { color: "#64748b", fontSize: "14px", fontWeight: "700", textDecoration: "underline", textUnderlineOffset: "3px", cursor: "pointer" },
  companyNameLink: { border: "none", background: "transparent", padding: 0, margin: 0, color: "#2563eb", fontSize: "16px", fontWeight: "800", textDecoration: "underline", textUnderlineOffset: "4px", cursor: "pointer" },
  companyWebsiteLink: { color: "#2563eb", fontWeight: "800", textDecoration: "underline", textUnderlineOffset: "4px", wordBreak: "break-word" },
  emptyJobsBox: { marginTop: "20px", border: "2px dashed #d1d5db", borderRadius: "16px", padding: "30px", textAlign: "center", color: "#64748b", fontWeight: "700" },
  backButton: { border: "none", background: "#eff6ff", color: "#2563eb", padding: "10px 14px", borderRadius: "12px", cursor: "pointer", fontWeight: "800", marginBottom: "22px" },
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
  applicationsShell: { background: "#ffffff", borderRadius: "24px", padding: "36px", boxShadow: "0 4px 24px rgba(15,23,42,0.06)", border: "1px solid #e8edf5" },
  applicationsHeader: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "30px" },
  applicationsHeaderLeft: { display: "flex", alignItems: "center", gap: "18px" },
  applicationsIcon: { width: "52px", height: "52px", borderRadius: "14px", background: "#eff6ff", color: "#2563eb", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 },
  applicationsTitle: { margin: 0, fontSize: "28px", fontWeight: "800", color: "#071936" },
  applicationsSubtitle: { margin: "8px 0 0", color: "#64748b", fontSize: "15px" },
  statusFilterSelect: { border: "1px solid #dfe5ef", background: "#ffffff", color: "#475569", padding: "12px 16px", borderRadius: "9px", fontSize: "15px", fontWeight: "700", cursor: "pointer", outline: "none", minWidth: "132px", height: "50px" },
  applicationCards: { display: "flex", flexDirection: "column", gap: "16px" },
  applicationCard: { border: "1px solid #dfe7f1", borderRadius: "18px", padding: "28px 32px", background: "#ffffff", display: "flex", alignItems: "center", gap: "24px", boxShadow: "0 2px 12px rgba(15,23,42,0.04)" },
  applicationCompanyIcon: { width: "60px", height: "60px", borderRadius: "16px", background: "#eff4fb", color: "#2563eb", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, overflow: "hidden" },
  applicationCompanyLogoImage: { width: "100%", height: "100%", objectFit: "cover" },
  applicationInfo: { flex: 1, textAlign: "left", minWidth: 0 },
  applicationJobTitle: { margin: "0 0 8px", fontSize: "18px", fontWeight: "800", color: "#071936" },
  applicationCompanyButton: { border: "none", background: "transparent", margin: "0 0 16px", padding: 0, color: "#64748b", fontSize: "14px", fontWeight: "700", display: "flex", alignItems: "center", gap: "8px", cursor: "pointer", textDecoration: "underline", textUnderlineOffset: "3px" },
  applicationMetaRow: { display: "flex", flexWrap: "wrap", alignItems: "center", gap: "20px", color: "#64748b", fontSize: "13px", fontWeight: "600" },
  metaItem: { display: "inline-flex", alignItems: "center", gap: "6px", color: "#64748b", whiteSpace: "nowrap" },
  applicationStatusBadge: { padding: "8px 16px", borderRadius: "999px", fontSize: "13px", fontWeight: "800", textTransform: "capitalize", whiteSpace: "nowrap" },
  applicationArrow: { color: "#94a3b8", fontSize: "28px", fontWeight: "300", lineHeight: 1 },
  companyOverlay: { position: "fixed", inset: 0, background: "rgba(15,23,42,0.55)", display: "flex", alignItems: "center", justifyContent: "center", padding: "24px", zIndex: 999, backdropFilter: "blur(4px)" },
  companyModal: { width: "900px", maxWidth: "95vw", maxHeight: "88vh", overflowY: "auto", background: "#ffffff", borderRadius: "24px", padding: "30px", boxShadow: "0 24px 70px rgba(15,23,42,0.28)", position: "relative" },
  companyCloseButton: { position: "absolute", top: "18px", right: "20px", width: "36px", height: "36px", borderRadius: "999px", border: "none", background: "#f1f5f9", color: "#0f172a", fontSize: "24px", fontWeight: "800", cursor: "pointer" },
  companyModalHeader: { display: "flex", alignItems: "center", gap: "18px", paddingRight: "46px" },
  companyModalTitle: { margin: 0, color: "#071936", fontSize: "26px", fontWeight: "900" },
  companyModalSubtitle: { margin: "6px 0 0", color: "#64748b", fontSize: "14px", fontWeight: "700" },
  companyTabs: { display: "flex", gap: "18px", borderBottom: "1px solid #e5e7eb", marginTop: "24px" },
  companyTabButton: { border: "none", background: "transparent", padding: "14px 0", color: "#64748b", fontWeight: "800", fontSize: "14px", cursor: "pointer", borderBottom: "2px solid transparent" },
  companyTabActive: { color: "#2563eb", borderBottom: "2px solid #2563eb" },
  companyProfileContent: { marginTop: "24px", display: "flex", flexDirection: "column", gap: "14px" },
  companyInfoBox: { background: "#f8fafc", border: "1px solid #e5e7eb", borderRadius: "16px", padding: "18px" },
  companyInfoTitle: { margin: "0 0 8px", color: "#0f172a", fontSize: "16px", fontWeight: "900" },
  companyInfoText: { margin: 0, color: "#64748b", lineHeight: "1.7", fontWeight: "600" },
  companyMiniGrid: { display: "grid", gridTemplateColumns: "repeat(3, minmax(0, 1fr))", gap: "12px" },
  companyMiniBox: { background: "#ffffff", border: "1px solid #e5e7eb", borderRadius: "14px", padding: "14px", display: "flex", flexDirection: "column", gap: "6px", color: "#64748b", fontWeight: "700", fontSize: "14px" },
  companyJobsList: { marginTop: "24px", display: "flex", flexDirection: "column", gap: "12px" },
  companyJobCard: { border: "1px solid #e5e7eb", borderRadius: "16px", padding: "16px", display: "flex", justifyContent: "space-between", alignItems: "center", gap: "16px", background: "#f8fafc" },
  companyJobTitle: { margin: "0 0 6px", color: "#0f172a", fontSize: "16px", fontWeight: "900" },
  companyJobMeta: { margin: 0, color: "#64748b", fontSize: "13px", fontWeight: "700" },
  companyApplyButton: { border: "none", background: "#2563eb", color: "#ffffff", padding: "10px 16px", borderRadius: "999px", cursor: "pointer", fontWeight: "900", whiteSpace: "nowrap", fontSize: "13px" },
};

export default CandidateDashboard;
