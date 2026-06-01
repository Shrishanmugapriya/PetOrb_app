const Pet = require('../models/Pet');
const QRAccess = require('../models/QRAccess');
const Job = require('../models/Job');

// Helper to check if sitter has active access to a pet
const checkSitterAccess = async (petId, sitterId) => {
  // Check 1: Active QR token
  const qrAccess = await QRAccess.findOne({
    petId,
    sitterId,
    expiryDate: { $gt: new Date() },
    revoked: false
  });
  if (qrAccess) return true;

  // Check 2: Active assigned job containing this pet
  const jobAccess = await Job.findOne({
    assignedSitterId: sitterId,
    petIds: petId,
    status: 'assigned'
  });
  if (jobAccess) return true;

  return false;
};

exports.createPet = async (req, res) => {
  try {
    if (req.user.role !== 'owner') {
      return res.status(403).json({ message: 'Only pet owners can register pets' });
    }

    const petData = {
      ...req.body,
      ownerId: req.user.uid
    };

    const pet = new Pet(petData);
    await pet.save();
    res.status(201).json(pet);
  } catch (error) {
    console.error('Create pet error:', error);
    res.status(500).json({ message: 'Server error during pet registration' });
  }
};

exports.getPets = async (req, res) => {
  try {
    if (req.user.role === 'owner') {
      const pets = await Pet.find({ ownerId: req.user.uid });
      return res.json(pets);
    } else {
      // For sitters, retrieve only pets they are assigned to
      // 1. Get petIds from active jobs
      const jobs = await Job.find({ assignedSitterId: req.user.uid, status: 'assigned' });
      const jobPetIds = jobs.reduce((acc, job) => [...acc, ...job.petIds], []);

      // 2. Get petIds from QR access codes
      const qrAccess = await QRAccess.find({
        sitterId: req.user.uid,
        expiryDate: { $gt: new Date() },
        revoked: false
      });
      const qrPetIds = qrAccess.map(access => access.petId);

      // Unique list of authorized pet IDs
      const authorizedPetIds = [...new Set([...jobPetIds, ...qrPetIds])];
      const pets = await Pet.find({ _id: { $in: authorizedPetIds } });
      return res.json(pets);
    }
  } catch (error) {
    console.error('Get pets error:', error);
    res.status(500).json({ message: 'Server error retrieving pets' });
  }
};

exports.getPetById = async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id);
    if (!pet) {
      return res.status(404).json({ message: 'Pet not found' });
    }

    if (req.user.role === 'owner') {
      if (pet.ownerId !== req.user.uid) {
        return res.status(403).json({ message: 'Access denied: You do not own this pet' });
      }
    } else {
      const hasAccess = await checkSitterAccess(pet._id, req.user.uid);
      if (!hasAccess) {
        return res.status(403).json({ message: 'Access denied: You are not authorized to care for this pet' });
      }
    }

    res.json(pet);
  } catch (error) {
    console.error('Get pet by ID error:', error);
    res.status(500).json({ message: 'Server error retrieving pet details' });
  }
};

exports.updatePet = async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id);
    if (!pet) {
      return res.status(404).json({ message: 'Pet not found' });
    }

    if (pet.ownerId !== req.user.uid) {
      return res.status(403).json({ message: 'Access denied: You do not own this pet' });
    }

    // Update fields
    Object.assign(pet, req.body);
    await pet.save();

    res.json(pet);
  } catch (error) {
    console.error('Update pet error:', error);
    res.status(500).json({ message: 'Server error updating pet details' });
  }
};

exports.deletePet = async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id);
    if (!pet) {
      return res.status(404).json({ message: 'Pet not found' });
    }

    if (pet.ownerId !== req.user.uid) {
      return res.status(403).json({ message: 'Access denied: You do not own this pet' });
    }

    await Pet.findByIdAndDelete(req.params.id);
    res.json({ message: 'Pet deleted successfully' });
  } catch (error) {
    console.error('Delete pet error:', error);
    res.status(500).json({ message: 'Server error deleting pet profile' });
  }
};
