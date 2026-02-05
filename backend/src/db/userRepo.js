// src/db/userRepo.js

/**
 * Find a user by their email address
 * @param {Object} supabase - Supabase client instance
 * @param {string} email - User's email
 * @returns {Promise<Object|null>} User object or null if not found
 */
export async function findByEmail(supabase, email) {
  const { data, error } = await supabase
    .from("users")
    .select("*")
    .eq("email", email)
    .maybeSingle();
  if (error) throw error;
  return data;
}

/**
 * Find a user by their username
 * @param {Object} supabase - Supabase client instance
 * @param {string} username - User's username
 * @returns {Promise<Object|null>} User object or null if not found
 */
export async function findByUsername(supabase, username) {
  const { data, error } = await supabase
    .from("users")
    .select("*")
    .eq("username", username)
    .maybeSingle();
  if (error) throw error;
  return data;
}

/**
 * Find a user by their ID
 * @param {Object} supabase - Supabase client instance
 * @param {string} id - User's ID (UUID)
 * @returns {Promise<Object|null>} User object or null if not found
 */
export async function findById(supabase, id) {
  const { data, error } = await supabase
    .from("users")
    .select("*")
    .eq("id", id)
    .maybeSingle();
  if (error) throw error;
  return data;
}

/**
 * Create a new Molt (agent) user
 * @param {Object} supabase - Supabase client instance
 * @param {Object} params - Creation parameters
 * @param {string} params.username - Desired username
 * @param {string} params.moltbookHandle - Moltbook handle for verification
 * @returns {Promise<Object>} The created user object
 * @throws Error if creation fails
 */
export async function createMolt(supabase, { username, moltbookHandle }) {
  const { data, error } = await supabase
    .from("users")
    .insert({
      username,
      moltbook_handle: moltbookHandle,
      type: "molt",               // Marks this as an agent/Molt user
      created_at: new Date().toISOString()
      // Add other fields if your schema requires them (e.g., email: null, avatar_url: null)
    })
    .select("*")
    .single();

  if (error) throw error;
  return data;
export async function findByMoltbookHandle(supabase, moltbookHandle) {
  const { data, error } = await supabase
    .from("users")
    .select("*")
    .eq("moltbook_handle", moltbookHandle)
    .maybeSingle();
  if (error) throw error;
  return data;
}
