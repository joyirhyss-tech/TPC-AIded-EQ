// ======================================================
// TPC Board App: Authentication Module
// ======================================================

const Auth = {
  currentUser: null,
  currentProfile: null,

  // Initialize auth state
  async init() {
    if (!isSupabaseConfigured()) {
      console.warn('Supabase not configured. Running in demo mode.');
      this.currentUser = { id: 'demo', email: 'demo@thepracticecenter.org' };
      this.currentProfile = { id: 'demo', email: 'demo@thepracticecenter.org', full_name: 'Demo User', role: 'admin' };
      return this.currentProfile;
    }

    const { data: { session } } = await supabase.auth.getSession();
    if (session) {
      this.currentUser = session.user;
      await this.loadProfile();
    }

    // Listen for auth state changes
    supabase.auth.onAuthStateChange(async (event, session) => {
      if (event === 'SIGNED_IN' && session) {
        this.currentUser = session.user;
        await this.loadProfile();
      } else if (event === 'SIGNED_OUT') {
        this.currentUser = null;
        this.currentProfile = null;
      }
    });

    return this.currentProfile;
  },

  // Load user profile from profiles table
  async loadProfile() {
    if (!this.currentUser) return null;
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', this.currentUser.id)
      .single();
    if (data) this.currentProfile = data;
    return this.currentProfile;
  },

  // Login with email + password
  async login(email, password) {
    if (!isSupabaseConfigured()) {
      Toast.show('Demo mode: logged in as admin', 'info');
      window.location.href = 'dashboard.html';
      return { success: true };
    }
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return { success: false, error: error.message };
    this.currentUser = data.user;
    await this.loadProfile();
    return { success: true };
  },

  // Send magic link
  async sendMagicLink(email) {
    if (!isSupabaseConfigured()) {
      Toast.show('Demo mode: magic link not available', 'info');
      return { success: false, error: 'Configure Supabase first' };
    }
    const { error } = await supabase.auth.signInWithOtp({ email });
    if (error) return { success: false, error: error.message };
    return { success: true };
  },

  // Logout
  async logout() {
    if (isSupabaseConfigured()) {
      await supabase.auth.signOut();
    }
    this.currentUser = null;
    this.currentProfile = null;
    window.location.href = 'index.html';
  },

  // Check if user is logged in
  isLoggedIn() {
    return !!this.currentUser;
  },

  // Get current user role
  getRole() {
    return this.currentProfile?.role || 'member';
  },

  // Check role
  isAdmin() { return this.getRole() === 'admin'; },
  isChair() { return this.getRole() === 'chair'; },
  isSecretary() { return this.getRole() === 'secretary'; },
  canManageAgenda() { return ['admin', 'chair', 'secretary'].includes(this.getRole()); },
  canTakeNotes() { return ['admin', 'secretary'].includes(this.getRole()); },

  // Get initials for avatar
  getInitials() {
    const name = this.currentProfile?.full_name || '';
    return name.split(' ').map(w => w[0]).join('').toUpperCase().substring(0, 2);
  },

  // Protect page: redirect if not logged in
  async requireAuth() {
    await this.init();
    if (!this.isLoggedIn()) {
      window.location.href = 'index.html';
      return false;
    }
    return true;
  },

  // Protect page: require specific role
  async requireRole(roles) {
    const authed = await this.requireAuth();
    if (!authed) return false;
    if (!roles.includes(this.getRole())) {
      Toast.show('You do not have permission to view this page.', 'error');
      window.location.href = 'dashboard.html';
      return false;
    }
    return true;
  }
};
