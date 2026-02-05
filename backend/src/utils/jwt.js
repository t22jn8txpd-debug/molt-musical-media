import jwt from 'jsonwebtoken';

export const signToken = (payload, secret = process.env.JWT_SECRET, options = {}) => {
  return jwt.sign(payload, secret, {
    expiresIn: '7d',
    ...options
  });
};

export const verifyToken = (token, secret = process.env.JWT_SECRET) => {
  try {
    return jwt.verify(token, secret);
  } catch (err) {
    throw err; // or return null / handle specific errors
  }
};