// ======================================================
// TPC Board App: Utilities
// ======================================================

// Toast notification system
const Toast = {
  container: null,

  init() {
    if (this.container) return;
    this.container = document.createElement('div');
    this.container.className = 'toast-container';
    document.body.appendChild(this.container);
  },

  show(message, type = 'info', duration = 3500) {
    this.init();
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    this.container.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateX(100%)';
      toast.style.transition = '0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, duration);
  }
};

// Date formatting
function formatDate(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr + 'T00:00:00');
  return d.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
}

function formatDateShort(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr + 'T00:00:00');
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

function formatTime(timeStr) {
  if (!timeStr) return '';
  const [h, m] = timeStr.split(':');
  const hour = parseInt(h);
  const ampm = hour >= 12 ? 'PM' : 'AM';
  const hour12 = hour % 12 || 12;
  return `${hour12}:${m} ${ampm}`;
}

// Timer formatting
function formatTimer(seconds) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  if (h > 0) return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  return `${m}:${String(s).padStart(2, '0')}`;
}

// Days until a date
function daysUntil(dateStr) {
  const target = new Date(dateStr + 'T00:00:00');
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return Math.ceil((target - today) / (1000 * 60 * 60 * 24));
}

// Escape HTML
function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

// Debounce
function debounce(fn, delay = 500) {
  let timer;
  return function (...args) {
    clearTimeout(timer);
    timer = setTimeout(() => fn.apply(this, args), delay);
  };
}

// Generate sidebar HTML (shared across pages)
function renderSidebar(activePage) {
  const user = Auth.currentProfile || {};
  const role = Auth.getRole();
  const initials = Auth.getInitials() || '?';

  return `
    <div class="sidebar-header">
      <h1>The Practice Center</h1>
      <div class="subtitle">Board Management</div>
    </div>
    <div class="sidebar-user">
      <div class="avatar">${escapeHtml(initials)}</div>
      <div class="user-info">
        <div class="user-name">${escapeHtml(user.full_name || 'Board Member')}</div>
        <div class="user-role">${escapeHtml(APP.roles[role] || 'Member')}</div>
      </div>
    </div>
    <div class="sidebar-nav">
      <div class="nav-section-label">Navigation</div>
      <a href="dashboard.html" class="nav-link ${activePage === 'dashboard' ? 'active' : ''}">
        <svg viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        Dashboard
      </a>
      <a href="agenda.html" class="nav-link ${activePage === 'agenda' ? 'active' : ''}">
        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
        Agenda
      </a>
      <a href="meeting.html" class="nav-link ${activePage === 'meeting' ? 'active' : ''}">
        <svg viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
        Live Meeting
      </a>
      <a href="minutes.html" class="nav-link ${activePage === 'minutes' ? 'active' : ''}">
        <svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
        Minutes
      </a>

      <div class="nav-section-label">Records</div>
      <a href="archive.html" class="nav-link ${activePage === 'archive' ? 'active' : ''}">
        <svg viewBox="0 0 24 24"><polyline points="21 8 21 21 3 21 3 8"/><rect x="1" y="3" width="22" height="5"/><line x1="10" y1="12" x2="14" y2="12"/></svg>
        Archive
      </a>
      <a href="governance.html" class="nav-link ${activePage === 'governance' ? 'active' : ''}">
        <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        Governance
      </a>

      ${['admin', 'chair'].includes(role) ? `
      <div class="nav-section-label">Admin</div>
      <a href="admin.html" class="nav-link ${activePage === 'admin' ? 'active' : ''}">
        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 01-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>
        Admin
      </a>` : ''}
    </div>
    <div class="sidebar-footer">
      <a href="#" class="nav-link" onclick="Auth.logout(); return false;">
        <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
        Sign Out
      </a>
    </div>
  `;
}

// Render page shell (call on each protected page)
async function initPage(pageName) {
  const authed = await Auth.requireAuth();
  if (!authed) return false;
  const sidebar = document.getElementById('sidebar');
  if (sidebar) {
    sidebar.innerHTML = renderSidebar(pageName);
    // Add mobile hamburger menu and backdrop
    if (!document.getElementById('mobileMenuBtn')) {
      const btn = document.createElement('button');
      btn.id = 'mobileMenuBtn';
      btn.className = 'mobile-menu-btn';
      btn.setAttribute('aria-label', 'Toggle menu');
      btn.innerHTML = '<svg viewBox="0 0 24 24"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>';
      document.body.appendChild(btn);

      const backdrop = document.createElement('div');
      backdrop.id = 'sidebarBackdrop';
      backdrop.className = 'sidebar-backdrop';
      document.body.appendChild(backdrop);

      function toggleMenu() {
        sidebar.classList.toggle('open');
        backdrop.classList.toggle('active');
        const isOpen = sidebar.classList.contains('open');
        btn.innerHTML = isOpen
          ? '<svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>'
          : '<svg viewBox="0 0 24 24"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>';
      }
      btn.addEventListener('click', toggleMenu);
      backdrop.addEventListener('click', toggleMenu);
      // Close sidebar when a nav link is clicked (mobile)
      sidebar.addEventListener('click', function(e) {
        if (e.target.closest('.nav-link') && sidebar.classList.contains('open')) {
          toggleMenu();
        }
      });
    }
  }
  return true;
}

// TPC Logo SVG
const TPC_LOGO = `<svg viewBox="0 0 200 80" xmlns="http://www.w3.org/2000/svg" style="max-width:200px;">
  <rect x="0" y="0" width="200" height="80" rx="8" fill="#1a1520"/>
  <rect x="2" y="2" width="196" height="76" rx="7" fill="none" stroke="#c8a961" stroke-width="1.5"/>
  <line x1="20" y1="18" x2="180" y2="18" stroke="#c8a961" stroke-width="0.5" opacity="0.6"/>
  <line x1="20" y1="62" x2="180" y2="62" stroke="#c8a961" stroke-width="0.5" opacity="0.6"/>
  <text x="100" y="13" text-anchor="middle" font-family="Georgia,serif" font-size="7" font-weight="400" fill="#c8a961" letter-spacing="4">EST. 2024</text>
  <text x="100" y="47" text-anchor="middle" font-family="Georgia,serif" font-size="32" font-weight="700" fill="#ffffff" letter-spacing="8">TPC</text>
  <text x="100" y="73" text-anchor="middle" font-family="Georgia,serif" font-size="7.5" font-weight="400" fill="#c8a961" letter-spacing="3">THE PRACTICE CENTER</text>
</svg>`;
