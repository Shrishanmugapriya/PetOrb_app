const Job = require('../models/Job');
const Application = require('../models/Application');
const QRAccess = require('../models/QRAccess');
const crypto = require('crypto');

exports.createJob = async (req, res) => {
  try {
    if (req.user.role !== 'owner') {
      return res.status(403).json({ message: 'Only pet owners can post jobs' });
    }

    const { petIds, title, description, payment, startDate, endDate, instructions } = req.body;

    if (!petIds || petIds.length === 0 || !title || !description || !payment || !startDate || !endDate) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    const job = new Job({
      ownerId: req.user.uid,
      petIds,
      title,
      description,
      payment,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      instructions: instructions || ''
    });

    await job.save();
    res.status(201).json(job);
  } catch (error) {
    console.error('Create job error:', error);
    res.status(500).json({ message: 'Server error creating job posting' });
  }
};

exports.getJobs = async (req, res) => {
  try {
    const User = require('../models/User');
    if (req.user.role === 'owner') {
      // Return jobs posted by this owner
      const jobs = await Job.find({ ownerId: req.user.uid }).populate('petIds');
      return res.json(jobs);
    } else {
      // Sitter: Return all open jobs or jobs assigned to this sitter
      const { assigned } = req.query;
      let query = { status: 'open' };
      if (assigned === 'true') {
        query = { assignedSitterId: req.user.uid };
      }
      const jobs = await Job.find(query).populate('petIds');
      
      const populatedJobs = [];
      for (const job of jobs) {
        const owner = await User.findOne({ uid: job.ownerId });
        populatedJobs.push({
          ...job.toObject(),
          ownerName: owner ? owner.name : 'Pet Owner'
        });
      }
      return res.json(populatedJobs);
    }
  } catch (error) {
    console.error('Get jobs error:', error);
    res.status(500).json({ message: 'Server error retrieving jobs' });
  }
};

exports.getJobById = async (req, res) => {
  try {
    const job = await Job.findById(req.params.id).populate('petIds');
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }
    res.json(job);
  } catch (error) {
    console.error('Get job error:', error);
    res.status(500).json({ message: 'Server error retrieving job details' });
  }
};

exports.applyForJob = async (req, res) => {
  try {
    if (req.user.role !== 'sitter') {
      return res.status(403).json({ message: 'Only sitters can apply for jobs' });
    }

    const jobId = req.params.id;
    const { experience, proposedRate } = req.body;

    const job = await Job.findById(jobId);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    if (job.status !== 'open') {
      return res.status(400).json({ message: 'Job is no longer open for applications' });
    }

    // Check if already applied
    const existingApp = await Application.findOne({ jobId, sitterId: req.user.uid });
    if (existingApp) {
      return res.status(400).json({ message: 'You have already applied for this job' });
    }

    const application = new Application({
      jobId,
      sitterId: req.user.uid,
      experience: experience || '',
      proposedRate: proposedRate || job.payment
    });

    await application.save();
    res.status(201).json(application);
  } catch (error) {
    console.error('Apply job error:', error);
    res.status(500).json({ message: 'Server error submitting application' });
  }
};

exports.getApplicants = async (req, res) => {
  try {
    const jobId = req.params.id;
    const job = await Job.findById(jobId);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    if (job.ownerId !== req.user.uid) {
      return res.status(403).json({ message: 'Access denied' });
    }

    const applications = await Application.find({ jobId });
    // Let's populate user details manually or via schema query
    const populatedApps = [];
    const User = require('../models/User');

    for (const app of applications) {
      const sitter = await User.findOne({ uid: app.sitterId });
      populatedApps.push({
        ...app.toObject(),
        sitter: sitter ? {
          name: sitter.name,
          email: sitter.email,
          phone: sitter.phone,
          photo: sitter.photo,
          sitterProfile: sitter.sitterProfile
        } : null
      });
    }

    res.json(populatedApps);
  } catch (error) {
    console.error('Get applicants error:', error);
    res.status(500).json({ message: 'Server error retrieving applicants' });
  }
};

exports.acceptApplicant = async (req, res) => {
  try {
    const { applicationId } = req.body;
    const application = await Application.findById(applicationId);
    if (!application) {
      return res.status(404).json({ message: 'Application not found' });
    }

    const job = await Job.findById(application.jobId);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    if (job.ownerId !== req.user.uid) {
      return res.status(403).json({ message: 'Access denied: You do not own this job listing' });
    }

    if (job.status !== 'open') {
      return res.status(400).json({ message: 'Job is already assigned or closed' });
    }

    // 1. Assign Job
    job.status = 'assigned';
    job.assignedSitterId = application.sitterId;
    await job.save();

    // 2. Accept this application and reject all others for this job
    application.status = 'accepted';
    await application.save();

    await Application.updateMany(
      { jobId: job._id, _id: { $ne: application._id } },
      { status: 'rejected' }
    );

    // 3. Auto-generate Secure QR Access Tokens for this sitter for each pet
    const accessRecords = [];
    for (const petId of job.petIds) {
      // Secure random token
      const secureToken = crypto.randomBytes(32).toString('hex');
      
      const qrAccess = new QRAccess({
        petId,
        sitterId: application.sitterId,
        expiryDate: job.endDate, // QR expires when job ends
        token: secureToken
      });
      await qrAccess.save();
      accessRecords.push(qrAccess);
    }

    res.json({
      message: 'Application accepted, job assigned, and QR security keys generated successfully.',
      job,
      qrAccess: accessRecords
    });
  } catch (error) {
    console.error('Accept applicant error:', error);
    res.status(500).json({ message: 'Server error accepting applicant' });
  }
};

exports.rejectApplicant = async (req, res) => {
  try {
    const { applicationId } = req.body;
    const application = await Application.findById(applicationId);
    if (!application) {
      return res.status(404).json({ message: 'Application not found' });
    }

    const job = await Job.findById(application.jobId);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    if (job.ownerId !== req.user.uid) {
      return res.status(403).json({ message: 'Access denied' });
    }

    application.status = 'rejected';
    await application.save();

    res.json({ message: 'Application rejected successfully', application });
  } catch (error) {
    console.error('Reject applicant error:', error);
    res.status(500).json({ message: 'Server error rejecting applicant' });
  }
};

exports.completeJob = async (req, res) => {
  try {
    const jobId = req.params.id;
    const job = await Job.findById(jobId);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    if (job.ownerId !== req.user.uid) {
      return res.status(403).json({ message: 'Access denied: Only the job owner can mark it as completed' });
    }

    if (job.status !== 'assigned') {
      return res.status(400).json({ message: 'Only active assigned jobs can be marked as completed' });
    }

    // 1. Update Job status
    job.status = 'completed';
    await job.save();

    // 2. Revoke all QR access codes for this job immediately to stop sitter AI/QR access
    await QRAccess.updateMany(
      { petId: { $in: job.petIds }, sitterId: job.assignedSitterId },
      { revoked: true }
    );

    res.json({
      message: 'Job completed successfully. Owner and sitter notified. Sitter QR & AI access revoked.',
      job
    });
  } catch (error) {
    console.error('Complete job error:', error);
    res.status(500).json({ message: 'Server error completing job' });
  }
};

