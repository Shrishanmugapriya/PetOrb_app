const QRAccess = require('../models/QRAccess');
const Pet = require('../models/Pet');
const User = require('../models/User');
const mongoose = require('mongoose');

exports.getQRAccessCodes = async (req, res) => {
  try {
    if (req.user.role === 'owner') {
      // Find all pets owned by this owner
      const pets = await Pet.find({ ownerId: req.user.uid });
      const petIds = pets.map(p => p._id);
      
      const codes = await QRAccess.find({ petId: { $in: petIds }, revoked: false })
        .populate('petId');
      
      // Let's populate sitter details manually
      const populatedCodes = [];
      for (const code of codes) {
        const sitter = await User.findOne({ uid: code.sitterId });
        populatedCodes.push({
          ...code.toObject(),
          sitter: sitter ? { name: sitter.name, email: sitter.email, phone: sitter.phone, photo: sitter.photo } : null
        });
      }
      res.json(populatedCodes);
    } else {
      // Sitter: find active codes assigned to this sitter
      const codes = await QRAccess.find({
        sitterId: req.user.uid,
        expiryDate: { $gt: new Date() },
        revoked: false
      }).populate('petId');
      
      res.json(codes);
    }
  } catch (error) {
    console.error('Get QR codes error:', error);
    res.status(500).json({ message: 'Server error retrieving QR codes' });
  }
};

exports.verifyQR = async (req, res) => {
  try {
    const { token } = req.body;
    if (!token) {
      return res.status(400).json({ message: 'Verification token is required' });
    }

    const qrAccess = await QRAccess.findOne({ token }).populate('petId');
    if (!qrAccess) {
      return res.status(404).json({ message: 'Invalid QR code. Access denied.' });
    }

    if (qrAccess.revoked) {
      return res.status(403).json({ message: 'This QR code has been revoked. Access denied.' });
    }

    if (new Date() > qrAccess.expiryDate) {
      return res.status(403).json({ message: 'This QR code has expired. Access denied.' });
    }

    if (qrAccess.sitterId !== req.user.uid) {
      return res.status(403).json({ message: 'Unauthorized. This QR code belongs to a different sitter.' });
    }

    // Access granted! Retrieve Owner details for the sitter
    const owner = await User.findOne({ uid: qrAccess.petId.ownerId });

    res.json({
      message: 'Access Granted!',
      pet: qrAccess.petId,
      owner: owner ? {
        name: owner.name,
        email: owner.email,
        phone: owner.phone
      } : null
    });
  } catch (error) {
    console.error('Verify QR error:', error);
    res.status(500).json({ message: 'Server error verifying QR code' });
  }
};

exports.revokeQR = async (req, res) => {
  try {
    if (req.user.role !== 'owner') {
      return res.status(403).json({ message: 'Only owners can revoke access' });
    }

    const qrAccess = await QRAccess.findById(req.params.id).populate('petId');
    if (!qrAccess) {
      return res.status(404).json({ message: 'Access record not found' });
    }

    if (qrAccess.petId.ownerId !== req.user.uid) {
      return res.status(403).json({ message: 'Access denied: You do not own this pet' });
    }

    qrAccess.revoked = true;
    await qrAccess.save();

    res.json({ message: 'QR Access revoked successfully', qrAccess });
  } catch (error) {
    console.error('Revoke QR error:', error);
    res.status(500).json({ message: 'Server error revoking access' });
  }
};

// PUBLIC ENDPOINT - NO AUTH REQUIRED
exports.getLostPetPage = async (req, res) => {
  try {
    const { petId } = req.params;
    if (!mongoose.Types.ObjectId.isValid(petId)) {
      return res.status(400).send('<h1>400 Bad Request</h1><p>Invalid pet ID format.</p>');
    }
    const pet = await Pet.findById(petId);
    if (!pet) {
      return res.status(404).send('<h1>404 Not Found</h1><p>Pet profile could not be found.</p>');
    }

    const owner = await User.findOne({ uid: pet.ownerId });
    if (!owner) {
      return res.status(404).send('<h1>404 Not Found</h1><p>Owner information could not be found.</p>');
    }

    // Render EJS layout with pet and owner contact info
    res.render('lost_pet', {
      petName: pet.name,
      photo: pet.photo || 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=500',
      breed: pet.breed,
      species: pet.species,
      age: pet.age,
      ownerName: owner.name,
      ownerPhone: owner.phone || 'Not Provided',
      specialInstructions: pet.specialInstructions || 'None provided. If found, please call the owner immediately.'
    });
  } catch (error) {
    console.error('Lost pet page render error:', error);
    res.status(500).send('<h1>Server Error</h1><p>Unable to retrieve recovery details.</p>');
  }
};
