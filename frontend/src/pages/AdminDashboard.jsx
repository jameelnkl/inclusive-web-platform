import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { getToken, logout } from "../services/authService";

function AdminDashboard() {
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState("USERS");
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [searchTerm, setSearchTerm] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [verificationFilter, setVerificationFilter] = useState("");
  const [userToEdit, setUserToEdit] = useState(null);
  const [editFormData, setEditFormData] = useState({ username: "", email: "", password: "" });
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
      if (!token) { navigate("/signin"); return; }
      const endpoint = tab === "ARCHIVED_USERS"
        ? "https://fyp-backend-cbaa.onrender.com/api/admin/users/archived"
        : "https://fyp-backend-cbaa.onrender.com/api/admin/users";
      const response = await fetch(endpoint, { method: "GET", headers: { "X-Auth-Token": token } });
      const data = await response.json();
      if (!response.ok) throw new Error(data.message || "Failed to load users.");
      setUsers(data.users || []);
    } catch (err) {
      setError(err.message || "Something went wrong.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { fetchUsers(activeTab); }, [activeTab]);

  function handleLogout() { logout(); navigate("/signin"); }

  function handleTabChange(tab) {
    setActiveTab(tab);
    setSearchTerm(""); setRoleFilter(""); setVerificationFilter(""); setError("");
  }

  function openEditModal(user) {
    setUserToEdit(user);
    setEditFormData({ username: user.username, email: user.email, password: "" });
    setShowPasswordField(false);
  }

  function handleEditFormChange(e) {
    setEditFormData({ ...editFormData, [e.target.name]: e.target.value });
  }

  async function handleEditUser(e) {
    e.preventDefault();
    if (!userToEdit) return;
    try {
      setEditingUser(true); setActionLoadingId(userToEdit.id);
      const token = getToken();
      if (!token) { navigate("/signin"); return; }
      const response = await fetch(`https://fyp-backend-cbaa.onrender.com/api/admin/users/${userToEdit.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", "X-Auth-Token": token },
        body: JSON.stringify({ username: editFormData.username, email: editFormData.email, password: showPasswordField ? editFormData.password : "" }),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.message || "Failed to update user.");
      setUsers(prev => prev.map(u => u.id === userToEdit.id ? data.user : u));
      setUserToEdit(null); setEditFormData({ username: "", email: "", password: "" }); setShowPasswordField(false);
      if (data.emailVerificationRequired) alert("User updated. Since the email changed, a new verification email was sent.");
    } catch (err) {
      alert(err.message || "Something went wrong.");
    } finally {
      setEditingUser(false); setActionLoadingId(null);
    }
  }

  async function handleArchiveUser() {
    if (!userToArchive) return;
    try {
      setArchivingUser(true); setActionLoadingId(userToArchive.id);
      const token = getToken();
      if (!token) { navigate("/signin"); return; }
      const response = await fetch(`https://fyp-backend-cbaa.onrender.com/api/admin/users/${userToArchive.id}/archive`, {
        method: "PATCH", headers: { "X-Auth-Token": token },
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.message || "Failed to archive user.");
      setUsers(prev => prev.filter(u => u.id !== userToArchive.id));
      setUserToArchive(null);
    } catch (err) {
      alert(err.message || "Something went wrong.");
    } finally {
      setArchivingUser(false); setActionLoadingId(null);
    }
  }

  async function handleRestoreUser(user) {
    try {
      setActionLoadingId(user.id);
      const token = getToken();
      if (!token) { navigate("/signin"); return; }
      const response = await fetch(`https://fyp-backend-cbaa.onrender.com/api/admin/users/${user.id}/restore`, {
        method: "PATCH", headers: { "X-Auth-Token": token },
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.message || "Failed to restore user.");
      setUsers(prev => prev.filter(u => u.id !== user.id));
    } catch (err) {
      alert(err.message || "Something went wrong.");
    } finally {
      setActionLoadingId(null);
    }
  }

  async function handleDeleteUser() {
    if (!userToDelete) return;
    try {
      setDeletingUser(true);
      const token = getToken();
      if (!token) { navigate("/signin"); return; }
      const response = await fetch(`https://fyp-backend-cbaa.onrender.com/api/admin/users/${userToDelete.id}`, {
        method: "DELETE", headers: { "X-Auth-Token": token },
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.message || "Failed to delete user.");
      setUsers(prev => prev.filter(u => u.id !== userToDelete.id));
      setUserToDelete(null);
    } catch (err) {
      alert(err.message || "Something went wrong.");
    } finally {
      setDeletingUser(false);
    }
  }

  function getMainRole(user) {
    if (user.roles.includes("ROLE_ADMIN")) return "ADMIN";
    if (user.roles.includes("ROLE_EMPLOYER")) return "EMPLOYER";
    if (user.roles.includes("ROLE_CANDIDATE")) return "CANDIDATE";
    return "USER";
  }

  function formatRole(user) {
    const r = getMainRole(user);
    if (r === "ADMIN") return "Admin";
    if (r === "EMPLOYER") return "Employer";
    if (r === "CANDIDATE") return "Candidate";
    return "User";
  }

  const totalUsers = users.length;
  const verifiedUsers = users.filter(u => u.isVerified).length;
  const unverifiedUsers = users.filter(u => !u.isVerified).length;
  const adminUsers = users.filter(u => u.roles.includes("ROLE_ADMIN")).length;

  const filteredUsers = users.filter(user => {
    const s = searchTerm.toLowerCase().trim();
    const matchesSearch = user.username.toLowerCase().includes(s) || user.email.toLowerCase().includes(s);
    const mainRole = getMainRole(user);
    const matchesRole = roleFilter === "" || mainRole === roleFilter;
    const matchesVerification = verificationFilter === "" ||
      (verificationFilter === "VERIFIED" && user.isVerified) ||
      (verificationFilter === "UNVERIFIED" && !user.isVerified);
    return matchesSearch && matchesRole && matchesVerification;
  });

  const roleColors = {
    Admin: { bg: "#fef3c7", color: "#92400e" },
    Employer: { bg: "#ede9fe", color: "#5b21b6" },
    Candidate: { bg: "#dbeafe", color: "#1e40af" },
    User: { bg: "#eef2ff", color: "#3730a3" },
  };

  const navItems = [
    { key: "USERS", label: "👥 Users" },
    { key: "ARCHIVED_USERS", label: "📦 Archived Users" },
    { key: "APPLICATIONS", label: "📋 Applications" },
    { key: "USER_PROFILES", label: "🪪 User Profiles" },
  ];

  return (
    <div style={s.page}>
      {/* Sidebar */}
      <aside style={s.sidebar}>
        <div style={s.sidebarLogo}>
          <div style={s.logoIcon}>JH</div>
          <span style={s.logoText}>Admin Panel</span>
        </div>

        <nav style={s.nav}>
          {navItems.map(item => (
            <button
              key={item.key}
              style={{ ...s.navItem, ...(activeTab === item.key ? s.navItemActive : {}) }}
              onClick={() => handleTabChange(item.key)}
            >
              {item.label}
              {activeTab === item.key && <span style={s.navDot} />}
            </button>
          ))}
        </nav>

        <button onClick={handleLogout} style={s.logoutBtn}>
          🚪 Logout
        </button>
      </aside>

      {/* Main */}
      <main style={s.main}>
        {/* Header */}
        <div style={s.topBar}>
          <div>
            <h1 style={s.pageTitle}>Admin Dashboard</h1>
            <p style={s.pageSubtitle}>Manage users, applications and platform settings</p>
          </div>
          <div style={s.adminBadge}>⚡ Super Admin</div>
        </div>

        {/* Stat Cards */}
        <div style={s.statsGrid}>
          {[
            { label: isArchivedView ? "Archived Users" : "Active Users", value: totalUsers, icon: "👥", color: "#3b82f6" },
            { label: "Verified Emails", value: verifiedUsers, icon: "✅", color: "#10b981" },
            { label: "Unverified Users", value: unverifiedUsers, icon: "⏳", color: "#f59e0b" },
            { label: "Admins", value: adminUsers, icon: "🛡️", color: "#8b5cf6" },
          ].map((stat, i) => (
            <div key={i} style={s.statCard}>
              <div style={{ ...s.statIcon, background: stat.color + "18" }}>{stat.icon}</div>
              <div>
                <p style={s.statLabel}>{stat.label}</p>
                <h2 style={{ ...s.statValue, color: stat.color }}>{stat.value}</h2>
              </div>
            </div>
          ))}
        </div>

        {/* Table Section */}
        <div style={s.tableCard}>
          <div style={s.tableTopBar}>
            <h2 style={s.tableTitle}>{isArchivedView ? "📦 Archived Users" : "👥 Users"}</h2>
            <span style={s.tableCount}>{filteredUsers.length} of {users.length}</span>
          </div>

          <div style={s.filtersRow}>
            <input
              type="text"
              placeholder="🔍 Search by username or email..."
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
              style={s.searchInput}
            />
            <select value={roleFilter} onChange={e => setRoleFilter(e.target.value === "RESET" ? "" : e.target.value)} style={s.filterSelect}>
              <option value="" disabled hidden>Filter by Role</option>
              <option value="RESET">All Roles</option>
              <option value="ADMIN">Admin</option>
              <option value="CANDIDATE">Candidate</option>
              <option value="EMPLOYER">Employer</option>
              <option value="USER">User</option>
            </select>
            <select value={verificationFilter} onChange={e => setVerificationFilter(e.target.value === "RESET" ? "" : e.target.value)} style={s.filterSelect}>
              <option value="" disabled hidden>Filter by Status</option>
              <option value="RESET">All Statuses</option>
              <option value="VERIFIED">Verified</option>
              <option value="UNVERIFIED">Unverified</option>
            </select>
          </div>

          {loading && <p style={s.infoText}>⏳ Loading users...</p>}
          {error && <p style={s.errorText}>⚠️ {error}</p>}

          {!loading && !error && (
            <div style={s.tableWrapper}>
              <table style={s.table}>
                <thead>
                  <tr>
                    {["#", "Username", "Email", "Role", "Status", "Actions"].map(h => (
                      <th key={h} style={s.th}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {filteredUsers.map((user, index) => (
                    <tr key={user.id} style={s.tr}>
                      <td style={s.td}><span style={s.rowNum}>{index + 1}</span></td>
                      <td style={s.td}><strong>{user.username}</strong></td>
                      <td style={s.td}><span style={s.email}>{user.email}</span></td>
                      <td style={s.td}>
                        <span style={{ ...s.badge, background: roleColors[formatRole(user)]?.bg, color: roleColors[formatRole(user)]?.color }}>
                          {formatRole(user)}
                        </span>
                      </td>
                      <td style={s.td}>
                        <span style={{ ...s.badge, ...(user.isVerified ? s.verified : s.unverified) }}>
                          {user.isVerified ? "✓ Verified" : "⏳ Unverified"}
                        </span>
                      </td>
                      <td style={s.td}>
                        <div style={s.actions}>
                          {!isArchivedView ? (
                            <>
                              <button style={s.btnEdit} onClick={() => openEditModal(user)} disabled={actionLoadingId === user.id}>Edit</button>
                              <button style={s.btnArchive} onClick={() => setUserToArchive(user)} disabled={actionLoadingId === user.id}>Archive</button>
                              <button style={s.btnDelete} onClick={() => setUserToDelete(user)}>Delete</button>
                            </>
                          ) : (
                            <>
                              <button style={s.btnRestore} onClick={() => handleRestoreUser(user)} disabled={actionLoadingId === user.id}>
                                {actionLoadingId === user.id ? "..." : "Restore"}
                              </button>
                              <button style={s.btnDelete} onClick={() => setUserToDelete(user)}>Delete</button>
                            </>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {filteredUsers.length === 0 && <p style={s.infoText}>No users match your filters.</p>}
            </div>
          )}
        </div>
      </main>

      {/* Edit Modal */}
      {userToEdit && (
        <div style={s.overlay}>
          <div style={s.modal}>
            <h2 style={s.modalTitle}>✏️ Edit User</h2>
            <p style={s.modalSubtitle}>Updating <strong>{userToEdit.username}</strong>&apos;s account</p>
            <form onSubmit={handleEditUser} style={s.modalForm}>
              <div style={s.modalField}>
                <label style={s.modalLabel}>Username</label>
                <input type="text" name="username" value={editFormData.username} onChange={handleEditFormChange} style={s.modalInput} />
              </div>
              <div style={s.modalField}>
                <label style={s.modalLabel}>Email</label>
                <input type="email" name="email" value={editFormData.email} onChange={handleEditFormChange} style={s.modalInput} />
              </div>
              <div style={s.emailNote}>📧 If email is changed, user will need to re-verify.</div>
              <button type="button" onClick={() => { setShowPasswordField(p => !p); setEditFormData(d => ({ ...d, password: "" })); }} style={s.btnChangePass}>
                {showPasswordField ? "Cancel password change" : "🔐 Change Password"}
              </button>
              {showPasswordField && (
                <div style={s.modalField}>
                  <label style={s.modalLabel}>New Password</label>
                  <input type="password" name="password" value={editFormData.password} onChange={handleEditFormChange} style={s.modalInput} placeholder="Enter new password" />
                </div>
              )}
              <div style={s.modalActions}>
                <button type="button" onClick={() => { setUserToEdit(null); setShowPasswordField(false); }} style={s.btnCancel} disabled={editingUser}>Cancel</button>
                <button type="submit" style={s.btnConfirmEdit} disabled={editingUser}>{editingUser ? "Saving..." : "Save Changes"}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Archive Modal */}
      {userToArchive && (
        <div style={s.overlay}>
          <div style={{ ...s.modal, textAlign: "center" }}>
            <div style={s.modalIconBox}>📦</div>
            <h2 style={s.modalTitle}>Archive User?</h2>
            <p style={s.modalSubtitle}>You are about to archive <strong>{userToArchive.username}</strong>. They will be moved to Archived Users.</p>
            <div style={s.modalActions}>
              <button onClick={() => setUserToArchive(null)} style={s.btnCancel} disabled={archivingUser}>Cancel</button>
              <button onClick={handleArchiveUser} style={s.btnConfirmArchive} disabled={archivingUser}>{archivingUser ? "Archiving..." : "Archive User"}</button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Modal */}
      {userToDelete && (
        <div style={s.overlay}>
          <div style={{ ...s.modal, textAlign: "center" }}>
            <div style={s.modalIconBox}>🗑️</div>
            <h2 style={s.modalTitle}>Delete User?</h2>
            <p style={s.modalSubtitle}>You are about to permanently delete <strong>{userToDelete.username}</strong>.</p>
            <p style={s.modalWarning}>⚠️ This action cannot be undone.</p>
            <div style={s.modalActions}>
              <button onClick={() => setUserToDelete(null)} style={s.btnCancel} disabled={deletingUser}>Cancel</button>
              <button onClick={handleDeleteUser} style={s.btnConfirmDelete} disabled={deletingUser}>{deletingUser ? "Deleting..." : "Delete User"}</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

const s = {
  page: { minHeight: "100vh", display: "flex", background: "#f0f4ff", fontFamily: "'Segoe UI', system-ui, sans-serif" },

  // Sidebar
  sidebar: { width: "260px", background: "linear-gradient(180deg, #0f172a 0%, #1e293b 100%)", color: "white", padding: "28px 16px", display: "flex", flexDirection: "column", gap: "8px", boxShadow: "4px 0 24px rgba(0,0,0,0.15)" },
  sidebarLogo: { display: "flex", alignItems: "center", gap: "12px", marginBottom: "32px", padding: "0 8px" },
  logoIcon: { width: "40px", height: "40px", borderRadius: "12px", background: "linear-gradient(135deg, #3b82f6, #1d4ed8)", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: "800", fontSize: "14px" },
  logoText: { fontSize: "18px", fontWeight: "700", color: "white" },
  nav: { display: "flex", flexDirection: "column", gap: "4px", flex: 1 },
  navItem: { background: "transparent", color: "#94a3b8", border: "none", textAlign: "left", padding: "12px 16px", borderRadius: "12px", cursor: "pointer", fontSize: "14px", fontWeight: "500", transition: "all 0.2s ease", display: "flex", alignItems: "center", justifyContent: "space-between" },
  navItemActive: { background: "rgba(59, 130, 246, 0.15)", color: "white", fontWeight: "700" },
  navDot: { width: "6px", height: "6px", borderRadius: "50%", background: "#3b82f6" },
  logoutBtn: { background: "rgba(239, 68, 68, 0.15)", color: "#f87171", border: "1px solid rgba(239, 68, 68, 0.2)", padding: "12px 16px", borderRadius: "12px", cursor: "pointer", fontWeight: "600", fontSize: "14px", textAlign: "left", marginTop: "16px" },

  // Main
  main: { flex: 1, padding: "32px", overflowY: "auto" },
  topBar: { display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "28px" },
  pageTitle: { margin: "0 0 4px", fontSize: "28px", fontWeight: "800", color: "#0f172a" },
  pageSubtitle: { margin: 0, color: "#64748b", fontSize: "14px" },
  adminBadge: { background: "linear-gradient(135deg, #3b82f6, #1d4ed8)", color: "white", padding: "8px 16px", borderRadius: "999px", fontSize: "13px", fontWeight: "700", boxShadow: "0 4px 12px rgba(59,130,246,0.3)" },

  // Stats
  statsGrid: { display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: "16px", marginBottom: "24px" },
  statCard: { background: "white", borderRadius: "16px", padding: "20px", boxShadow: "0 1px 3px rgba(0,0,0,0.06)", display: "flex", alignItems: "center", gap: "16px", border: "1px solid #e2e8f0" },
  statIcon: { width: "48px", height: "48px", borderRadius: "14px", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "22px", flexShrink: 0 },
  statLabel: { margin: "0 0 4px", fontSize: "12px", color: "#64748b", fontWeight: "600", textTransform: "uppercase", letterSpacing: "0.5px" },
  statValue: { margin: 0, fontSize: "28px", fontWeight: "800" },

  // Table Card
  tableCard: { background: "white", borderRadius: "20px", padding: "24px", boxShadow: "0 1px 3px rgba(0,0,0,0.06)", border: "1px solid #e2e8f0" },
  tableTopBar: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "20px" },
  tableTitle: { margin: 0, fontSize: "18px", fontWeight: "700", color: "#0f172a" },
  tableCount: { background: "#f1f5f9", color: "#64748b", padding: "4px 12px", borderRadius: "999px", fontSize: "13px", fontWeight: "600" },

  // Filters
  filtersRow: { display: "grid", gridTemplateColumns: "1fr 180px 180px", gap: "12px", marginBottom: "16px" },
  searchInput: { padding: "11px 16px", borderRadius: "12px", border: "1.5px solid #e2e8f0", fontSize: "14px", outline: "none", background: "#f8fafc", boxSizing: "border-box", width: "100%" },
  filterSelect: { padding: "11px 14px", borderRadius: "12px", border: "1.5px solid #e2e8f0", fontSize: "14px", background: "#f8fafc", cursor: "pointer", outline: "none", boxSizing: "border-box", width: "100%" },

  // Table
  tableWrapper: { overflowX: "auto" },
  table: { width: "100%", borderCollapse: "collapse" },
  th: { padding: "12px 16px", background: "#f8fafc", color: "#64748b", fontSize: "12px", fontWeight: "700", letterSpacing: "0.8px", textTransform: "uppercase", borderBottom: "1px solid #e2e8f0", textAlign: "left" },
  tr: { transition: "background 0.15s ease" },
  td: { padding: "14px 16px", borderBottom: "1px solid #f1f5f9", fontSize: "14px", color: "#1e293b", verticalAlign: "middle" },
  rowNum: { background: "#f1f5f9", color: "#64748b", padding: "2px 8px", borderRadius: "6px", fontSize: "12px", fontWeight: "700" },
  email: { color: "#64748b", fontSize: "13px" },
  badge: { padding: "4px 12px", borderRadius: "999px", fontSize: "12px", fontWeight: "700", display: "inline-block" },
  verified: { background: "#dcfce7", color: "#166534" },
  unverified: { background: "#fef3c7", color: "#92400e" },

  // Actions
  actions: { display: "flex", gap: "6px", flexWrap: "wrap" },
  btnEdit: { padding: "6px 12px", borderRadius: "8px", border: "none", background: "#eff6ff", color: "#1d4ed8", fontWeight: "700", fontSize: "12px", cursor: "pointer" },
  btnArchive: { padding: "6px 12px", borderRadius: "8px", border: "none", background: "#f1f5f9", color: "#475569", fontWeight: "700", fontSize: "12px", cursor: "pointer" },
  btnRestore: { padding: "6px 12px", borderRadius: "8px", border: "none", background: "#dcfce7", color: "#166534", fontWeight: "700", fontSize: "12px", cursor: "pointer" },
  btnDelete: { padding: "6px 12px", borderRadius: "8px", border: "none", background: "#fee2e2", color: "#b91c1c", fontWeight: "700", fontSize: "12px", cursor: "pointer" },

  // Modal
  overlay: { position: "fixed", inset: 0, background: "rgba(15,23,42,0.6)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000, padding: "20px", backdropFilter: "blur(4px)" },
  modal: { width: "100%", maxWidth: "460px", background: "white", borderRadius: "20px", padding: "32px", boxShadow: "0 25px 50px rgba(15,23,42,0.25)" },
  modalIconBox: { fontSize: "40px", marginBottom: "16px" },
  modalTitle: { margin: "0 0 8px", fontSize: "20px", fontWeight: "800", color: "#0f172a" },
  modalSubtitle: { margin: "0 0 20px", color: "#64748b", fontSize: "14px", lineHeight: "1.6" },
  modalWarning: { color: "#dc2626", fontWeight: "700", fontSize: "13px", margin: "0 0 20px" },
  modalForm: { display: "flex", flexDirection: "column", gap: "16px" },
  modalField: { display: "flex", flexDirection: "column", gap: "6px" },
  modalLabel: { fontSize: "13px", fontWeight: "700", color: "#374151" },
  modalInput: { padding: "11px 14px", borderRadius: "12px", border: "1.5px solid #e2e8f0", fontSize: "14px", outline: "none", boxSizing: "border-box" },
  emailNote: { background: "#eff6ff", color: "#1d4ed8", padding: "10px 14px", borderRadius: "10px", fontSize: "13px", fontWeight: "600" },
  btnChangePass: { border: "1.5px solid #3b82f6", background: "white", color: "#1d4ed8", padding: "10px 14px", borderRadius: "10px", cursor: "pointer", fontWeight: "700", fontSize: "13px", alignSelf: "flex-start" },
  modalActions: { display: "flex", justifyContent: "flex-end", gap: "10px", marginTop: "8px" },
  btnCancel: { border: "1.5px solid #e2e8f0", background: "white", color: "#374151", padding: "10px 18px", borderRadius: "10px", cursor: "pointer", fontWeight: "600", fontSize: "14px" },
  btnConfirmEdit: { border: "none", background: "linear-gradient(135deg, #3b82f6, #1d4ed8)", color: "white", padding: "10px 18px", borderRadius: "10px", cursor: "pointer", fontWeight: "700", fontSize: "14px", boxShadow: "0 4px 12px rgba(59,130,246,0.3)" },
  btnConfirmArchive: { border: "none", background: "#92400e", color: "white", padding: "10px 18px", borderRadius: "10px", cursor: "pointer", fontWeight: "700", fontSize: "14px" },
  btnConfirmDelete: { border: "none", background: "linear-gradient(135deg, #ef4444, #dc2626)", color: "white", padding: "10px 18px", borderRadius: "10px", cursor: "pointer", fontWeight: "700", fontSize: "14px", boxShadow: "0 4px 12px rgba(239,68,68,0.3)" },

  infoText: { color: "#64748b", textAlign: "center", padding: "32px 0", fontSize: "15px" },
  errorText: { color: "#dc2626", textAlign: "center", padding: "16px 0", fontWeight: "600" },
};

export default AdminDashboard;
