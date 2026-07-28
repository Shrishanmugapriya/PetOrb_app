const crypto = require('crypto');
const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Helper to sign JWT
const signToken = (uid) => {
  return jwt.sign({ uid }, process.env.JWT_SECRET || 'petorb_super_secret_jwt_key_2026', {
    expiresIn: '30d'
  });
};

// Password hashing helper using native Node.js crypto
const hashPassword = (password) => {
  if (!password) return '';
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');
  return `${salt}:${hash}`;
};

// Password verification helper
const verifyPassword = (password, storedHash) => {
  if (!storedHash || !storedHash.includes(':')) return false;
  const [salt, originalHash] = storedHash.split(':');
  const hash = crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');
  return hash === originalHash;
};

// Password format validation helper
const validatePasswordFormat = (password) => {
  if (!password || password.length < 6) {
    return 'Password must be at least 6 characters long.';
  }
  if (/^[^a-zA-Z]/.test(password)) {
    return 'Password must start with a letter (cannot start with a number or special character).';
  }
  if (!/[A-Z]/.test(password)) {
    return 'Password must contain at least one uppercase letter (A-Z).';
  }
  if (!/[a-z]/.test(password)) {
    return 'Password must contain at least one lowercase letter (a-z).';
  }
  if (!/[0-9]/.test(password)) {
    return 'Password must contain at least one number (0-9).';
  }
  if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
    return 'Password must contain at least one special character (!@#$%^&*).';
  }
  return null;
};

exports.register = async (req, res) => {
  try {
    const { uid, name, email, password, role, phone, photo } = req.body;

    if (!name || !email || !role) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    if (password) {
      const pwdError = validatePasswordFormat(password);
      if (pwdError) {
        return res.status(400).json({ message: pwdError });
      }
    }

    const effectiveUid = uid || `user_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;

    let existingUser = await User.findOne({ $or: [{ uid: effectiveUid }, { email: email.toLowerCase() }] });
    if (existingUser) {
      return res.status(400).json({ message: 'An account with this email already exists. Please sign in.' });
    }

    const hashedPassword = password ? hashPassword(password) : '';

    const user = new User({
      uid: effectiveUid,
      name,
      email: email.toLowerCase(),
      password: hashedPassword,
      role,
      phone: phone || '',
      photo: photo || ''
    });

    await user.save();
    const token = signToken(user.uid);

    res.status(201).json({
      token,
      user: {
        uid: user.uid,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
        photo: user.photo
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: 'Server error during registration' });
  }
};

exports.login = async (req, res) => {
  try {
    const { uid, email, password } = req.body;

    let user = null;

    if (email) {
      user = await User.findOne({ email: email.toLowerCase() });
    } else if (uid) {
      user = await User.findOne({ uid });
    }

    if (!user) {
      return res.status(404).json({ message: 'Account not found. Please sign up first.' });
    }

    // If password is provided, verify it against stored hash
    if (password && user.password) {
      const isValid = verifyPassword(password, user.password);
      if (!isValid) {
        return res.status(401).json({ message: 'Incorrect password. Please try again.' });
      }
    }

    const token = signToken(user.uid);

    res.json({
      token,
      user: {
        uid: user.uid,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
        photo: user.photo,
        sitterProfile: user.sitterProfile
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error during login' });
  }
};

exports.getProfile = async (req, res) => {
  try {
    res.json(req.user);
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, phone, photo, sitterProfile } = req.body;
    const user = req.user;

    if (name) user.name = name;
    if (phone) user.phone = phone;
    if (photo) user.photo = photo;

    if (user.role === 'sitter' && sitterProfile) {
      user.sitterProfile = {
        ...user.sitterProfile,
        ...sitterProfile
      };
    }

    await user.save();
    res.json(user);
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ message: 'Server error during profile update' });
  }
};
