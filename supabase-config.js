/* ===========================================================
   Supabase connection + shared sign-in helpers
   Every page loads this file, so the project URL and key live in
   ONE place. Fill in the two values below (Supabase dashboard ->
   Project Settings -> API).

   The anon / publishable key is DESIGNED to be public — it is safe
   in a GitHub Pages site. What actually protects your data is the
   Row Level Security policies created by supabase-setup.sql.
   NEVER put the service_role / secret key in this file.
=========================================================== */

const SUPABASE_URL = "https://YOUR-PROJECT-REF.supabase.co";
const SUPABASE_ANON_KEY = "YOUR-ANON-OR-PUBLISHABLE-KEY";

const supabaseConfigured =
  !SUPABASE_URL.includes("YOUR-PROJECT-REF") && !SUPABASE_ANON_KEY.startsWith("YOUR-");

// `sb` is null until the two values above are filled in, so the planner
// still works (using just the JSON files) while you're setting things up.
const sb =
  supabaseConfigured && window.supabase
    ? window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
        auth: { persistSession: true, autoRefreshToken: true },
      })
    : null;

async function getCurrentUser() {
  if (!sb) return null;
  const { data } = await sb.auth.getSession();
  return data && data.session ? data.session.user : null;
}

// Name shown next to "Added by". Comes from the meal_profiles table;
// falls back to the part of the email before the @.
async function getDisplayName(user) {
  try {
    const { data } = await sb
      .from("meal_profiles")
      .select("display_name")
      .eq("id", user.id)
      .maybeSingle();
    if (data && data.display_name) return data.display_name;
  } catch (e) {
    /* fall through to the fallback */
  }
  return (user.email || "member").split("@")[0];
}

async function signOutAndGoHome() {
  await sb.auth.signOut();
  location.href = "index.html";
}

// Fills <span id="auth-nav"> in the nav bar:
//   signed out -> "Sign in"
//   signed in  -> "Add recipe", the user's name, and "Sign out"
// `activePage` is "add" or "login" so the right link is highlighted.
async function renderAuthNav(activePage) {
  const el = document.getElementById("auth-nav");
  if (!el) return;
  el.innerHTML = "";

  const user = await getCurrentUser();

  if (!user) {
    const a = document.createElement("a");
    a.href = "login.html";
    a.className = "nav-link" + (activePage === "login" ? " is-active" : "");
    if (activePage === "login") a.setAttribute("aria-current", "page");
    a.textContent = "Sign in";
    el.appendChild(a);
    return;
  }

  const add = document.createElement("a");
  add.href = "add.html";
  add.className = "nav-link" + (activePage === "add" ? " is-active" : "");
  if (activePage === "add") add.setAttribute("aria-current", "page");
  add.textContent = "Add recipe";
  el.appendChild(add);

  const who = document.createElement("span");
  who.className = "nav-user";
  who.textContent = await getDisplayName(user);
  el.appendChild(who);

  const out = document.createElement("button");
  out.type = "button";
  out.className = "nav-link";
  out.textContent = "Sign out";
  out.addEventListener("click", signOutAndGoHome);
  el.appendChild(out);
}
