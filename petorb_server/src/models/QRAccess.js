const mongoose = require('mongoose');

const QRAccessSchema = new mongoose.Schema({
  petId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pet',
    required: true
  },
  sitterId: {
    type: String, // Sitter UID
    required: true
  },
  expiryDate: {
    type: Date,
    required: true
  },
  token: {
    type: String,
    required: true,
    unique: true
  },
  revoked: {
    type: Boolean,
    default: false
  }
}, { timestamps: true });

module.exports = mongoose.model('QRAccess', QRAccessSchema);
