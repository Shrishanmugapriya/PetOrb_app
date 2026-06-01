const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');
const User = require('../models/User');

// Optionally initialize firebase-admin if key exists
let firebaseInitialized = false;
if (process.env.FIREBASE_PROJECT_ID && process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  try {
    admin.initializeApp();
    firebaseInitialized = true;
    console.log('Firebase Admin SDK Initialized.');
  } catch (err) {
    console.log('Firebase Admin init bypassed or failed. Using JWT fallback auth.');
  }
}

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'No token, authorization denied' });
    }

    const token = authHeader.split(' ')[1];

    // 1. Direct Local UID Testing Bypass (for super-easy developer testing)
    // If token starts with 'dev_uid_', we can bypass validation for local demo
    if (token.startsWith('dev_uid_')) {
      const user = await User.findOne({ $or: [{ uid: token }, { uid: token.replace('dev_uid_', '') }] });
      if (!user) {
        return res.status(404).json({ message: 'User not found in development bypass' });
      }
      req.user = user;
      return next();
    }

    // 2. Try Firebase verification if enabled
    if (firebaseInitialized) {
      try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        const uid = decodedToken.uid;
        let user = await User.findOne({ uid });
        if (!user) {
          // Auto create user record in MongoDB if registered via Firebase
          user = new User({
            uid,
            name: decodedToken.name || decodedToken.email.split('@')[0],
            email: decodedToken.email,
            role: 'owner' // default role
          });
          await user.save();
        }
        req.user = user;
        return next();
      } catch (fbError) {
        console.log('Firebase verification failed, trying JWT...');
      }
    }

    // 3. Try fallback custom JWT token verification
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'petorb_super_secret_jwt_key_2026');
      const user = await User.findOne({ uid: decoded.uid });
      if (!user) {
        return res.status(401).json({ message: 'Token is valid, but user not found' });
      }
      req.user = user;
      next();
    } catch (jwtError) {
      return res.status(401).json({ message: 'Token verification failed' });
    }
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({ message: 'Server authentication error' });
  }
};
