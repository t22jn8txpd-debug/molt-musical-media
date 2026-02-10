export async function createRefreshToken(
  supabase,
  { userId, tokenHash, expiresAt, userAgent, ip }
) {
  const { data, error } = await supabase
    .from("refresh_tokens")
    .insert({
      user_id: userId,
      token_hash: tokenHash,
      expires_at: expiresAt,
      user_agent: userAgent || null,
      ip: ip || null
    })
    .select("*")
    .single();
  if (error) throw error;
  return data;
}

export async function findRefreshTokenByHash(supabase, tokenHash) {
  const { data, error } = await supabase
    .from("refresh_tokens")
    .select("*")
    .eq("token_hash", tokenHash)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function markRefreshTokenUsed(supabase, id) {
  const { error } = await supabase
    .from("refresh_tokens")
    .update({ last_used_at: new Date().toISOString() })
    .eq("id", id);
  if (error) throw error;
}

export async function revokeRefreshToken(supabase, id, replacedBy = null) {
  const updates = {
    revoked_at: new Date().toISOString(),
    replaced_by: replacedBy
  };
  const { error } = await supabase.from("refresh_tokens").update(updates).eq("id", id);
  if (error) throw error;
}

export async function revokeAllRefreshTokens(supabase, userId) {
  const { error } = await supabase
    .from("refresh_tokens")
    .update({ revoked_at: new Date().toISOString() })
    .eq("user_id", userId)
    .is("revoked_at", null);
  if (error) throw error;
}

export async function listActiveSessions(supabase, userId) {
  const { data, error } = await supabase
    .from("refresh_tokens")
    .select("id, created_at, last_used_at, expires_at, user_agent, ip")
    .eq("user_id", userId)
    .is("revoked_at", null)
    .gt("expires_at", new Date().toISOString())
    .order("created_at", { ascending: false });
  if (error) throw error;
  return data || [];
}

export async function revokeSessionById(supabase, userId, sessionId) {
  const { error } = await supabase
    .from("refresh_tokens")
    .update({ revoked_at: new Date().toISOString() })
    .eq("id", sessionId)
    .eq("user_id", userId);
  if (error) throw error;
}

export async function blacklistJti(supabase, { userId, jti, expiresAt }) {
  const { error } = await supabase.from("token_blacklist").insert({
    user_id: userId,
    jti,
    expires_at: expiresAt
  });
  if (error) throw error;
}

export async function isJtiBlacklisted(supabase, jti) {
  if (!jti) return false;
  const { data, error } = await supabase
    .from("token_blacklist")
    .select("id")
    .eq("jti", jti)
    .gt("expires_at", new Date().toISOString())
    .maybeSingle();
  if (error) throw error;
  return !!data;
}

export async function createPasswordReset(supabase, { userId, tokenHash, expiresAt }) {
  const { data, error } = await supabase
    .from("password_resets")
    .insert({
      user_id: userId,
      token_hash: tokenHash,
      expires_at: expiresAt
    })
    .select("*")
    .single();
  if (error) throw error;
  return data;
}

export async function findPasswordResetByHash(supabase, tokenHash) {
  const { data, error } = await supabase
    .from("password_resets")
    .select("*")
    .eq("token_hash", tokenHash)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function markPasswordResetUsed(supabase, id) {
  const { error } = await supabase
    .from("password_resets")
    .update({ used_at: new Date().toISOString() })
    .eq("id", id);
  if (error) throw error;
}

export async function createEmailVerification(supabase, { userId, tokenHash, expiresAt }) {
  const { data, error } = await supabase
    .from("email_verifications")
    .insert({
      user_id: userId,
      token_hash: tokenHash,
      expires_at: expiresAt
    })
    .select("*")
    .single();
  if (error) throw error;
  return data;
}

export async function findEmailVerificationByHash(supabase, tokenHash) {
  const { data, error } = await supabase
    .from("email_verifications")
    .select("*")
    .eq("token_hash", tokenHash)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function markEmailVerified(supabase, { verificationId, userId }) {
  const { error: verificationError } = await supabase
    .from("email_verifications")
    .update({ verified_at: new Date().toISOString() })
    .eq("id", verificationId);
  if (verificationError) throw verificationError;

  const { error: userError } = await supabase
    .from("users")
    .update({ email_verified_at: new Date().toISOString() })
    .eq("id", userId);
  if (userError) throw userError;
}
