// Learnora — Supabase config
// These are the PUBLIC url + anon key from Project Settings → API.
// Safe to leave visible in frontend code — access is controlled by
// Row Level Security policies on the database, not by hiding this key.

const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL"; // e.g. https://xxxxx.supabase.co
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
