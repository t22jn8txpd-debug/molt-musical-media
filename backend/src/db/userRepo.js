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
  const placeholderEmail = `${moltbookHandle.toLowerCase()}@molt.local`;
  const { data, error } = await supabase
    .from("users")
    .insert({
      username,
      email: placeholderEmail,
      moltbook_handle: moltbookHandle,
      type: "molt",
      provider: "moltbook",
      created_at: new Date().toISOString()
    })
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function createHuman(supabase, { email, username, passwordHash }) {
  const { data, error } = await supabase
    .from("users")
    .insert({
      email,
      username,
      password_hash: passwordHash,
      type: "human",
      provider: "email",
      created_at: new Date().toISOString()
    })
    .select("*")
    .single();
  if (error) throw error;
  return data;
}

export async function updateLoginTimestamp(supabase, id) {
  const { error } = await supabase
    .from("users")
    .update({ last_login_at: new Date().toISOString() })
    .eq("id", id);
  if (error) throw error;
}

export async function updateProfile(supabase, id, { username, bio, avatarUrl }) {
  const updates = {};
  if (username !== undefined) updates.username = username;
  if (bio !== undefined) updates.bio = bio;
  if (avatarUrl !== undefined) updates.avatar_url = avatarUrl;

  const { data, error } = await supabase
    .from("users")
    .update(updates)
    .eq("id", id)
    .select("*")
    .single();
  if (error) throw error;
  return data;
}

export async function findByMoltbookHandle(supabase, moltbookHandle) {
  const { data, error } = await supabase
    .from("users")
    .select("*")
    .eq("moltbook_handle", moltbookHandle)
    .maybeSingle();
  if (error) throw error;
  return data;
}
