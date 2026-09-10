// ThinkTrail.AI — Supabase config
// These are the PUBLIC url + anon key from Project Settings → API.
// Safe to leave visible in frontend code — access is controlled by
// Row Level Security policies on the database, not by hiding this key.

const SUPABASE_URL = "https://usmaeutdgtrzyxuooosy.supabase.co"; // e.g. https://xxxxx.supabase.co
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzbWFldXRkZ3Ryenl4dW9vb3N5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkwMjM1ODAsImV4cCI6MjEwNDU5OTU4MH0.rkstIdPy2EBN9e5-NY8QaC_VwTD73x83gMFBmiXVCrk";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
