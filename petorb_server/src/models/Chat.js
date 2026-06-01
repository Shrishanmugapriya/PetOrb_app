const mongoose = require('mongoose');

const ChatMessageSchema = new mongoose.Schema({
  sender: {
    type: String, // 'user' or 'ai'
    required: true
  },
  content: {
    type: String,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const ChatSchema = new mongoose.Schema({
  petId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pet',
    required: true
  },
  userId: {
    type: String, // User UID
    required: true
  },
  role: {
    type: String, // 'owner' or 'sitter'
    required: true
  },
  messages: [ChatMessageSchema]
}, { timestamps: true });

module.exports = mongoose.model('Chat', ChatSchema);
