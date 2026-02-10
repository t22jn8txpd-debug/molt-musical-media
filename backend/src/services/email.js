export async function sendVerificationEmail({ email, token }) {
  if (!process.env.EMAIL_PROVIDER) {
    return { ok: true, skipped: true };
  }

  // Placeholder for real email integration
  return { ok: true };
}

export async function sendPasswordResetEmail({ email, token }) {
  if (!process.env.EMAIL_PROVIDER) {
    return { ok: true, skipped: true };
  }

  // Placeholder for real email integration
  return { ok: true };
}
