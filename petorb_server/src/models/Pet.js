const mongoose = require('mongoose');

const PetSchema = new mongoose.Schema({
  ownerId: {
    type: String, // User UID
    required: true
  },
  name: {
    type: String,
    required: true
  },
  species: {
    type: String,
    required: true
  },
  breed: {
    type: String,
    required: true
  },
  age: {
    type: Number,
    required: true
  },
  gender: {
    type: String,
    required: true
  },
  weight: {
    type: Number,
    required: true
  },
  photo: {
    type: String,
    default: ''
  },
  // Medical Information
  medicalRecords: {
    vaccinationRecords: [{
      vaccineName: String,
      dateAdministered: Date,
      nextDueDate: Date
    }],
    medicalHistory: [{
      condition: String,
      diagnosedDate: Date,
      notes: String
    }],
    allergies: [String],
    currentMedications: [{
      name: String,
      dosage: String,
      frequency: String
    }],
    vetInfo: {
      name: String,
      phone: String,
      address: String
    }
  },
  // Care Information
  feedingSchedule: [{
    time: String,
    foodType: String,
    amount: String
  }],
  foodPreferences: [String],
  sleepSchedule: String,
  activityRoutine: String,
  behaviourNotes: String,
  // Emergency Information
  emergencyContacts: [{
    name: String,
    phone: String,
    relationship: String
  }],
  specialInstructions: String
}, { timestamps: true });

module.exports = mongoose.model('Pet', PetSchema);
