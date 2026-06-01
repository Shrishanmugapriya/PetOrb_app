const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  uid: {
    type: String,
    required: true,
    unique: true
  },
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  role: {
    type: String,
    enum: ['owner', 'sitter'],
    required: true
  },
  photo: {
    type: String,
    default: ''
  },
  phone: {
    type: String,
    default: ''
  },
  sitterProfile: {
    experience: { type: String, default: '' },
    bio: { type: String, default: '' },
    rate: { type: Number, default: 0 },
    verified: { type: Boolean, default: false }
  }
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
