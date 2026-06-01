const mongoose = require('mongoose');

const JobSchema = new mongoose.Schema({
  ownerId: {
    type: String, // User UID
    required: true
  },
  petIds: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pet'
  }],
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  payment: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    enum: ['open', 'assigned', 'completed', 'cancelled'],
    default: 'open'
  },
  startDate: {
    type: Date,
    required: true
  },
  endDate: {
    type: Date,
    required: true
  },
  instructions: {
    type: String,
    default: ''
  },
  assignedSitterId: {
    type: String, // Sitter User UID
    default: null
  }
}, { timestamps: true });

module.exports = mongoose.model('Job', JobSchema);
