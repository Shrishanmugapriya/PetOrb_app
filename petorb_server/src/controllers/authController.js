const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Helper to sign JWT
const signToken = (uid) => {
  return jwt.sign({ uid }, process.env.JWT_SECRET || 'petorb_super_secret_jwt_key_2026', {
    expiresIn: '30d'
  });
};

exports.register = async (req, res) => {
  try {
    const { uid, name, email, role, phone, photo } = req.body;

    if (!uid || !name || !email || !role) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    let user = await User.findOne({ uid });
    if (user) {
      return res.status(400).json({ message: 'User already exists' });
    }

    user = new User({
      uid,
      name,
      email,
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
    const { uid } = req.body;

    if (!uid) {
      return res.status(400).json({ message: 'Please provide User UID' });
    }

    const user = await User.findOne({ uid });
    if (!user) {
      return res.status(404).json({ message: 'User profile not found. Please register first.' });
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
