const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');

const authController = require('../controllers/authController');
const petController = require('../controllers/petController');
const jobController = require('../controllers/jobController');
const qrController = require('../controllers/qrController');
const aiController = require('../controllers/aiController');

// --- AUTHENTICATION ROUTES ---
router.post('/auth/register', authController.register);
router.post('/auth/login', authController.login);
router.get('/auth/profile', auth, authController.getProfile);
router.put('/auth/profile', auth, authController.updateProfile);

// --- PET MANAGEMENT ROUTES ---
router.post('/pets', auth, petController.createPet);
router.get('/pets', auth, petController.getPets);
router.get('/pets/:id', auth, petController.getPetById);
router.put('/pets/:id', auth, petController.updatePet);
router.delete('/pets/:id', auth, petController.deletePet);

// --- SITTER MARKETPLACE ROUTES ---
router.post('/jobs', auth, jobController.createJob);
router.get('/jobs', auth, jobController.getJobs);
router.get('/jobs/:id', auth, jobController.getJobById);
router.post('/jobs/:id/apply', auth, jobController.applyForJob);
router.get('/jobs/:id/applicants', auth, jobController.getApplicants);
router.post('/jobs/accept', auth, jobController.acceptApplicant);
router.post('/jobs/reject', auth, jobController.rejectApplicant);
router.post('/jobs/:id/complete', auth, jobController.completeJob);

// --- QR SYSTEM ROUTES ---
router.get('/qr', auth, qrController.getQRAccessCodes);
router.post('/qr/verify', auth, qrController.verifyQR);
router.post('/qr/:id/revoke', auth, qrController.revokeQR);

// PUBLIC LOST PET RECOVERY ROUTE (NO AUTHENTICATION REQUIRED)
router.get('/qr/lost-pet/:petId', qrController.getLostPetPage);

// --- AI ASSISTANT ROUTES ---
router.post('/ai/ask', auth, aiController.askAssistant);
router.get('/ai/chat', auth, aiController.getChatHistory);
router.post('/ai/clear', auth, aiController.clearChatHistory);

module.exports = router;
