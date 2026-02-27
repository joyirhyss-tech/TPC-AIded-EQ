// ======================================================
// TPC Board App: Supabase Configuration
// ======================================================
// SETUP: Replace these with your Supabase project credentials
// Find them at: https://supabase.com/dashboard -> Settings -> API

const SUPABASE_URL = 'https://fdzfiizwgvraamgkqggo.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkemZpaXp3Z3ZyYWFtZ2txZ2dvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwNjg5ODUsImV4cCI6MjA4NzY0NDk4NX0.w0ectrTqbWVFrd46GbqPI_T2NnISqFOfTZfGfBTAU3o';

// Initialize Supabase client
// The CDN assigns the library to window.supabase; we replace it with the initialized client.
// All modules reference 'supabase' which resolves to window.supabase in global scope.
void function() {
  const lib = window.supabase;
  window.supabase = lib ? lib.createClient(SUPABASE_URL, SUPABASE_ANON_KEY) : null;
}();

// App constants
const APP = {
  name: 'The Practice Center',
  subtitle: 'Board Management Dashboard',
  orgName: 'The Practice Center',
  boardSize: 6,
  quorumSize: 4,       // Majority needed for approvals
  approvalThreshold: 4, // 4 of 6 for minutes approval
  adminEmails: ['joyirhyss@gmail.com', 'admin@thepracticecenter.org'],
  roles: {
    admin: 'Admin',
    chair: 'Board Chair',
    secretary: 'Secretary',
    member: 'Board Member'
  },
  sections: [
    'AIdedEQ Updates',
    'Programs',
    'Board Business',
    'Revenue & Funding',
    'Open Discussion',
    'Other'
  ],
  // Board seat terms
  termsStartDate: '2025-10-01',
  termsEndDate: '2027-09-30',
  electionDate: '2026-12-01',
  newTermsStart: '2027-01-01'
};

// Check if Supabase is configured
function isSupabaseConfigured() {
  return SUPABASE_URL !== 'YOUR_SUPABASE_URL' && SUPABASE_ANON_KEY !== 'YOUR_SUPABASE_ANON_KEY';
}
