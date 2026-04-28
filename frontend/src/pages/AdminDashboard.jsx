import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { getToken, logout } from "../services/authService";

function AdminDashboard() {
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState("USERS");
  const [hoveredTab, setHoveredTab] = useState(null);

  const [users, setUsers] = useState([]);
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

  useEffect(() => {
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

  const totalUsers = users.length;
  const verifiedUsers = users.filter((user) => user.isVerified).length;
  const unverifiedUsers = users.filter((user) => !user.isVerified).length;
  const adminUsers = users.filter((user) =>
    user.roles.includes("ROLE_ADMIN")
  ).length;

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
            style={{
              ...styles.navItem,
              ...(hoveredTab === "APPLICATIONS" ? styles.hoveredNavItem : {}),
            }}
            onMouseEnter={() => setHoveredTab("APPLICATIONS")}
            onMouseLeave={() => setHoveredTab(null)}
          >
            Applications
          </button>

          <button
            style={{
              ...styles.navItem,
              ...(hoveredTab === "USER PROFILES" ? styles.hoveredNavItem : {}),
            }}
            onMouseEnter={() => setHoveredTab("USER PROFILES")}
            onMouseLeave={() => setHoveredTab(null)}
          >
            User Profiles
          </button>
        </nav>

        <button onClick={handleLogout} style={styles.logoutButton}>
          Logout
        </button>
      </aside>

      <main style={styles.main}>
        <div style={styles.header}>
          <h1 style={styles.title}>ADMIN DASHBOARD</h1>
        </div>

        <section style={styles.cards}>
          <div style={styles.card}>
            <p style={styles.cardLabel}>
              {isArchivedView ? "Archived Users" : "Active Users"}
            </p>
            <h2 style={styles.cardValue}>{totalUsers}</h2>
          </div>

          <div style={styles.card}>
            <p style={styles.cardLabel}>Verified Emails</p>
            <h2 style={styles.cardValue}>{verifiedUsers}</h2>
          </div>

          <div style={styles.card}>
            <p style={styles.cardLabel}>Unverified Users</p>
            <h2 style={styles.cardValue}>{unverifiedUsers}</h2>
          </div>

          <div style={styles.card}>
            <p style={styles.cardLabel}>Admins</p>
            <h2 style={styles.cardValue}>{adminUsers}</h2>
          </div>
        </section>

        <section style={styles.tableSection}>
          <div style={styles.tableHeader}>
            <h2 style={styles.sectionTitle}>
              {isArchivedView ? "ARCHIVED USERS" : "USERS"}
            </h2>
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

          {!loading && !error && (
            <p style={styles.resultsText}>
              Showing {filteredUsers.length} of {users.length}{" "}
              {isArchivedView ? "archived users" : "users"}
            </p>
          )}

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
      </main>

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
              You are about to archive{" "}
              <strong>{userToArchive.username}</strong>.
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
    background: "#f5f7fb",
    color: "#1f2937",
    fontFamily: "Inter, system-ui, Arial, sans-serif",
  },

  sidebar: {
    width: "255px",
    background: "#111827",
    color: "white",
    padding: "28px 18px",
    display: "flex",
    flexDirection: "column",
    boxSizing: "border-box",
  },

  logo: {
    fontSize: "23px",
    marginBottom: "24px",
    whiteSpace: "nowrap",
  },

  nav: {
    display: "flex",
    flexDirection: "column",
    gap: "12px",
  },

  navItem: {
    background: "transparent",
    color: "#d1d5db",
    border: "none",
    textAlign: "left",
    padding: "12px 12px",
    borderRadius: "12px",
    cursor: "pointer",
    fontSize: "15px",
    fontWeight: "500",
    whiteSpace: "nowrap",
    transition: "all 0.18s ease",
  },

  activeNavItem: {
    background: "transparent",
    color: "#ffffff",
    fontWeight: "800",
    fontSize: "17px",
  },

  hoveredNavItem: {
    background: "transparent",
    color: "#ffffff",
    fontWeight: "700",
    fontSize: "16.5px",
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
  },

  header: {
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    marginBottom: "28px",
  },

  title: {
    fontSize: "34px",
    margin: 0,
    color: "#111827",
    fontWeight: "800",
    letterSpacing: "0.5px",
    textAlign: "center",
  },

  cards: {
    display: "grid",
    gridTemplateColumns: "repeat(4, minmax(0, 1fr))",
    gap: "18px",
    marginBottom: "28px",
  },

  card: {
    background: "white",
    borderRadius: "18px",
    padding: "22px",
    boxShadow: "0 10px 25px rgba(15, 23, 42, 0.08)",
    textAlign: "center",
  },

  cardLabel: {
    color: "#4b5563",
    margin: 0,
    fontSize: "15px",
    fontWeight: "700",
  },

  cardValue: {
    margin: "10px 0 0",
    fontSize: "32px",
    color: "#1e3a8a",
    fontWeight: "800",
  },

  tableSection: {
    background: "white",
    borderRadius: "20px",
    padding: "28px 24px 24px",
    boxShadow: "0 10px 25px rgba(15, 23, 42, 0.08)",
  },

  tableHeader: {
    marginBottom: "22px",
    textAlign: "center",
  },

  sectionTitle: {
    margin: 0,
    fontSize: "26px",
    color: "#111827",
    fontWeight: "800",
    letterSpacing: "1px",
  },

  filtersRow: {
    display: "grid",
    gridTemplateColumns: "minmax(360px, 1.9fr) 170px 210px",
    gap: "12px",
    alignItems: "center",
    marginBottom: "12px",
  },

  searchInput: {
    width: "100%",
    padding: "12px 14px",
    borderRadius: "12px",
    border: "1px solid #d1d5db",
    fontSize: "14px",
    outline: "none",
    boxSizing: "border-box",
  },

  filterSelect: {
    width: "100%",
    padding: "12px 14px",
    borderRadius: "12px",
    border: "1px solid #d1d5db",
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
    overflowX: "auto",
  },

  table: {
    width: "100%",
    borderCollapse: "collapse",
  },

  th: {
    textAlign: "center",
    padding: "18px 14px",
    background: "#f9fafb",
    color: "#374151",
    fontSize: "14px",
    fontWeight: "700",
    letterSpacing: "0.8px",
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
    padding: "16px 14px",
    borderBottom: "1px solid #e5e7eb",
    fontSize: "14px",
    verticalAlign: "middle",
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
    fontSize: "13px",
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
    color: "#1d4ed8",
    padding: "7px 12px",
    borderRadius: "999px",
    cursor: "pointer",
    fontWeight: "700",
    fontSize: "13px",
    minWidth: "74px",
  },

  archiveButton: {
    border: "none",
    background: "#f3f4f6",
    color: "#374151",
    padding: "7px 12px",
    borderRadius: "999px",
    cursor: "pointer",
    fontWeight: "700",
    fontSize: "13px",
    minWidth: "74px",
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
    color: "#b91c1c",
    padding: "7px 12px",
    borderRadius: "999px",
    cursor: "pointer",
    fontWeight: "700",
    fontSize: "13px",
    minWidth: "74px",
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