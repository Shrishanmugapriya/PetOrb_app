const mongoose = require('mongoose');

const ApplicationSchema = new mongoose.Schema({
  jobId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Job',
    required: true
  },
  sitterId: {
    type: String, // Sitter User UID
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'rejected'],
    default: 'pending'
  },
  experience: {
    type: String,
    default: ''
  },
  proposedRate: {
    type: Number,
    default: 0
  }
}, { timestamps: true });

module.exports = mongoose.model('Application', ApplicationSchema);
