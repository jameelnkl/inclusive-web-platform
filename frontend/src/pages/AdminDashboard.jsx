import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  getToken,
  logout,
  getAdminApplications,
  getAdminApplicationFileUrl,
} from "../services/authService";

function AdminDashboard() {
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState("USERS");
  const [hoveredTab, setHoveredTab] = useState(null);

  const [users, setUsers] = useState([]);
  const [candidateProfiles, setCandidateProfiles] = useState([]);
  const [adminApplications, setAdminApplications] = useState([]);
  const [selectedProfile, setSelectedProfile] = useState(null);
  const [showProfileApplications, setShowProfileApplications] = useState(false);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [searchTerm, setSearchTerm] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [verificationFilter, setVerificationFilter] = useState("");

  const [userToEdit, setUserToEdit] = useState(null);
  const [editFormData, setEditFormData] = useState({
    username: "",
    email: "",
    password: "",
  });
  const [editingUser, setEditingUser] = useState(false);
  const [showPasswordField, setShowPasswordField] = useState(false);

  const [userToArchive, setUserToArchive] = useState(null);
  const [archivingUser, setArchivingUser] = useState(false);

  const [userToDelete, setUserToDelete] = useState(null);
  const [deletingUser, setDeletingUser] = useState(false);

  const [actionLoadingId, setActionLoadingId] = useState(null);

  const isArchivedView = activeTab === "ARCHIVED_USERS";
  const isUserProfilesView = activeTab === "USER_PROFILES";
  const isApplicationsView = activeTab === "APPLICATIONS";

  async function fetchUsers(tab = activeTab) {
    try {
      setLoading(true);
      setError("");

      const token = getToken();

      if (!token) {
        navigate("/signin");
        return;
      }

      const endpoint =
        tab === "ARCHIVED_USERS"
          ? "https://fyp-backend-cbaa.onrender.com/api/admin/users/archived"
          : "https://fyp-backend-cbaa.onrender.com/api/admin/users";

      const response = await fetch(endpoint, {
        method: "GET",
        headers: {
          "X-Auth-Token": token,
        },
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Failed to load users.");
      }

      setUsers(data.users || []);
    } catch (err) {
      setError(err.message || "Something went wrong while loading users.");
    } finally {
      setLoading(false);
    }
  }

  async function fetchCandidateProfiles() {
    try {
      setLoading(true);
      setError("");

      const token = getToken();

      if (!token) {
        navigate("/signin");
        return;
      }

      const response = await fetch(
        "https://fyp-backend-cbaa.onrender.com/api/admin/candidate-profiles",
        {
          method: "GET",
          headers: {
            "X-Auth-Token": token,
          },
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Failed to load candidate profiles.");
      }

      setCandidateProfiles(data.profiles || []);
    } catch (err) {
      setError(err.message || "Something went wrong while loading candidate profiles.");
    } finally {
      setLoading(false);
    }
  }

  async function fetchAdminApplications() {
    try {
      setLoading(true);
      setError("");

      const data = await getAdminApplications();
      setAdminApplications(data.applications || []);
    } catch (err) {
      setError(err.message || "Something went wrong while loading applications.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (activeTab === "USER_PROFILES") {
      fetchCandidateProfiles();
      return;
    }

    if (activeTab === "APPLICATIONS") {
      fetchAdminApplications();
      return;
    }

    fetchUsers(activeTab);
  }, [activeTab]);

  function handleLogout() {
    logout();
    navigate("/signin");
  }

  function handleTabChange(tab) {
    setActiveTab(tab);
    setSearchTerm("");
    setRoleFilter("");
    setVerificationFilter("");
    setError("");
    setSelectedProfile(null);
    setShowProfileApplications(false);
  }

  function getNavStyle(tab) {
    const isActive = activeTab === tab;
    const isHovered = hoveredTab === tab;

    return {
      ...styles.navItem,
      ...(isActive ? styles.activeNavItem : {}),
      ...(isHovered && !isActive ? styles.hoveredNavItem : {}),
    };
  }

  function handleRoleFilterChange(e) {
    const value = e.target.value;

    if (value === "RESET") {
      setRoleFilter("");
      return;
    }

    setRoleFilter(value);
  }

  function handleVerificationFilterChange(e) {
    const value = e.target.value;

    if (value === "RESET") {
      setVerificationFilter("");
      return;
    }

    setVerificationFilter(value);
  }

  function openEditModal(user) {
    setUserToEdit(user);
    setEditFormData({
      username: user.username,
      email: user.email,
      password: "",
    });
    setShowPasswordField(false);
  }

  function handleEditFormChange(e) {
    setEditFormData({
      ...editFormData,
      [e.target.name]: e.target.value,
    });
  }

  async function handleEditUser(e) {
    e.preventDefault();

    if (!userToEdit) return;

    try {
      setEditingUser(true);
      setActionLoadingId(userToEdit.id);

      const token = getToken();

      if (!token) {
        navigate("/signin");
        return;
      }

      const response = await fetch(
        `https://fyp-backend-cbaa.onrender.com/api/admin/users/${userToEdit.id}`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            "X-Auth-Token": token,
          },
          body: JSON.stringify({
            username: editFormData.username,
            email: editFormData.email,
            password: showPasswordField ? editFormData.password : "",
          }),
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Failed to update user.");
      }

      setUsers((previousUsers) =>
        previousUsers.map((user) =>
          user.id === userToEdit.id ? data.user : user
        )
      );

      setUserToEdit(null);
      setEditFormData({
        username: "",
        email: "",
        password: "",
      });
      setShowPasswordField(false);

      if (data.emailVerificationRequired) {
        alert(
          "User updated successfully. Since the email changed, a new verification email was sent."
        );
      }
    } catch (err) {
      alert(err.message || "Something went wrong while updating the user.");
    } finally {
      setEditingUser(false);
      setActionLoadingId(null);
    }
  }

  async function handleArchiveUser() {
    if (!userToArchive) return;

    try {
      setArchivingUser(true);
      setActionLoadingId(userToArchive.id);

      const token = getToken();

      if (!token) {
        navigate("/signin");
        return;
      }

      const response = await fetch(
        `https://fyp-backend-cbaa.onrender.com/api/admin/users/${userToArchive.id}/archive`,
        {
          method: "PATCH",
          headers: {
            "X-Auth-Token": token,
          },
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Failed to archive user.");
      }

      setUsers((previousUsers) =>
        previousUsers.filter((currentUser) => currentUser.id !== userToArchive.id)
      );

      setUserToArchive(null);
    } catch (err) {
      alert(err.message || "Something went wrong while archiving the user.");
    } finally {
      setArchivingUser(false);
      setActionLoadingId(null);
    }
  }

  async function handleRestoreUser(user) {
    try {
      setActionLoadingId(user.id);

      const token = getToken();

      if (!token) {
        navigate("/signin");
        return;
      }

      const response = await fetch(
        `https://fyp-backend-cbaa.onrender.com/api/admin/users/${user.id}/restore`,
        {
          method: "PATCH",
          headers: {
            "X-Auth-Token": token,
          },
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Failed to restore user.");
      }

      setUsers((previousUsers) =>
        previousUsers.filter((currentUser) => currentUser.id !== user.id)
      );
    } catch (err) {
      alert(err.message || "Something went wrong while restoring the user.");
    } finally {
      setActionLoadingId(null);
    }
  }

  async function handleDeleteUser() {
    if (!userToDelete) return;

    try {
      setDeletingUser(true);

      const token = getToken();

      if (!token) {
        navigate("/signin");
        return;
      }

      const response = await fetch(
        `https://fyp-backend-cbaa.onrender.com/api/admin/users/${userToDelete.id}`,
        {
          method: "DELETE",
          headers: {
            "X-Auth-Token": token,
          },
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Failed to delete user.");
      }

      setUsers((previousUsers) =>
        previousUsers.filter((user) => user.id !== userToDelete.id)
      );

      setUserToDelete(null);
    } catch (err) {
      alert(err.message || "Something went wrong while deleting the user.");
    } finally {
      setDeletingUser(false);
    }
  }

  function getMainRole(user) {
    if (user.roles.includes("ROLE_ADMIN")) return "ADMIN";
    if (user.roles.includes("ROLE_EMPLOYER")) return "EMPLOYER";
    return "USER";
  }

  function formatRole(user) {
    const mainRole = getMainRole(user);

    if (mainRole === "ADMIN") return "Admin";
    if (mainRole === "EMPLOYER") return "Employer";
    return "User";
  }

  function formatStatus(status) {
    if (!status) return "Pending";

    return status
      .replace("_", " ")
      .replace(/\b\w/g, (letter) => letter.toUpperCase());
  }

  function formatDate(dateValue) {
    if (!dateValue) return "Not specified";

    const date = new Date(dateValue);

    if (Number.isNaN(date.getTime())) {
      return dateValue;
    }

    return date.toLocaleDateString("en-GB");
  }

  function renderApplicationFileButtons(application, type) {
    const hasFile =
      type === "application"
        ? application.hasApplicationDocument
        : application.hasRecommendationLetter;

    const label =
      type === "application"
        ? application.applicationOriginalName || "Application document"
        : application.recommendationOriginalName || "Recommendation letter";

    if (!hasFile) {
      return <span style={styles.noFileText}>No file</span>;
    }

    return (
      <div style={styles.fileActions}>
        <span style={styles.fileName}>{label}</span>

        <div style={styles.fileButtons}>
          <a
            href={getAdminApplicationFileUrl(application.id, type, false)}
            target="_blank"
            rel="noreferrer"
            style={styles.viewFileButton}
          >
            View
          </a>

          <a
            href={getAdminApplicationFileUrl(application.id, type, true)}
            target="_blank"
            rel="noreferrer"
            style={styles.downloadFileButton}
          >
            Download
          </a>
        </div>
      </div>
    );
  }

  function renderApplicationsTable(applications) {
    return (
      <div style={styles.tableWrapper}>
        <table style={styles.applicationsTable}>
          <thead>
            <tr>
              <th style={styles.smallTh}>#</th>
              <th style={styles.applicationTh}>Candidate</th>
              <th style={styles.applicationTh}>Job</th>
              <th style={styles.applicationTh}>Status</th>
              <th style={styles.applicationTh}>Application</th>
              <th style={styles.applicationTh}>Recommendation</th>
              <th style={styles.applicationTh}>Applied</th>
            </tr>
          </thead>

          <tbody>
            {applications.map((application, index) => (
              <tr key={application.id || index}>
                <td style={styles.smallTd}>{index + 1}</td>
                <td style={styles.applicationTd}>
                  {application.candidateName || "Unknown"}
                </td>
                <td style={styles.applicationTd}>
                  {application.jobTitle || "No job title"}
                </td>

                <td style={styles.applicationTd}>
                  <div style={styles.centerCell}>
                    <span style={styles.roleBadge}>
                      {formatStatus(application.status)}
                    </span>
                  </div>
                </td>

                <td style={styles.applicationTd}>
                  {renderApplicationFileButtons(application, "application")}
                </td>

                <td style={styles.applicationTd}>
                  {renderApplicationFileButtons(application, "recommendation")}
                </td>

                <td style={styles.applicationTd}>
                  {formatDate(application.createdAt)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {applications.length === 0 && (
          <p style={styles.infoText}>No applications found.</p>
        )}
      </div>
    );
  }

  const totalUsers = users.length;
  const verifiedUsers = users.filter((user) => user.isVerified).length;
  const unverifiedUsers = users.filter((user) => !user.isVerified).length;
  const adminUsers = users.filter((user) =>
    user.roles.includes("ROLE_ADMIN")
  ).length;

  const totalProfiles = candidateProfiles.length;
  const completedProfiles = candidateProfiles.filter(
    (profile) => profile.selectedDisabilities.length > 0
  ).length;
  const pendingAbilityProfiles = candidateProfiles.filter(
    (profile) => profile.remainingAbilities.length === 0
  ).length;
  const totalProfileApplications = candidateProfiles.reduce(
    (total, profile) => total + (profile.applications?.length || 0),
    0
  );

  const filteredUsers = users.filter((user) => {
    const searchValue = searchTerm.toLowerCase().trim();

    const matchesSearch =
      user.username.toLowerCase().includes(searchValue) ||
      user.email.toLowerCase().includes(searchValue);

    const mainRole = getMainRole(user);

    const matchesRole = roleFilter === "" || mainRole === roleFilter;

    const matchesVerification =
      verificationFilter === "" ||
      (verificationFilter === "VERIFIED" && user.isVerified) ||
      (verificationFilter === "UNVERIFIED" && !user.isVerified);

    return matchesSearch && matchesRole && matchesVerification;
  });

  const filteredProfiles = candidateProfiles.filter((profile) => {
    const searchValue = searchTerm.toLowerCase().trim();

    return (
      profile.username.toLowerCase().includes(searchValue) ||
      profile.email.toLowerCase().includes(searchValue)
    );
  });

  const filteredApplications = adminApplications.filter((application) => {
    const searchValue = searchTerm.toLowerCase().trim();

    return (
      (application.candidateName || "").toLowerCase().includes(searchValue) ||
      (application.jobTitle || "").toLowerCase().includes(searchValue) ||
      (application.status || "").toLowerCase().includes(searchValue)
    );
  });

  return (
    <div style={styles.page}>
      <aside style={styles.sidebar}>
        <h2 style={styles.logo}>Admin Panel</h2>

        <nav style={styles.nav}>
          <button
            style={getNavStyle("USERS")}
            onMouseEnter={() => setHoveredTab("USERS")}
            onMouseLeave={() => setHoveredTab(null)}
            onClick={() => handleTabChange("USERS")}
          >
            Users
          </button>

          <button
            style={getNavStyle("ARCHIVED_USERS")}
            onMouseEnter={() => setHoveredTab("ARCHIVED_USERS")}
            onMouseLeave={() => setHoveredTab(null)}
            onClick={() => handleTabChange("ARCHIVED_USERS")}
          >
            Archived Users
          </button>

          <button
            style={getNavStyle("APPLICATIONS")}
            onMouseEnter={() => setHoveredTab("APPLICATIONS")}
            onMouseLeave={() => setHoveredTab(null)}
            onClick={() => handleTabChange("APPLICATIONS")}
          >
            Applications
          </button>

          <button
            style={getNavStyle("USER_PROFILES")}
            onMouseEnter={() => setHoveredTab("USER_PROFILES")}
            onMouseLeave={() => setHoveredTab(null)}
            onClick={() => handleTabChange("USER_PROFILES")}
          >
            User Profiles
          </button>
        </nav>
      </aside>

      <main style={styles.main}>
        <div style={styles.header}>
          <button onClick={handleLogout} style={styles.logoutTextButton}>
            Logout
          </button>

          <div>
            <h1 style={styles.title}>Admin Dashboard</h1>
            <p style={styles.subtitle}>
              Manage users, applications, and platform activity.
            </p>
          </div>
        </div>

        {isUserProfilesView ? (
          <>
            <section style={styles.cards}>
              <div style={styles.card}>
                <p style={styles.cardLabel}>Candidate Profiles</p>
                <h2 style={styles.cardValue}>{totalProfiles}</h2>
              </div>

              <div style={styles.card}>
                <p style={styles.cardLabel}>Completed Profiles</p>
                <h2 style={styles.cardValue}>{completedProfiles}</h2>
              </div>

              <div style={styles.card}>
                <p style={styles.cardLabel}>Pending Abilities</p>
                <h2 style={styles.cardValue}>{pendingAbilityProfiles}</h2>
              </div>

              <div style={styles.card}>
                <p style={styles.cardLabel}>Applications</p>
                <h2 style={styles.cardValue}>{totalProfileApplications}</h2>
              </div>
            </section>

            <section style={styles.tableSection}>
              <div style={styles.tableHeader}>
                <h2 style={styles.sectionTitle}>USER PROFILES</h2>
              </div>

              <input
                type="text"
                placeholder="Search candidate profile by username or email..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                style={styles.profileSearchInput}
              />

              {loading && <p style={styles.infoText}>Loading profiles...</p>}
              {error && <p style={styles.errorText}>{error}</p>}

              {!loading && !error && (
                <div style={styles.profileGrid}>
                  {filteredProfiles.map((profile) => (
                    <div key={profile.id} style={styles.profileCard}>
                      <div style={styles.profileAvatar}>
                        {profile.username.charAt(0).toUpperCase()}
                      </div>

                      <h3 style={styles.profileName}>{profile.username}</h3>
                      <p style={styles.profileEmail}>{profile.email}</p>

                      <div style={styles.profileStats}>
                        <span style={styles.profileStat}>
                          {profile.selectedDisabilities.length} disabilities
                        </span>

                        <span style={styles.profileStat}>
                          {profile.remainingAbilities.length > 0
                            ? "Abilities ready"
                            : "Abilities pending"}
                        </span>

                        <span style={styles.profileStat}>
                          {profile.applications?.length || 0} applications
                        </span>
                      </div>

                      <button
                        style={styles.viewProfileButton}
                        onClick={() => {
                          setSelectedProfile(profile);
                          setShowProfileApplications(false);
                        }}
                      >
                        View Profile
                      </button>
                    </div>
                  ))}

                  {filteredProfiles.length === 0 && (
                    <p style={styles.infoText}>
                      No candidate profiles match your search.
                    </p>
                  )}
                </div>
              )}
            </section>
          </>
        ) : isApplicationsView ? (
          <section style={styles.tableSection}>
            <div style={styles.tableHeader}>
              <h2 style={styles.sectionTitle}>ALL APPLICATIONS</h2>
            </div>

            <input
              type="text"
              placeholder="Search by candidate, job, or status..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={styles.profileSearchInput}
            />

            {loading && <p style={styles.infoText}>Loading applications...</p>}
            {error && <p style={styles.errorText}>{error}</p>}

            {!loading && !error && renderApplicationsTable(filteredApplications)}
          </section>
        ) : (
          <>
            <section style={styles.cards}>
              <div style={styles.card}>
                <div style={{...styles.cardIcon, ...styles.usersIcon}}>
                  <svg style={styles.cardSvg} viewBox="0 0 24 24" fill="none">
                    <path d="M9 11C11.2 11 13 9.2 13 7C13 4.8 11.2 3 9 3C6.8 3 5 4.8 5 7C5 9.2 6.8 11 9 11Z" />
                    <path d="M2.5 21C3.2 16.8 5.6 14.5 9 14.5C12.4 14.5 14.8 16.8 15.5 21" />
                    <path d="M16 10C17.7 10 19 8.7 19 7C19 5.3 17.7 4 16 4" />
                    <path d="M17 14.8C19.4 15.3 21 17.4 21.5 21" />
                  </svg>
                </div>
                <p style={styles.cardLabel}>
                  {isArchivedView ? "Archived Users" : "Active Users"}
                </p>
                <h2 style={styles.cardValue}>{totalUsers}</h2>
              </div>

              <div style={styles.card}>
                <div style={{...styles.cardIcon, ...styles.verifiedIcon}}>
                  <svg style={styles.cardSvg} viewBox="0 0 24 24" fill="none">
                    <path d="M20 7L10 17L5 12" />
                  </svg>
                </div>
                <p style={styles.cardLabel}>Verified Emails</p>
                <h2 style={styles.cardValue}>{verifiedUsers}</h2>
              </div>

              <div style={styles.card}>
                <div style={{...styles.cardIcon, ...styles.unverifiedIcon}}>
                  <svg style={styles.cardSvg} viewBox="0 0 24 24" fill="none">
                    <path d="M12 4L21 20H3L12 4Z" />
                    <path d="M12 9V13" />
                    <path d="M12 17H12.01" />
                  </svg>
                </div>
                <p style={styles.cardLabel}>Unverified Users</p>
                <h2 style={styles.cardValue}>{unverifiedUsers}</h2>
              </div>

              <div style={styles.card}>
                <div style={{...styles.cardIcon, ...styles.adminIcon}}>
                  <svg style={styles.cardSvg} viewBox="0 0 24 24" fill="none">
                    <path d="M12 3L19 6V11C19 15.5 16.2 19.4 12 21C7.8 19.4 5 15.5 5 11V6L12 3Z" />
                    <path d="M9.5 12L11.3 13.8L15 10" />
                  </svg>
                </div>
                <p style={styles.cardLabel}>Admins</p>
                <h2 style={styles.cardValue}>{adminUsers}</h2>
              </div>
            </section>

            <section style={styles.tableSection}>
              <div style={styles.tableHeader}>
                <div style={styles.tableTitleRow}>
                  <h2 style={styles.sectionTitle}>
                    {isArchivedView ? "Archived Users" : "Users"}
                  </h2>

                  {!loading && !error && (
                    <span style={styles.tableCount}>
                      {filteredUsers.length}/{users.length}
                    </span>
                  )}
                </div>
              </div>

              <div style={styles.filtersRow}>
                <input
                  type="text"
                  placeholder="Search by username or email..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  style={styles.searchInput}
                />

                <select
                  value={roleFilter}
                  onChange={handleRoleFilterChange}
                  style={styles.filterSelect}
                >
                  <option value="" disabled hidden>
                    Filter by Role
                  </option>
                  <option value="RESET">--</option>
                  <option value="ADMIN">Admin</option>
                  <option value="USER">User</option>
                  <option value="EMPLOYER">Employer</option>
                </select>

                <select
                  value={verificationFilter}
                  onChange={handleVerificationFilterChange}
                  style={styles.filterSelect}
                >
                  <option value="" disabled hidden>
                    Filter by Email Status
                  </option>
                  <option value="RESET">--</option>
                  <option value="VERIFIED">Verified email</option>
                  <option value="UNVERIFIED">Unverified email</option>
                </select>
              </div>

              {loading && <p style={styles.infoText}>Loading users...</p>}
              {error && <p style={styles.errorText}>{error}</p>}

              {!loading && !error && (
                <div style={styles.tableWrapper}>
                  <table style={styles.table}>
                    <thead>
                      <tr>
                        <th style={styles.th}>#</th>
                        <th style={styles.th}>USERNAME</th>
                        <th style={styles.th}>EMAIL</th>
                        <th style={styles.th}>ROLE</th>
                        <th style={styles.th}>VERIFIED</th>
                        <th style={styles.actionsTh}>ACTIONS</th>
                      </tr>
                    </thead>

                    <tbody>
                      {filteredUsers.map((user, index) => (
                        <tr key={user.id}>
                          <td style={styles.td}>{index + 1}</td>
                          <td style={styles.td}>{user.username}</td>
                          <td style={styles.td}>{user.email}</td>

                          <td style={styles.td}>
                            <div style={styles.centerCell}>
                              <span style={styles.roleBadge}>{formatRole(user)}</span>
                            </div>
                          </td>

                          <td style={styles.td}>
                            <div style={styles.centerCell}>
                              <span
                                style={{
                                  ...styles.statusBadge,
                                  ...(user.isVerified
                                    ? styles.verified
                                    : styles.unverified),
                                }}
                              >
                                {user.isVerified ? "Verified" : "Unverified"}
                              </span>
                            </div>
                          </td>

                          <td style={styles.actionsTd}>
                            <div style={styles.actions}>
                              {!isArchivedView ? (
                                <>
                                  <button
                                    style={styles.actionButton}
                                    onClick={() => openEditModal(user)}
                                    disabled={actionLoadingId === user.id}
                                  >
                                    Edit
                                  </button>

                                  <button
                                    onClick={() => setUserToArchive(user)}
                                    style={styles.archiveButton}
                                    disabled={actionLoadingId === user.id}
                                  >
                                    Archive
                                  </button>

                                  <button
                                    onClick={() => setUserToDelete(user)}
                                    style={styles.deleteButton}
                                  >
                                    Delete
                                  </button>
                                </>
                              ) : (
                                <>
                                  <button
                                    onClick={() => handleRestoreUser(user)}
                                    style={styles.restoreButton}
                                    disabled={actionLoadingId === user.id}
                                  >
                                    {actionLoadingId === user.id
                                      ? "Restoring..."
                                      : "Restore"}
                                  </button>

                                  <button
                                    onClick={() => setUserToDelete(user)}
                                    style={styles.deleteButton}
                                  >
                                    Delete
                                  </button>
                                </>
                              )}
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>

                  {filteredUsers.length === 0 && (
                    <p style={styles.infoText}>
                      {isArchivedView
                        ? "No archived users match your search or filters."
                        : "No users match your search or filters."}
                    </p>
                  )}
                </div>
              )}
            </section>
          </>
        )}
      </main>

      {selectedProfile && (
        <div style={styles.modalOverlay}>
          <div style={styles.profileModal}>
            <div style={styles.profileModalScroll}>
              <div style={styles.profileModalTop}>
                <div>
                  <h2 style={styles.profileModalTitle}>Candidate Profile</h2>
                  <p style={styles.profileModalSubtitle}>
                    Detailed candidate information and activity
                  </p>
                </div>
              </div>

              <div style={styles.profileModalHeader}>
                <div style={styles.profileAvatarLarge}>
                  {selectedProfile.username.charAt(0).toUpperCase()}
                </div>

                <div>
                  <h3 style={styles.profileModalName}>{selectedProfile.username}</h3>
                  <p style={styles.profileModalEmail}>{selectedProfile.email}</p>
                </div>
              </div>

              <div style={styles.profileDetailsGrid}>
                <div style={styles.profileSection}>
                  <h3 style={styles.profileSectionTitle}>Selected Disabilities</h3>

                  {selectedProfile.selectedDisabilities.length > 0 ? (
                    <div style={styles.chipRow}>
                      {selectedProfile.selectedDisabilities.map((disability) => (
                        <span key={disability} style={styles.profileChip}>
                          {disability}
                        </span>
                      ))}
                    </div>
                  ) : (
                    <p style={styles.profileEmptyText}>No disabilities selected yet.</p>
                  )}
                </div>

                <div style={styles.profileSection}>
                  <h3 style={styles.profileSectionTitle}>Remaining Abilities</h3>

                  {selectedProfile.remainingAbilities.length > 0 ? (
                    <div style={styles.chipRow}>
                      {selectedProfile.remainingAbilities.map((ability) => (
                        <span key={ability} style={styles.abilityChip}>
                          {ability}
                        </span>
                      ))}
                    </div>
                  ) : (
                    <p style={styles.profileEmptyText}>
                      Remaining abilities are pending analysis.
                    </p>
                  )}
                </div>

                <div style={styles.profileSection}>
                  <h3 style={styles.profileSectionTitle}>Applications</h3>

                  <p style={styles.profileEmptyText}>
                    This user has applied to{" "}
                    <strong>{selectedProfile.applications?.length || 0}</strong>{" "}
                    application(s).
                  </p>

                  {(selectedProfile.applications?.length || 0) > 0 && (
                    <button
                      style={styles.viewApplicationsButton}
                      onClick={() =>
                        setShowProfileApplications((previousValue) => !previousValue)
                      }
                    >
                      {showProfileApplications ? "Hide Applications" : "View Applications"}
                    </button>
                  )}
                </div>

                <div style={styles.profileSection}>
                  <h3 style={styles.profileSectionTitle}>Last Updated</h3>
                  <p style={styles.profileEmptyText}>
                    {selectedProfile.updatedAt || "Not updated yet."}
                  </p>
                </div>
              </div>

              {showProfileApplications && (
                <div style={styles.profileApplicationsBlock}>
                  {renderApplicationsTable(selectedProfile.applications || [])}
                </div>
              )}
            </div>

            <div style={styles.profileModalFooter}>
              <button
                onClick={() => {
                  setSelectedProfile(null);
                  setShowProfileApplications(false);
                }}
                style={styles.confirmEditButton}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {userToEdit && (
        <div style={styles.modalOverlay}>
          <div style={styles.editModal}>
            <h2 style={styles.modalTitle}>Edit user</h2>

            <p style={styles.modalText}>
              Update <strong>{userToEdit.username}</strong>&apos;s account
              information.
            </p>

            <form onSubmit={handleEditUser} style={styles.editForm}>
              <div style={styles.editField}>
                <label style={styles.editLabel}>Username</label>
                <input
                  type="text"
                  name="username"
                  value={editFormData.username}
                  onChange={handleEditFormChange}
                  style={styles.editInput}
                  placeholder="Enter username"
                />
              </div>

              <div style={styles.editField}>
                <label style={styles.editLabel}>Email</label>
                <input
                  type="email"
                  name="email"
                  value={editFormData.email}
                  onChange={handleEditFormChange}
                  style={styles.editInput}
                  placeholder="Enter email"
                />
              </div>

              <p style={styles.emailEditNote}>
                If the email is changed, the user will become unverified and a
                new verification email will be sent.
              </p>

              <div style={styles.passwordSection}>
                <button
                  type="button"
                  onClick={() => {
                    setShowPasswordField((previousValue) => !previousValue);
                    setEditFormData((previousData) => ({
                      ...previousData,
                      password: "",
                    }));
                  }}
                  style={styles.changePasswordButton}
                >
                  {showPasswordField
                    ? "Cancel password change"
                    : "Change password"}
                </button>

                {showPasswordField && (
                  <div style={styles.editField}>
                    <label style={styles.editLabel}>Type new password</label>
                    <input
                      type="password"
                      name="password"
                      value={editFormData.password}
                      onChange={handleEditFormChange}
                      style={styles.editInput}
                      placeholder="Enter new password"
                    />
                  </div>
                )}
              </div>

              <div style={styles.modalActions}>
                <button
                  type="button"
                  onClick={() => {
                    setUserToEdit(null);
                    setShowPasswordField(false);
                  }}
                  style={styles.cancelModalButton}
                  disabled={editingUser}
                >
                  Cancel
                </button>

                <button
                  type="submit"
                  style={styles.confirmEditButton}
                  disabled={editingUser}
                >
                  {editingUser ? "Saving..." : "Save Changes"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {userToArchive && (
        <div style={styles.modalOverlay}>
          <div style={styles.modal}>
            <h2 style={styles.modalTitle}>Archive user?</h2>

            <p style={styles.modalText}>
              You are about to archive <strong>{userToArchive.username}</strong>.
            </p>

            <p style={styles.archiveModalWarning}>
              This user will be removed from the active users table and moved to
              Archived Users.
            </p>

            <div style={styles.modalActions}>
              <button
                onClick={() => setUserToArchive(null)}
                style={styles.cancelModalButton}
                disabled={archivingUser}
              >
                Cancel
              </button>

              <button
                onClick={handleArchiveUser}
                style={styles.confirmArchiveButton}
                disabled={archivingUser}
              >
                {archivingUser ? "Archiving..." : "Archive User"}
              </button>
            </div>
          </div>
        </div>
      )}

      {userToDelete && (
        <div style={styles.modalOverlay}>
          <div style={styles.modal}>
            <div style={styles.modalIcon}>!</div>

            <h2 style={styles.modalTitle}>Delete user?</h2>

            <p style={styles.modalText}>
              You are about to permanently delete{" "}
              <strong>{userToDelete.username}</strong> from the platform.
            </p>

            <p style={styles.modalWarning}>This action cannot be undone.</p>

            <div style={styles.modalActions}>
              <button
                onClick={() => setUserToDelete(null)}
                style={styles.cancelModalButton}
                disabled={deletingUser}
              >
                Cancel
              </button>

              <button
                onClick={handleDeleteUser}
                style={styles.confirmDeleteButton}
                disabled={deletingUser}
              >
                {deletingUser ? "Deleting..." : "Delete User"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

const styles = {
  page: {
    minHeight: "100vh",
    display: "flex",
    background:
      "linear-gradient(135deg, #eef4ff 0%, #f8fbff 40%, #edf2ff 100%)",
    color: "#1f2937",
    fontFamily: "Inter, system-ui, Arial, sans-serif",
    overflowX: "hidden",
  },

  sidebar: {
    width: "240px",
    minWidth: "240px",
    background:
      "linear-gradient(180deg, #121b31 0%, #081020 45%, #000000 100%)",
    color: "white",
    padding: "32px 20px",
    display: "flex",
    flexDirection: "column",
    boxSizing: "border-box",
    borderRight: "1px solid rgba(255,255,255,0.05)",
    boxShadow: "8px 0 30px rgba(15, 23, 42, 0.18)",
  },

  logo: {
    fontSize: "28px",
    marginBottom: "38px",
    whiteSpace: "nowrap",
    fontWeight: "800",
    letterSpacing: "-0.8px",
    color: "#ffffff",
  },

  nav: {
    display: "flex",
    flexDirection: "column",
    gap: "12px",
  },

  navItem: {
    background: "transparent",
    color: "#cbd5e1",
    border: "none",
    textAlign: "left",
    padding: "14px 18px",
    borderRadius: "14px",
    cursor: "pointer",
    fontSize: "15px",
    fontWeight: "500",
    transition: "all 0.18s ease",
  },

  activeNavItem: {
    background: "rgba(59, 130, 246, 0.12)",
    color: "#ffffff",
    fontWeight: "700",
    boxShadow: "inset 4px 0 0 #cdd2d9",
  },

  hoveredNavItem: {
    background: "rgba(255,255,255,0.05)",
    color: "#ffffff",
  },

  logoutButton: {
    marginTop: "auto",
    background: "#ef4444",
    color: "white",
    border: "none",
    padding: "12px",
    borderRadius: "12px",
    cursor: "pointer",
    fontWeight: "600",
  },

  main: {
    flex: 1,
    padding: "36px",
    maxWidth: "calc(100vw - 255px)",
    boxSizing: "border-box",
    overflowX: "hidden",
  },

  header: {
    position: "relative",
    display: "flex",
    flexDirection: "column",
    alignItems: "flex-start",
    marginBottom: "34px",
  },

  logoutTextButton: {
    position: "absolute",
    top: "8px",
    right: "0",
    border: "none",
    background: "transparent",
    color: "#dc2626",
    fontSize: "15px",
    fontWeight: "800",
    cursor: "pointer",
    padding: 0,
  },

  logoutButton: {
    display: "none",
  },

  title: {
    fontSize: "40px",
    margin: 0,
    color: "#0f172a",
    fontWeight: "800",
    letterSpacing: "-1.5px",
    textAlign: "left",
  },

  subtitle: {
    marginTop: "10px",
    color: "#475569",
    fontSize: "16px",
    fontWeight: "500",
    textAlign: "left",
  },
  
  cards: {
    display: "grid",
    gridTemplateColumns: "repeat(4, minmax(0, 1fr))",
    gap: "22px",
    marginBottom: "30px",
  },

  card: {
    background: "rgba(255,255,255,0.9)",
    borderRadius: "20px",
    padding: "14px 18px",
    border: "1px solid rgba(226,232,240,0.9)",
    boxShadow: "0 10px 28px rgba(15, 23, 42, 0.06)",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    gap: "5px",
    height: "135px",
    minHeight: "unset",
  },
  
  cardIcon: {
    width: "44px",
    height: "44px",
    borderRadius: "15px",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    flexShrink: 0,
    marginBottom: "4px",
  },

  cardLabel: {
    color: "#475569",
    margin: 0,
    fontSize: "15px",
    fontWeight: "700",
    letterSpacing: "0.1px",
    lineHeight: "1",
  },

  cardValue: {
    margin: "4px 0 0",
    fontSize: "34px",
    color: "#0c2364",
    fontWeight: "900",
    letterSpacing: "-0.8px",
    lineHeight: "1",
  },

  cardSvg: {
    width: "24px",
    height: "24px",
    stroke: "currentColor",
    strokeWidth: 2.2,
    strokeLinecap: "round",
    strokeLinejoin: "round",
  },

  usersIcon: {
    background: "#dccfe5",
    color: "#9646e5",
  },

  verifiedIcon: {
    background: "#dcfce7",
    color: "#16a34a",
  },

  unverifiedIcon: {
    background: "#fef3c7",
    color: "#d97706",
  },

  adminIcon: {
    background: "#dbeafe",
    color: "#2563eb",
  },

  tableSection: {
    background: "rgba(255,255,255,0.92)",
    borderRadius: "28px",
    padding: "30px 28px 26px",
    boxShadow:
      "0 14px 40px rgba(15, 23, 42, 0.08)",
    width: "100%",
    boxSizing: "border-box",
    overflow: "hidden",
    border: "1px solid rgba(226,232,240,0.8)",
    backdropFilter: "blur(12px)",
  },

  tableHeader: {
    marginBottom: "20px",
  },

  tableTitleRow: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
  },

  sectionTitle: {
    margin: 0,
    fontSize: "22px",
    color: "#111827",
    fontWeight: "800",
    letterSpacing: "-0.3px",
  },

  tableCount: {
    color: "#64748b",
    fontSize: "14px",
    fontWeight: "800",
    background: "#f8fafc",
    border: "1px solid #e2e8f0",
    borderRadius: "999px",
    padding: "7px 12px",
  },

  filtersRow: {
    display: "grid",
    gridTemplateColumns: "minmax(260px, 1fr) 170px 210px",
    gap: "12px",
    alignItems: "center",
    marginBottom: "12px",
  },

  searchInput: {
    width: "100%",
    padding: "14px 16px",
    borderRadius: "16px",
    border: "1px solid #768db1",
    fontSize: "14px",
    outline: "none",
    boxSizing: "border-box",
    background: "#f0f5fc",
    color: "#0f172a",
  },

  profileSearchInput: {
    width: "100%",
    padding: "14px 16px",
    borderRadius: "16px",
    border: "1px solid #dbe3ef",
    fontSize: "14px",
    outline: "none",
    boxSizing: "border-box",
    marginBottom: "24px",
    background: "#f8fbff",
    color: "#0f172a",
  },

  filterSelect: {
    width: "100%",
    padding: "12px 14px",
    borderRadius: "12px",
    border: "1px solid #b9c9e0",
    fontSize: "14px",
    background: "white",
    color: "#374151",
    cursor: "pointer",
    outline: "none",
    appearance: "auto",
    boxSizing: "border-box",
  },

  resultsText: {
    color: "#6b7280",
    fontSize: "14px",
    marginBottom: "14px",
    textAlign: "center",
  },

  tableWrapper: {
    width: "100%",
    overflowX: "auto",
  },

  table: {
    width: "100%",
    borderCollapse: "collapse",
  },

  applicationsTable: {
    width: "100%",
    tableLayout: "fixed",
    borderCollapse: "collapse",
  },

  th: {
    textAlign: "center",
    padding: "15px 14px",
    background: "#f8fafc",
    color: "#475569",
    fontSize: "14px",
    fontWeight: "700",
    letterSpacing: "0.8px",
    textTransform: "uppercase",
    borderBottom: "1px solid #e5e7eb",
  },

  smallTh: {
    width: "44px",
    textAlign: "center",
    padding: "16px 8px",
    background: "#f9fafb",
    color: "#374151",
    fontSize: "13px",
    fontWeight: "800",
    textTransform: "uppercase",
    borderBottom: "1px solid #e5e7eb",
  },

  applicationTh: {
    textAlign: "center",
    padding: "16px 8px",
    background: "#f9fafb",
    color: "#374151",
    fontSize: "13px",
    fontWeight: "800",
    letterSpacing: "0.3px",
    textTransform: "uppercase",
    borderBottom: "1px solid #e5e7eb",
  },

  actionsTh: {
    textAlign: "center",
    padding: "18px 12px",
    background: "#f9fafb",
    color: "#374151",
    fontSize: "14px",
    fontWeight: "700",
    letterSpacing: "0.8px",
    textTransform: "uppercase",
    borderBottom: "1px solid #e5e7eb",
    borderLeft: "1px solid #eef2f7",
    width: "145px",
  },

  td: {
    padding: "13px 14px",
    borderBottom: "1px solid #e5e7eb",
    fontSize: "14px",
    verticalAlign: "middle",
    textAlign: "center",
  },

  smallTd: {
    width: "44px",
    padding: "14px 8px",
    borderBottom: "1px solid #e5e7eb",
    fontSize: "13px",
    verticalAlign: "middle",
    textAlign: "center",
  },

  applicationTd: {
    padding: "14px 8px",
    borderBottom: "1px solid #e5e7eb",
    fontSize: "13px",
    verticalAlign: "middle",
    textAlign: "center",
    wordBreak: "break-word",
  },

  actionsTd: {
    padding: "14px 12px",
    borderBottom: "1px solid #e5e7eb",
    borderLeft: "1px solid #eef2f7",
    fontSize: "14px",
    verticalAlign: "middle",
    width: "145px",
  },

  centerCell: {
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
  },

  roleBadge: {
    background: "#eef2ff",
    color: "#3730a3",
    padding: "6px 10px",
    borderRadius: "999px",
    fontWeight: "600",
    fontSize: "12px",
    whiteSpace: "nowrap",
  },

  statusBadge: {
    padding: "6px 10px",
    borderRadius: "999px",
    fontWeight: "600",
    fontSize: "13px",
  },

  verified: {
    background: "#dcfce7",
    color: "#166534",
  },

  unverified: {
    background: "#fef3c7",
    color: "#92400e",
  },

  actions: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    gap: "7px",
  },

  actionButton: {
    border: "none",
    background: "#eff6ff",
    color: "#2563eb",
    padding: "8px 14px",
    borderRadius: "999px",
    cursor: "pointer",
    fontWeight: "700",
    fontSize: "13px",
    minWidth: "82px",
  },

  archiveButton: {
    border: "none",
    background: "#f3f4f6",
    color: "#374151",
    padding: "8px 14px",
    borderRadius: "999px",
    cursor: "pointer",
    fontWeight: "700",
    fontSize: "13px",
    minWidth: "82px",
  },

  restoreButton: {
    border: "none",
    background: "#dcfce7",
    color: "#166534",
    padding: "7px 12px",
    borderRadius: "999px",
    cursor: "pointer",
    fontWeight: "700",
    fontSize: "13px",
    minWidth: "74px",
  },

  deleteButton: {
    border: "none",
    background: "#fee2e2",
    color: "#dc2626",
    padding: "8px 14px",
    borderRadius: "999px",
    cursor: "pointer",
    fontWeight: "700",
    fontSize: "13px",
    minWidth: "82px",
  },

  fileActions: {
    display: "flex",
    flexDirection: "column",
    gap: "7px",
    alignItems: "center",
  },

  fileName: {
    fontSize: "12px",
    color: "#4b5563",
    fontWeight: "600",
    maxWidth: "115px",
    wordBreak: "break-word",
    textAlign: "center",
    lineHeight: "1.25",
  },

  fileButtons: {
    display: "flex",
    flexWrap: "wrap",
    gap: "6px",
    justifyContent: "center",
  },

  viewFileButton: {
    textDecoration: "none",
    background: "#eff6ff",
    color: "#1d4ed8",
    padding: "6px 9px",
    borderRadius: "999px",
    fontSize: "12px",
    fontWeight: "700",
  },

  downloadFileButton: {
    textDecoration: "none",
    background: "#dcfce7",
    color: "#166534",
    padding: "6px 9px",
    borderRadius: "999px",
    fontSize: "12px",
    fontWeight: "700",
  },

  noFileText: {
    color: "#9ca3af",
    fontSize: "13px",
    fontWeight: "600",
  },

  profileGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fill, minmax(245px, 1fr))",
    gap: "18px",
  },

  profileCard: {
    background: "#ffffff",
    border: "1px solid #dbe3ef",
    borderRadius: "18px",
    padding: "24px",
    textAlign: "center",
    boxShadow: "0 8px 24px rgba(15, 23, 42, 0.055)",
  },

  profileAvatar: {
    width: "56px",
    height: "56px",
    borderRadius: "16px",
    background: "linear-gradient(135deg, #4d6ebd, #092069)",
    color: "white",
    margin: "0 auto 14px",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontWeight: "800",
    fontSize: "22px",
  },

  profileName: {
    margin: "0 0 6px",
    color: "#111827",
    fontSize: "18px",
    fontWeight: "800",
  },

  profileEmail: {
    margin: "0 0 14px",
    color: "#6b7280",
    fontSize: "13px",
    wordBreak: "break-word",
  },

  profileStats: {
    display: "flex",
    flexDirection: "column",
    gap: "8px",
    marginBottom: "18px",
  },

  profileStat: {
    background: "#f8fafc",
    color: "#334155",
    border: "1px solid #e2e8f0",
    borderRadius: "12px",
    padding: "9px 12px",
    fontSize: "13px",
    fontWeight: "700",
  },

  viewProfileButton: {
    border: "none",
    background: "#3a62d2",
    color: "white",
    padding: "10px 14px",
    borderRadius: "12px",
    cursor: "pointer",
    fontWeight: "700",
  },

  modalOverlay: {
    position: "fixed",
    inset: 0,
    background: "rgba(17, 24, 39, 0.55)",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    zIndex: 1000,
    padding: "20px",
  },

  modal: {
    width: "100%",
    maxWidth: "430px",
    background: "white",
    borderRadius: "18px",
    padding: "28px",
    boxShadow: "0 25px 50px rgba(15, 23, 42, 0.25)",
    textAlign: "center",
  },

  profileModal: {
    width: "100%",
    maxWidth: "900px",
    height: "88vh",
    background: "#ffffff",
    borderRadius: "8px",
    padding: "0",
    boxShadow: "0 28px 70px rgba(15, 23, 42, 0.28)",
    border: "1px solid #e2e8f0",
    overflow: "hidden",
    display: "flex",
    flexDirection: "column",
  },

  profileModalScroll: {
    flex: 1,
    overflowY: "auto",
    padding: "28px",
    scrollbarWidth: "thin",
    scrollbarColor: "#cbd5e1 transparent",
  },

  profileModalFooter: {
    borderTop: "1px solid #e2e8f0",
    background: "#ffffff",
    padding: "14px 28px",
    display: "flex",
    justifyContent: "center",
  },

  profileModalTop: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: "20px",
  },

  profileModalTitle: {
    margin: 0,
    color: "#0f172a",
    fontSize: "28px",
    fontWeight: "900",
    letterSpacing: "-0.8px",
  },

  profileModalHeader: {
    display: "flex",
    alignItems: "center",
    gap: "16px",
    background: "linear-gradient(135deg, #f8fbff 0%, #eef4ff 100%)",
    border: "1px solid #dbeafe",
    borderRadius: "6px",
    padding: "18px",
    marginBottom: "18px",
  },

  profileModalSubtitle: {
    margin: "6px 0 0",
    color: "#64748b",
    fontSize: "14px",
    fontWeight: "500",
  },


  profileAvatarLarge: {
    width: "64px",
    height: "64px",
    borderRadius: "50%",
    background: "#1d4ed8",
    color: "white",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontWeight: "800",
    fontSize: "26px",
  },

  profileModalName: {
    margin: 0,
    color: "#111827",
    fontSize: "20px",
    fontWeight: "800",
  },

  profileModalEmail: {
    margin: "6px 0 0",
    color: "#6b7280",
    fontSize: "14px",
  },

  profileDetailsGrid: {
    display: "grid",
    gridTemplateColumns: "1fr 1fr",
    gap: "16px",
    marginTop: "18px",
  },

  profileSection: {
    background: "#ffffff",
    border: "1px solid #e2e8f0",
    borderRadius: "6px",
    padding: "16px 18px",
    textAlign: "left",
    boxShadow: "0 6px 18px rgba(15, 23, 42, 0.035)",
    minHeight: "120px",
  },

  profileSectionTitle: {
    margin: "0 0 12px",
    color: "#0f172a",
    fontSize: "15px",
    fontWeight: "800",
  },

  chipRow: {
    display: "flex",
    flexWrap: "wrap",
    gap: "8px",
  },

  viewApplicationsButton: {
    marginTop: "16px",
    border: "none",
    background: "#2563eb",
    color: "white",
    padding: "10px 16px",
    borderRadius: "12px",
    cursor: "pointer",
    fontWeight: "800",
    fontSize: "14px",
  },

  profileApplicationsBlock: {
    marginTop: "18px",
    border: "1px solid #e2e8f0",
    borderRadius: "6px",
    padding: "16px",
    background: "#ffffff",
  },

  profileChip: {
    display: "inline-block",
    background: "#eef2ff",
    color: "#3730a3",
    padding: "7px 10px",
    borderRadius: "999px",
    fontSize: "13px",
    fontWeight: "700",
    margin: "0 8px 8px 0",
  },

  abilityChip: {
    display: "inline-block",
    background: "#dcfce7",
    color: "#166534",
    padding: "7px 10px",
    borderRadius: "999px",
    fontSize: "13px",
    fontWeight: "700",
    margin: "0 8px 8px 0",
  },

  profileEmptyText: {
    color: "#6b7280",
    fontSize: "14px",
    margin: 0,
  },

  editModal: {
    width: "100%",
    maxWidth: "500px",
    background: "white",
    borderRadius: "18px",
    padding: "28px",
    boxShadow: "0 25px 50px rgba(15, 23, 42, 0.25)",
    textAlign: "left",
  },

  modalIcon: {
    width: "42px",
    height: "42px",
    borderRadius: "50%",
    background: "#fee2e2",
    color: "#dc2626",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    margin: "0 auto 14px",
    fontSize: "22px",
    fontWeight: "800",
  },

  modalTitle: {
    margin: 0,
    fontSize: "22px",
    color: "#111827",
    textAlign: "center",
  },

  modalText: {
    color: "#4b5563",
    fontSize: "15px",
    lineHeight: "1.6",
    margin: "14px 0 6px",
    textAlign: "center",
  },

  modalWarning: {
    color: "#991b1b",
    fontSize: "14px",
    fontWeight: "600",
    margin: "0 0 22px",
    textAlign: "center",
  },

  archiveModalWarning: {
    color: "#92400e",
    fontSize: "14px",
    fontWeight: "600",
    margin: "0 0 22px",
    textAlign: "center",
  },

  editForm: {
    marginTop: "20px",
    display: "flex",
    flexDirection: "column",
    gap: "14px",
  },

  editField: {
    display: "flex",
    flexDirection: "column",
    gap: "6px",
  },

  editLabel: {
    fontSize: "14px",
    color: "#374151",
    fontWeight: "700",
  },

  editInput: {
    padding: "11px 13px",
    borderRadius: "11px",
    border: "1px solid #d1d5db",
    fontSize: "14px",
    outline: "none",
    boxSizing: "border-box",
  },

  emailEditNote: {
    background: "#eff6ff",
    color: "#1d4ed8",
    padding: "10px 12px",
    borderRadius: "12px",
    fontSize: "13px",
    fontWeight: "600",
    lineHeight: "1.5",
    margin: "-4px 0 4px",
  },

  passwordSection: {
    display: "flex",
    flexDirection: "column",
    gap: "12px",
    marginTop: "2px",
  },

  changePasswordButton: {
    border: "1px solid #1d4ed8",
    background: "white",
    color: "#1d4ed8",
    padding: "10px 14px",
    borderRadius: "10px",
    cursor: "pointer",
    fontWeight: "700",
    fontSize: "14px",
    alignSelf: "flex-start",
  },

  modalActions: {
    display: "flex",
    justifyContent: "center",
    gap: "12px",
    marginTop: "22px",
  },

  cancelModalButton: {
    border: "1px solid #d1d5db",
    background: "white",
    color: "#374151",
    padding: "10px 16px",
    borderRadius: "10px",
    cursor: "pointer",
    fontWeight: "600",
  },

  confirmDeleteButton: {
    border: "1px solid #dc2626",
    background: "#dc2626",
    color: "white",
    padding: "10px 16px",
    borderRadius: "10px",
    cursor: "pointer",
    fontWeight: "600",
  },

  confirmArchiveButton: {
    border: "1px solid #92400e",
    background: "#92400e",
    color: "white",
    padding: "10px 16px",
    borderRadius: "10px",
    cursor: "pointer",
    fontWeight: "600",
  },

  confirmEditButton: {
    border: "1px solid #1d4ed8",
    background: "#1d4ed8",
    color: "white",
    padding: "10px 16px",
    borderRadius: "10px",
    cursor: "pointer",
    fontWeight: "600",
  },

  infoText: {
    color: "#6b7280",
    textAlign: "center",
  },

  errorText: {
    color: "#dc2626",
    fontWeight: "600",
    textAlign: "center",
  },
};

export default AdminDashboard;