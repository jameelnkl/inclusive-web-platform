import { useEffect, useState } from "react";
import {
  createEmployerJob,
  getEmployerJobs,
  updateEmployerJob,
  deleteEmployerJob,
  getEmployerApplications,
  updateApplicationStatus,
  deleteEmployerApplication,
  updateEmployerProfile,
  getEmployerProfile,
  getToken,
} from "../services/authService";

const API_BASE_URL = "https://fyp-backend-cbaa.onrender.com/api";
const BACKEND_BASE_URL = "https://fyp-backend-cbaa.onrender.com";

const emptyForm = {
  title: "",
  companyName: "",
  location: "",
  jobType: "Full-time",
  workMode: "On-site",
  description: "",
  requirements: "",
  applicationDeadline: "",
  cvRequired: true,
  coverLetterRequired: false,
};

const emptyTask = {
  taskName: "",
  description: "",
  requiredAbilitiesText: "",
};

const emptyEmployerProfile = {
  companyName: "",
  industry: "",
  location: "",
  website: "",
  description: "",
  accessibilityStatement: "",
};

function EmployerDashboard() {
  const [activeTab, setActiveTab] = useState("POST_JOB");
  const [formData, setFormData] = useState(emptyForm);
  const [tasks, setTasks] = useState([emptyTask]);
  const [editingJobId, setEditingJobId] = useState(null);

  const [myJobs, setMyJobs] = useState([]);
  const [applications, setApplications] = useState([]);

  const [employerProfile, setEmployerProfile] = useState(emptyEmployerProfile);
  const [logoFile, setLogoFile] = useState(null);
  const [logoPreview, setLogoPreview] = useState("");

  const [loading, setLoading] = useState(false);
  const [loadingJobs, setLoadingJobs] = useState(false);
  const [loadingApplications, setLoadingApplications] = useState(false);
  const [loadingProfile, setLoadingProfile] = useState(false);

  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [selectedProfile, setSelectedProfile] = useState(null);

  useEffect(() => {
    if (activeTab === "MY_JOBS") {
      fetchMyJobs();
    }

    if (activeTab === "APPLICATIONS") {
      fetchApplications();
    }

    if (activeTab === "PROFILE") {
      fetchEmployerProfile();
    }
  }, [activeTab]);

  function switchTab(tab) {
    setMessage("");
    setError("");
    setActiveTab(tab);
  }

  async function fetchMyJobs() {
    try {
      setLoadingJobs(true);
      setError("");

      const data = await getEmployerJobs();
      setMyJobs(data.jobs || []);
    } catch (err) {
      setError(err.message || "Failed to load jobs.");
    } finally {
      setLoadingJobs(false);
    }
  }

  async function fetchApplications() {
    try {
      setLoadingApplications(true);
      setError("");

      const data = await getEmployerApplications();
      setApplications(data.applications || []);
    } catch (err) {
      setError(err.message || "Failed to load applications.");
    } finally {
      setLoadingApplications(false);
    }
  }

  async function fetchEmployerProfile() {
    try {
      setLoadingProfile(true);
      setError("");

      const data = await getEmployerProfile();

      if (data.profile) {
        setEmployerProfile({
          companyName: data.profile.companyName || "",
          industry: data.profile.industry || "",
          location: data.profile.location || "",
          website: data.profile.website || "",
          description: data.profile.description || "",
          accessibilityStatement: data.profile.accessibilityStatement || "",
        });

        setLogoPreview(data.profile.logoUrl || "");
      }
    } catch (err) {
      setError(err.message || "Failed to load employer profile.");
    } finally {
      setLoadingProfile(false);
    }
  }

  function resetForm() {
    setFormData(emptyForm);
    setTasks([emptyTask]);
    setEditingJobId(null);
  }

  function handleChange(e) {
    const { name, value, type, checked } = e.target;

    setFormData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  }

  function handleProfileChange(e) {
    const { name, value } = e.target;

    setEmployerProfile((prev) => ({
      ...prev,
      [name]: value,
    }));
  }

  function handleLogoChange(e) {
    const file = e.target.files?.[0];

    if (!file) return;

    setLogoFile(file);
    setLogoPreview(URL.createObjectURL(file));
  }

  async function handleSaveProfile() {
    try {
      setLoading(true);
      setError("");
      setMessage("");

      const profileFormData = new FormData();

      profileFormData.append("companyName", employerProfile.companyName);
      profileFormData.append("industry", employerProfile.industry);
      profileFormData.append("location", employerProfile.location);
      profileFormData.append("website", employerProfile.website);
      profileFormData.append("description", employerProfile.description);
      profileFormData.append(
        "accessibilityStatement",
        employerProfile.accessibilityStatement
      );

      if (logoFile) {
        profileFormData.append("logo", logoFile);
      }

      const data = await updateEmployerProfile(profileFormData);

      if (data.profile) {
        setEmployerProfile({
          companyName: data.profile.companyName || "",
          industry: data.profile.industry || "",
          location: data.profile.location || "",
          website: data.profile.website || "",
          description: data.profile.description || "",
          accessibilityStatement: data.profile.accessibilityStatement || "",
        });

        setLogoPreview(data.profile.logoUrl || "");
        setLogoFile(null);
      }

      setMessage("Employer profile updated successfully.");
    } catch (err) {
      setError(err.message || "Failed to save employer profile.");
    } finally {
      setLoading(false);
    }
  }

  function handleTaskChange(index, field, value) {
    setTasks((prev) =>
      prev.map((task, i) => (i === index ? { ...task, [field]: value } : task))
    );
  }

  function addTask() {
    setTasks((prev) => [...prev, emptyTask]);
  }

  function removeTask(index) {
    setTasks((prev) => prev.filter((_, i) => i !== index));
  }

  function buildPayload() {
    const cleanTasks = tasks
      .filter((task) => task.taskName.trim() !== "")
      .map((task) => ({
        taskName: task.taskName.trim(),
        description: task.description.trim(),
        feasibilityLevel: "not_calculated",
        requiredAbilities: task.requiredAbilitiesText
          .split(",")
          .map((ability) => ability.trim())
          .filter(Boolean),
      }));

    if (cleanTasks.length === 0) {
      throw new Error("Please add at least one task.");
    }

    return {
      ...formData,
      category: formData.title,
      tasks: cleanTasks,
    };
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setMessage("");
    setError("");

    try {
      const payload = buildPayload();

      setLoading(true);

      if (editingJobId) {
        await updateEmployerJob(editingJobId, payload);
        setMessage("Job updated successfully.");
      } else {
        await createEmployerJob(payload);
        setMessage("Job posted successfully.");
      }

      resetForm();
      setActiveTab("MY_JOBS");
      await fetchMyJobs();
    } catch (err) {
      setError(err.message || "Failed to save job.");
    } finally {
      setLoading(false);
    }
  }

  function handleEditJob(job) {
    setMessage("");
    setError("");
    setEditingJobId(job.id);

    setFormData({
      title: job.title || "",
      companyName: job.companyName || "",
      location: job.location || "",
      jobType: job.jobType || "Full-time",
      workMode: job.workMode || "On-site",
      description: job.description || "",
      requirements: job.requirements || "",
      applicationDeadline: job.applicationDeadline || "",
      cvRequired: Boolean(job.cvRequired),
      coverLetterRequired: Boolean(job.coverLetterRequired),
    });

    setTasks(
      job.tasks?.length
        ? job.tasks.map((task) => ({
            taskName: task.taskName || "",
            description: task.description || "",
            requiredAbilitiesText: (task.requiredAbilities || []).join(", "),
          }))
        : [emptyTask]
    );

    setActiveTab("POST_JOB");
  }

  async function handleDeleteJob(jobId) {
    const confirmed = window.confirm("Are you sure you want to delete this job?");

    if (!confirmed) return;

    try {
      setError("");
      setMessage("");

      await deleteEmployerJob(jobId);
      setMessage("Job deleted successfully.");
      await fetchMyJobs();
    } catch (err) {
      setError(err.message || "Failed to delete job.");
    }
  }

  async function handleStatusChange(applicationId, newStatus) {
    try {
      setError("");
      setMessage("");

      await updateApplicationStatus(applicationId, newStatus);

      setApplications((prev) =>
        prev.map((application) =>
          application.id === applicationId
            ? { ...application, status: newStatus }
            : application
        )
      );
    } catch (err) {
      setError(err.message || "Failed to update application status.");
    }
  }

  async function handleDeleteApplication(applicationId) {
    const confirmed = window.confirm(
      "Are you sure you want to remove this application?"
    );

    if (!confirmed) return;

    try {
      setError("");
      setMessage("");

      await deleteEmployerApplication(applicationId);

      setApplications((prev) =>
        prev.filter((application) => application.id !== applicationId)
      );

      setMessage("Application removed successfully.");

      setTimeout(() => {
        setMessage("");
      }, 3000);
    } catch (err) {
      setError(err.message || "Failed to delete application.");
    }
  }

  function handleViewProfile(application) {
    setSelectedProfile({
      name: application.candidateName,
      email: application.candidateEmail,
      selectedDisabilities: application.candidateSelectedDisabilities || [],
      remainingAbilities: application.candidateRemainingAbilities || [],
    });
  }

  async function fetchFileBlob(applicationId, type) {
    const token = getToken();

    const response = await fetch(
      `${API_BASE_URL}/employer/applications/${applicationId}/download/${type}`,
      {
        method: "GET",
        headers: {
          "X-Auth-Token": token,
        },
      }
    );

    if (!response.ok) {
      const data = await response.json().catch(() => ({}));
      throw new Error(data.message || "Failed to load file.");
    }

    return response.blob();
  }

  async function handleView(applicationId, type) {
    try {
      setError("");

      const blob = await fetchFileBlob(applicationId, type);
      const url = window.URL.createObjectURL(blob);

      window.open(url, "_blank");
    } catch (err) {
      setError(err.message || "Failed to view file.");
    }
  }

  async function handleDownload(applicationId, type, fallbackName) {
    try {
      setError("");

      const blob = await fetchFileBlob(applicationId, type);
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement("a");

      link.href = url;
      link.download = fallbackName || `${type}-document`;
      document.body.appendChild(link);
      link.click();
      link.remove();

      window.URL.revokeObjectURL(url);
    } catch (err) {
      setError(err.message || "Failed to download file.");
    }
  }

  function getLogoSrc() {
    if (!logoPreview) return "";

    if (logoPreview.startsWith("blob:")) {
      return logoPreview;
    }

    if (logoPreview.startsWith("/uploads")) {
      return `${BACKEND_BASE_URL}${logoPreview}`;
    }

    return logoPreview;
  }

  return (
    <div style={styles.page}>
      <aside style={styles.sidebar}>
        <h2 style={styles.logo}>Employer Panel</h2>

        <button
          style={activeTab === "POST_JOB" ? styles.activeTab : styles.tab}
          onClick={() => {
            resetForm();
            switchTab("POST_JOB");
          }}
        >
          Post a Job
        </button>

        <button
          style={activeTab === "MY_JOBS" ? styles.activeTab : styles.tab}
          onClick={() => switchTab("MY_JOBS")}
        >
          My Jobs
        </button>

        <button
          style={activeTab === "APPLICATIONS" ? styles.activeTab : styles.tab}
          onClick={() => switchTab("APPLICATIONS")}
        >
          Applications
        </button>

        <button
          style={activeTab === "PROFILE" ? styles.activeTab : styles.tab}
          onClick={() => switchTab("PROFILE")}
        >
          Company Profile
        </button>
      </aside>

      <main style={styles.main}>
        <h1 style={styles.title}>EMPLOYER DASHBOARD</h1>

        {message && <p style={styles.success}>{message}</p>}
        {error && <p style={styles.error}>{error}</p>}

        {activeTab === "POST_JOB" && (
          <form onSubmit={handleSubmit} style={styles.card}>
            <h2 style={styles.sectionTitle}>
              {editingJobId ? "EDIT JOB" : "POST A JOB"}
            </h2>

            <p style={styles.note}>
              Fields marked with * are required. Your company logo is managed
              from the Company Profile tab.
            </p>

            <div style={styles.grid}>
              <Field label="Job title *">
                <input
                  style={styles.input}
                  name="title"
                  value={formData.title}
                  onChange={handleChange}
                  required
                />
              </Field>

              <Field label="Company name *">
                <input
                  style={styles.input}
                  name="companyName"
                  value={formData.companyName}
                  onChange={handleChange}
                  required
                />
              </Field>

              <Field label="Location *">
                <input
                  style={styles.input}
                  name="location"
                  value={formData.location}
                  onChange={handleChange}
                  required
                />
              </Field>

              <Field label="Job type *">
                <select
                  style={styles.input}
                  name="jobType"
                  value={formData.jobType}
                  onChange={handleChange}
                  required
                >
                  <option>Full-time</option>
                  <option>Part-time</option>
                  <option>Internship</option>
                  <option>Seasonal</option>
                </select>
              </Field>

              <Field label="Work mode *">
                <select
                  style={styles.input}
                  name="workMode"
                  value={formData.workMode}
                  onChange={handleChange}
                  required
                >
                  <option>On-site</option>
                  <option>Hybrid</option>
                  <option>Remote</option>
                </select>
              </Field>

              <Field label="Application deadline *">
                <input
                  style={styles.input}
                  type="date"
                  name="applicationDeadline"
                  value={formData.applicationDeadline}
                  onChange={handleChange}
                  required
                />
              </Field>
            </div>

            <Field label="Job description *">
              <textarea
                style={styles.textarea}
                name="description"
                value={formData.description}
                onChange={handleChange}
                required
              />
            </Field>

            <Field label="Requirements">
              <textarea
                style={styles.textarea}
                name="requirements"
                value={formData.requirements}
                onChange={handleChange}
              />
            </Field>

            <div style={styles.checkboxRow}>
              <label style={styles.checkboxLabel}>
                <input
                  type="checkbox"
                  name="cvRequired"
                  checked={formData.cvRequired}
                  onChange={handleChange}
                />
                Application document required *
              </label>

              <label style={styles.checkboxLabel}>
                <input
                  type="checkbox"
                  name="coverLetterRequired"
                  checked={formData.coverLetterRequired}
                  onChange={handleChange}
                />
                Recommendation letter required
              </label>
            </div>

            <div style={styles.tasksHeader}>
              <div>
                <h3 style={styles.tasksTitle}>JOB TASKS *</h3>
                <p style={styles.note}>
                  Add the tasks the candidate may need to perform.
                </p>
              </div>

              <button type="button" style={styles.secondaryButton} onClick={addTask}>
                + Add Task
              </button>
            </div>

            <div style={styles.tasksContainer}>
              {tasks.map((task, index) => (
                <div key={index} style={styles.taskCard}>
                  <div style={styles.taskCardHeader}>
                    <h4 style={styles.taskNumber}>Task {index + 1}</h4>

                    {tasks.length > 1 && (
                      <button
                        type="button"
                        style={styles.removeButton}
                        onClick={() => removeTask(index)}
                      >
                        Remove
                      </button>
                    )}
                  </div>

                  <Field label="Task name *">
                    <input
                      style={styles.input}
                      value={task.taskName}
                      onChange={(e) =>
                        handleTaskChange(index, "taskName", e.target.value)
                      }
                      required
                    />
                  </Field>

                  <Field label="Task description">
                    <textarea
                      style={styles.smallTextarea}
                      value={task.description}
                      onChange={(e) =>
                        handleTaskChange(index, "description", e.target.value)
                      }
                    />
                  </Field>

                  <Field label="Required abilities">
                    <input
                      style={styles.input}
                      value={task.requiredAbilitiesText}
                      onChange={(e) =>
                        handleTaskChange(
                          index,
                          "requiredAbilitiesText",
                          e.target.value
                        )
                      }
                      placeholder="Example: Can work seated, Can use one hand"
                    />
                  </Field>
                </div>
              ))}
            </div>

            <button type="submit" style={styles.button} disabled={loading}>
              {loading ? "Saving..." : editingJobId ? "Update Job" : "Publish Job"}
            </button>

            {editingJobId && (
              <button type="button" style={styles.cancelButton} onClick={resetForm}>
                Cancel Edit
              </button>
            )}
          </form>
        )}

        {activeTab === "PROFILE" && (
          <section style={styles.card}>
            <h2 style={styles.sectionTitle}>COMPANY PROFILE</h2>

            <p style={styles.note}>
              Upload your company logo here. This profile is attached to your
              posted jobs.
            </p>

            {loadingProfile && (
              <p style={styles.loadingText}>Loading company profile...</p>
            )}

            <div style={styles.profileContainer}>
              <div style={styles.logoSection}>
                <div style={styles.logoPreviewBox}>
                  {getLogoSrc() ? (
                    <img
                      src={getLogoSrc()}
                      alt="Company logo"
                      style={styles.logoPreview}
                    />
                  ) : (
                    <div style={styles.logoPlaceholder}>Upload Logo</div>
                  )}
                </div>

                <label style={styles.uploadButton}>
                  Choose Image
                  <input
                    type="file"
                    accept="image/png,image/jpeg,image/webp,image/gif"
                    style={{ display: "none" }}
                    onChange={handleLogoChange}
                  />
                </label>

                <p style={styles.logoHelpText}>
                  PNG, JPG, WebP, or GIF. Max 3MB.
                </p>
              </div>

              <div style={styles.profileFields}>
                <div style={styles.grid}>
                  <Field label="Company Name">
                    <input
                      style={styles.input}
                      name="companyName"
                      value={employerProfile.companyName}
                      onChange={handleProfileChange}
                    />
                  </Field>

                  <Field label="Industry">
                    <input
                      style={styles.input}
                      name="industry"
                      value={employerProfile.industry}
                      onChange={handleProfileChange}
                    />
                  </Field>

                  <Field label="Location">
                    <input
                      style={styles.input}
                      name="location"
                      value={employerProfile.location}
                      onChange={handleProfileChange}
                    />
                  </Field>

                  <Field label="Website">
                    <input
                      style={styles.input}
                      name="website"
                      value={employerProfile.website}
                      onChange={handleProfileChange}
                    />
                  </Field>
                </div>

                <Field label="Company Description">
                  <textarea
                    style={styles.textarea}
                    name="description"
                    value={employerProfile.description}
                    onChange={handleProfileChange}
                  />
                </Field>

                <Field label="Accessibility Statement">
                  <textarea
                    style={styles.textarea}
                    name="accessibilityStatement"
                    value={employerProfile.accessibilityStatement}
                    onChange={handleProfileChange}
                  />
                </Field>

                <button
                  type="button"
                  style={styles.button}
                  onClick={handleSaveProfile}
                  disabled={loading}
                >
                  {loading ? "Saving..." : "Save Profile"}
                </button>
              </div>
            </div>
          </section>
        )}

        {activeTab === "MY_JOBS" && (
          <section style={styles.card}>
            <h2 style={styles.sectionTitle}>MY JOBS</h2>

            {loadingJobs && <p style={styles.loadingText}>Loading jobs...</p>}

            {!loadingJobs && myJobs.length === 0 && (
              <div style={styles.emptyBox}>You have not posted any jobs yet.</div>
            )}

            <div style={styles.jobsList}>
              {myJobs.map((job) => (
                <div key={job.id} style={styles.jobManageCard}>
                  <div>
                    <h3 style={styles.jobManageTitle}>{job.title}</h3>
                    <p style={styles.note}>
                      {job.companyName} · {job.location} · {job.jobType} ·{" "}
                      {job.workMode}
                    </p>
                    <p style={styles.note}>
                      Deadline: {job.applicationDeadline || "Not specified"}
                    </p>
                  </div>

                  <div style={styles.actionRow}>
                    <button style={styles.editButton} onClick={() => handleEditJob(job)}>
                      Edit
                    </button>

                    <button
                      style={styles.deleteButton}
                      onClick={() => handleDeleteJob(job.id)}
                    >
                      Delete
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </section>
        )}

        {activeTab === "APPLICATIONS" && (
          <section style={styles.card}>
            <h2 style={styles.sectionTitle}>APPLICATIONS</h2>

            {loadingApplications && (
              <p style={styles.loadingText}>Loading applications...</p>
            )}

            {!loadingApplications && applications.length === 0 && (
              <div style={styles.emptyBox}>
                No applications have been submitted yet.
              </div>
            )}

            {applications.length > 0 && (
              <div style={styles.tableWrapper}>
                <table style={styles.table}>
                  <thead>
                    <tr>
                      <th style={styles.th}>Candidate</th>
                      <th style={styles.th}>Job</th>
                      <th style={styles.th}>Profile</th>
                      <th style={styles.th}>Status</th>
                      <th style={styles.th}>Application</th>
                      <th style={styles.th}>Recommendation</th>
                      <th style={styles.th}>Action</th>
                    </tr>
                  </thead>

                  <tbody>
                    {applications.map((application) => (
                      <tr key={application.id}>
                        <td style={styles.td}>{application.candidateName}</td>
                        <td style={styles.td}>{application.jobTitle}</td>

                        <td style={styles.td}>
                          <button
                            style={styles.viewButton}
                            onClick={() => handleViewProfile(application)}
                          >
                            View Profile
                          </button>
                        </td>

                        <td style={styles.td}>
                          <select
                            style={styles.statusSelect}
                            value={application.status}
                            onChange={(e) =>
                              handleStatusChange(application.id, e.target.value)
                            }
                          >
                            <option value="pending">Pending</option>
                            <option value="in_review">In review</option>
                            <option value="accepted">Accepted</option>
                            <option value="rejected">Rejected</option>
                          </select>
                        </td>

                        <td style={styles.td}>
                          {application.hasApplicationDocument ? (
                            <div style={styles.fileActions}>
                              <button
                                style={styles.viewButton}
                                onClick={() =>
                                  handleView(application.id, "application")
                                }
                              >
                                View
                              </button>

                              <button
                                style={styles.downloadButton}
                                onClick={() =>
                                  handleDownload(
                                    application.id,
                                    "application",
                                    application.applicationOriginalName
                                  )
                                }
                              >
                                Download
                              </button>
                            </div>
                          ) : (
                            <span style={styles.mutedText}>Not provided</span>
                          )}
                        </td>

                        <td style={styles.td}>
                          {application.hasRecommendationLetter ? (
                            <div style={styles.fileActions}>
                              <button
                                style={styles.viewButton}
                                onClick={() =>
                                  handleView(application.id, "recommendation")
                                }
                              >
                                View
                              </button>

                              <button
                                style={styles.downloadButton}
                                onClick={() =>
                                  handleDownload(
                                    application.id,
                                    "recommendation",
                                    application.recommendationOriginalName
                                  )
                                }
                              >
                                Download
                              </button>
                            </div>
                          ) : (
                            <span style={styles.mutedText}>Not provided</span>
                          )}
                        </td>

                        <td style={styles.td}>
                          <button
                            style={styles.deleteButton}
                            onClick={() => handleDeleteApplication(application.id)}
                          >
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>
        )}

        {selectedProfile && (
          <div style={styles.modalOverlay}>
            <div style={styles.modal}>
              <button
                style={styles.closeButton}
                onClick={() => setSelectedProfile(null)}
              >
                ×
              </button>

              <h2 style={styles.modalTitle}>Candidate Profile</h2>

              <p style={styles.profileLine}>
                <strong>Name:</strong> {selectedProfile.name || "Not specified"}
              </p>

              <p style={styles.profileLine}>
                <strong>Email:</strong> {selectedProfile.email || "Not specified"}
              </p>

              <h3 style={styles.profileSubtitle}>Selected Disabilities</h3>

              <div style={styles.chipWrap}>
                {selectedProfile.selectedDisabilities.length > 0 ? (
                  selectedProfile.selectedDisabilities.map((item) => (
                    <span key={item} style={styles.profileChip}>
                      {item}
                    </span>
                  ))
                ) : (
                  <span style={styles.mutedText}>No disabilities selected.</span>
                )}
              </div>

              <h3 style={styles.profileSubtitle}>Remaining Abilities</h3>

              <div style={styles.chipWrap}>
                {selectedProfile.remainingAbilities.length > 0 ? (
                  selectedProfile.remainingAbilities.map((item) => (
                    <span key={item} style={styles.abilityChip}>
                      {item}
                    </span>
                  ))
                ) : (
                  <span style={styles.mutedText}>
                    No remaining abilities available yet.
                  </span>
                )}
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

function Field({ label, children }) {
  return (
    <label style={styles.label}>
      <span>{label}</span>
      {children}
    </label>
  );
}

const styles = {
  page: {
    display: "flex",
    minHeight: "100vh",
    background: "#f1f4f8",
    color: "#111827",
    fontFamily: "Inter, Arial, sans-serif",
  },
  sidebar: {
    width: "250px",
    background: "#111827",
    color: "white",
    padding: "36px 28px",
    boxSizing: "border-box",
  },
  logo: {
    fontSize: "25px",
    margin: "0 0 38px",
    fontWeight: "800",
  },
  tab: {
    display: "block",
    width: "100%",
    padding: "9px 0",
    marginBottom: "14px",
    border: "none",
    background: "transparent",
    color: "white",
    textAlign: "left",
    fontSize: "16px",
    cursor: "pointer",
  },
  activeTab: {
    display: "block",
    width: "100%",
    padding: "9px 0",
    marginBottom: "14px",
    border: "none",
    background: "transparent",
    color: "white",
    textAlign: "left",
    fontSize: "17px",
    fontWeight: "850",
    cursor: "pointer",
  },
  main: {
    flex: 1,
    padding: "38px 44px",
    boxSizing: "border-box",
  },
  title: {
    textAlign: "center",
    color: "#071a38",
    fontSize: "42px",
    letterSpacing: "2px",
    margin: "0 0 28px",
    fontWeight: "900",
  },
  card: {
    background: "white",
    borderRadius: "24px",
    padding: "34px",
    boxShadow: "0 18px 42px rgba(15, 23, 42, 0.09)",
  },
  sectionTitle: {
    textAlign: "center",
    color: "#071a38",
    fontSize: "34px",
    letterSpacing: "1px",
    margin: "0 0 8px",
    fontWeight: "900",
  },
  note: {
    color: "#667085",
    fontSize: "15px",
    margin: "0 0 20px",
  },
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(2, minmax(0, 1fr))",
    gap: "18px 24px",
  },
  label: {
    display: "flex",
    flexDirection: "column",
    gap: "9px",
    color: "#27364a",
    fontSize: "15px",
    fontWeight: "800",
    marginBottom: "20px",
  },
  input: {
    height: "52px",
    padding: "0 16px",
    borderRadius: "14px",
    border: "1px solid #d6dce6",
    background: "#fbfcfe",
    color: "#111827",
    fontSize: "15px",
    outline: "none",
    boxSizing: "border-box",
  },
  textarea: {
    minHeight: "110px",
    padding: "14px 16px",
    borderRadius: "14px",
    border: "1px solid #d6dce6",
    background: "#fbfcfe",
    color: "#111827",
    fontSize: "15px",
    resize: "vertical",
    outline: "none",
    boxSizing: "border-box",
  },
  smallTextarea: {
    minHeight: "82px",
    padding: "14px 16px",
    borderRadius: "14px",
    border: "1px solid #d6dce6",
    background: "#fbfcfe",
    color: "#111827",
    fontSize: "15px",
    resize: "vertical",
    outline: "none",
    boxSizing: "border-box",
  },
  checkboxRow: {
    display: "flex",
    gap: "24px",
    margin: "8px 0 28px",
    color: "#27364a",
    fontWeight: "800",
  },
  checkboxLabel: {
    display: "flex",
    alignItems: "center",
    gap: "8px",
  },
  tasksHeader: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginTop: "8px",
  },
  tasksTitle: {
    color: "#071a38",
    fontSize: "24px",
    margin: "0 0 6px",
    fontWeight: "900",
  },
  tasksContainer: {
    display: "grid",
    gridTemplateColumns: "repeat(2, minmax(0, 1fr))",
    gap: "18px",
  },
  taskCard: {
    border: "1px solid #e5eaf2",
    borderRadius: "20px",
    padding: "20px",
    background: "#f8fafc",
  },
  taskCardHeader: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: "14px",
  },
  taskNumber: {
    margin: 0,
    color: "#071a38",
    fontSize: "20px",
    fontWeight: "900",
  },
  secondaryButton: {
    padding: "12px 18px",
    border: "none",
    borderRadius: "999px",
    background: "#e8f0ff",
    color: "#1042a0",
    fontWeight: "900",
    cursor: "pointer",
  },
  removeButton: {
    border: "none",
    background: "#ffe1e1",
    color: "#b91c1c",
    padding: "8px 13px",
    borderRadius: "999px",
    fontWeight: "900",
    cursor: "pointer",
  },
  button: {
    display: "block",
    margin: "30px auto 0",
    padding: "15px 34px",
    border: "none",
    borderRadius: "999px",
    background: "#111827",
    color: "white",
    fontSize: "16px",
    fontWeight: "900",
    cursor: "pointer",
  },
  cancelButton: {
    display: "block",
    margin: "14px auto 0",
    padding: "12px 26px",
    border: "none",
    borderRadius: "999px",
    background: "#e5e7eb",
    color: "#111827",
    fontWeight: "900",
    cursor: "pointer",
  },
  success: {
    color: "#047857",
    fontWeight: "800",
    marginTop: "20px",
    textAlign: "center",
  },
  error: {
    color: "#b91c1c",
    fontWeight: "800",
    marginTop: "20px",
    textAlign: "center",
  },
  loadingText: {
    color: "#667085",
    fontWeight: "800",
    textAlign: "center",
  },
  emptyBox: {
    border: "2px dashed #d1d5db",
    borderRadius: "18px",
    padding: "28px",
    textAlign: "center",
    color: "#667085",
    fontWeight: "800",
  },
  jobsList: {
    display: "flex",
    flexDirection: "column",
    gap: "16px",
    marginTop: "24px",
  },
  jobManageCard: {
    border: "1px solid #e5eaf2",
    borderRadius: "18px",
    padding: "20px",
    background: "#f8fafc",
    display: "flex",
    justifyContent: "space-between",
    gap: "20px",
    alignItems: "center",
  },
  jobManageTitle: {
    margin: "0 0 8px",
    color: "#071a38",
    fontSize: "22px",
    fontWeight: "900",
  },
  actionRow: {
    display: "flex",
    gap: "10px",
  },
  editButton: {
    border: "none",
    background: "#e8f0ff",
    color: "#1042a0",
    padding: "10px 16px",
    borderRadius: "999px",
    fontWeight: "900",
    cursor: "pointer",
  },
  deleteButton: {
    border: "none",
    background: "#ffe1e1",
    color: "#b91c1c",
    padding: "10px 16px",
    borderRadius: "999px",
    fontWeight: "900",
    cursor: "pointer",
  },
  tableWrapper: {
    width: "100%",
    marginTop: "24px",
  },
  table: {
    width: "100%",
    borderCollapse: "collapse",
    fontSize: "15px",
  },
  th: {
    background: "#f8fafc",
    color: "#111827",
    textAlign: "center",
    padding: "18px 16px",
    borderBottom: "1px solid #e5e7eb",
    fontWeight: "900",
    fontSize: "13px",
    letterSpacing: "0.4px",
  },
  td: {
    padding: "24px 16px",
    borderBottom: "1px solid #e5e7eb",
    color: "#27364a",
    textAlign: "center",
    fontWeight: "700",
  },
  statusSelect: {
    padding: "9px 12px",
    borderRadius: "12px",
    border: "1px solid #d6dce6",
    background: "#fbfcfe",
    color: "#111827",
    fontWeight: "800",
    outline: "none",
  },
  fileActions: {
    display: "flex",
    justifyContent: "center",
    gap: "8px",
    flexWrap: "wrap",
  },
  viewButton: {
    border: "none",
    background: "#f3f4f6",
    color: "#111827",
    padding: "9px 13px",
    borderRadius: "999px",
    fontWeight: "900",
    cursor: "pointer",
  },
  downloadButton: {
    border: "none",
    background: "#e8f0ff",
    color: "#1042a0",
    padding: "9px 13px",
    borderRadius: "999px",
    fontWeight: "900",
    cursor: "pointer",
  },
  mutedText: {
    color: "#94a3b8",
    fontWeight: "800",
  },
  profileContainer: {
    display: "grid",
    gridTemplateColumns: "280px 1fr",
    gap: "34px",
    alignItems: "start",
    marginTop: "28px",
  },
  logoSection: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    gap: "18px",
  },
  logoPreviewBox: {
    width: "240px",
    height: "240px",
    borderRadius: "24px",
    background: "#f8fafc",
    border: "2px dashed #cbd5e1",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden",
  },
  logoPreview: {
    width: "100%",
    height: "100%",
    objectFit: "cover",
  },
  logoPlaceholder: {
    color: "#64748b",
    fontWeight: "900",
    fontSize: "18px",
  },
  uploadButton: {
    background: "#111827",
    color: "white",
    padding: "12px 22px",
    borderRadius: "999px",
    fontWeight: "900",
    cursor: "pointer",
  },
  logoHelpText: {
    color: "#667085",
    fontSize: "13px",
    fontWeight: "700",
    margin: 0,
    textAlign: "center",
  },
  profileFields: {
    display: "flex",
    flexDirection: "column",
  },
  modalOverlay: {
    position: "fixed",
    inset: 0,
    background: "rgba(15, 23, 42, 0.45)",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    zIndex: 999,
  },
  modal: {
    width: "520px",
    maxWidth: "90vw",
    background: "white",
    borderRadius: "24px",
    padding: "30px",
    boxShadow: "0 24px 60px rgba(15, 23, 42, 0.25)",
    position: "relative",
  },
  closeButton: {
    position: "absolute",
    top: "16px",
    right: "18px",
    border: "none",
    background: "#f3f4f6",
    color: "#111827",
    width: "34px",
    height: "34px",
    borderRadius: "999px",
    fontSize: "22px",
    fontWeight: "900",
    cursor: "pointer",
  },
  modalTitle: {
    margin: "0 0 18px",
    color: "#071a38",
    fontSize: "28px",
    fontWeight: "900",
    textAlign: "center",
  },
  profileLine: {
    color: "#27364a",
    fontSize: "15px",
    margin: "8px 0",
  },
  profileSubtitle: {
    color: "#071a38",
    fontSize: "18px",
    margin: "22px 0 10px",
    fontWeight: "900",
  },
  chipWrap: {
    display: "flex",
    flexWrap: "wrap",
    gap: "8px",
  },
  profileChip: {
    background: "#eef2ff",
    color: "#3730a3",
    padding: "7px 11px",
    borderRadius: "999px",
    fontSize: "13px",
    fontWeight: "800",
  },
  abilityChip: {
    background: "#ecfdf5",
    color: "#047857",
    padding: "7px 11px",
    borderRadius: "999px",
    fontSize: "13px",
    fontWeight: "800",
  },
};

export default EmployerDashboard;