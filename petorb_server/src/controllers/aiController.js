const { GoogleGenerativeAI } = require('@google/generative-ai');
const Pet = require('../models/Pet');
const Chat = require('../models/Chat');
const QRAccess = require('../models/QRAccess');
const Job = require('../models/Job');



// Helper to check sitter access
const checkSitterAccess = async (petId, sitterId) => {
  const qrAccess = await QRAccess.findOne({
    petId,
    sitterId,
    expiryDate: { $gt: new Date() },
    revoked: false
  });
  if (qrAccess) return true;

  const jobAccess = await Job.findOne({
    assignedSitterId: sitterId,
    petIds: petId,
    status: 'assigned'
  });
  if (jobAccess) return true;

  return false;
};

const extractAndApplyPetUpdates = async (pet, question, reply, apiKey) => {
  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' }, { apiVersion: 'v1' });

    const currentAllergies = pet.medicalRecords?.allergies || [];
    const currentMedications = pet.medicalRecords?.currentMedications || [];
    const currentVet = pet.medicalRecords?.vetInfo || {};

    const extractionPrompt = `
You are a pet profile data extractor. Analyze this recent interaction between a pet Owner and an AI assistant.
Determine if the Owner has explicitly provided new or updated facts about the pet that should be stored in the pet's profile.

Pet name: "${pet.name}"
Current Pet Profile Data (JSON):
${JSON.stringify({
  weight: pet.weight,
  age: pet.age,
  breed: pet.breed,
  allergies: currentAllergies,
  currentMedications: currentMedications,
  specialInstructions: pet.specialInstructions,
  vetInfo: currentVet
}, null, 2)}

User's message: "${question}"
AI's response: "${reply}"

If the Owner explicitly stated new details, output a JSON object containing ONLY the fields to update. Do not modify fields that were not mentioned or changed.
Allowed update fields and formats:
{
  "age": Number,
  "weight": Number,
  "breed": String,
  "allergies": [String], (list any new allergies to add, e.g. ["Chicken"])
  "currentMedications": [{"name": String, "dosage": String, "frequency": String}], (list medications)
  "specialInstructions": String,
  "vetInfo": {"name": String, "phone": String, "address": String}
}

If no profile updates are stated or if the user is asking a question rather than stating a new profile fact to remember, output exactly: {"hasUpdates": false}
Do not explain your reasoning. Output valid JSON only, starting with "{" and ending with "}".
`;

    const result = await model.generateContent(extractionPrompt);
    let responseText = result.response.text().trim();
    
    // Clean markdown formatting if any
    if (responseText.startsWith('```')) {
      responseText = responseText.replace(/```json|```/g, '').trim();
    }
    
    console.log('AI Extraction parsed response:', responseText);
    const updates = JSON.parse(responseText);

    if (updates && updates.hasUpdates !== false) {
      console.log('Applying updates to pet profile:', updates);
      
      let modified = false;

      if (updates.age !== undefined && updates.age !== pet.age) {
        pet.age = updates.age;
        modified = true;
      }
      if (updates.weight !== undefined && updates.weight !== pet.weight) {
        pet.weight = updates.weight;
        modified = true;
      }
      if (updates.breed !== undefined && updates.breed !== pet.breed) {
        pet.breed = updates.breed;
        modified = true;
      }
      if (updates.specialInstructions !== undefined && updates.specialInstructions !== pet.specialInstructions) {
        pet.specialInstructions = updates.specialInstructions;
        modified = true;
      }
      
      if (updates.allergies !== undefined && Array.isArray(updates.allergies)) {
        if (!pet.medicalRecords) pet.medicalRecords = {};
        if (!pet.medicalRecords.allergies) pet.medicalRecords.allergies = [];
        const uniqueAllergies = new Set([...pet.medicalRecords.allergies, ...updates.allergies]);
        pet.medicalRecords.allergies = Array.from(uniqueAllergies);
        pet.markModified('medicalRecords.allergies');
        modified = true;
      }
      
      if (updates.currentMedications !== undefined && Array.isArray(updates.currentMedications)) {
        if (!pet.medicalRecords) pet.medicalRecords = {};
        pet.medicalRecords.currentMedications = updates.currentMedications;
        pet.markModified('medicalRecords.currentMedications');
        modified = true;
      }
      
      if (updates.vetInfo !== undefined && typeof updates.vetInfo === 'object') {
        if (!pet.medicalRecords) pet.medicalRecords = {};
        pet.medicalRecords.vetInfo = { ...pet.medicalRecords.vetInfo, ...updates.vetInfo };
        pet.markModified('medicalRecords.vetInfo');
        modified = true;
      }
      
      if (modified) {
        await pet.save();
        return true;
      }
    }
  } catch (error) {
    console.error('Failed to extract/apply pet updates:', error);
  }
  return false;
};

exports.askAssistant = async (req, res) => {
  try {
    const { petId, question } = req.body;
    const { uid, role } = req.user;

    if (!petId || !question) {
      return res.status(400).json({ message: 'Pet ID and question are required' });
    }

    // 1. Verify access permissions
    const pet = await Pet.findById(petId);
    if (!pet) {
      return res.status(404).json({ message: 'Pet not found' });
    }

    if (role === 'owner') {
      if (pet.ownerId !== uid) {
        return res.status(403).json({ message: 'Access denied: You do not own this pet' });
      }
    } else {
      // Sitter permission check
      const hasAccess = await checkSitterAccess(pet._id, uid);
      if (!hasAccess) {
        return res.status(403).json({ message: 'Access denied: You are not authorized to care for this pet' });
      }
    }

    // 2. Check for Gemini API Key
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey || apiKey === 'YOUR_GEMINI_API_KEY_HERE') {
      return res.status(400).json({
        message: 'Gemini API Key is not configured on the backend server. Please set GEMINI_API_KEY in the server\'s .env file.'
      });
    }

    // 3. Fetch or initialize chat history
    let chat = await Chat.findOne({ petId, userId: uid, role });
    if (!chat) {
      chat = new Chat({ petId, userId: uid, role, messages: [] });
    }

    // Append user question to history database
    chat.messages.push({ sender: 'user', content: question });

    // 4. Construct AI Workflow context payload
    const petInformation = {
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      age: pet.age,
      gender: pet.gender,
      weight: pet.weight
    };

    const medicalRecords = pet.medicalRecords || {};
    const feedingSchedule = pet.feedingSchedule || [];
    const ownerNotes = {
      foodPreferences: pet.foodPreferences || [],
      sleepSchedule: pet.sleepSchedule || '',
      activityRoutine: pet.activityRoutine || '',
      behaviourNotes: pet.behaviourNotes || '',
      specialInstructions: pet.specialInstructions || ''
    };

    // Build Chat History logs string
    const chatLogs = chat.messages
      .slice(-10) // Limit to last 10 messages for token efficiency
      .map(m => `${m.sender === 'user' ? 'User' : 'Assistant'}: ${m.content}`)
      .join('\n');

    // 5. System instructions based on role
    let roleSystemInstructions = '';
    if (role === 'owner') {
      roleSystemInstructions = `
You are in OWNER mode. The user asking questions is the pet owner.
- You can explain medical issues in detail and provide grooming, training, and care routine updates.
- Help generate personalized care checklists or diet plan suggestions.
- Provide health monitoring advice based on their history.
`;
    } else {
      roleSystemInstructions = `
You are in SITTER mode. The user asking questions is a hired pet sitter.
- Answer care-related questions: feeding amounts, food restrictions, behavior notes, activities.
- You MUST NOT reveal the owner's personal contacts, phone numbers, or administrative/financial data.
- Refuse questions asking to modify records or edit pet details. Explain politely that only owners can modify profiles.
`;
    }

    const systemPrompt = `
You are "PetOrb AI", the advanced intelligent AI Pet Assistant.
You are a virtual pet care expert capable of assisting with feeding, health, behavior, activities, medication reminders, emergency guidance, and daily pet management.
You are interacting with a user in ${role.toUpperCase()} mode.

CONTEXT INFORMATION FOR THE CURRENT SELECTED PET:
${JSON.stringify({ pet_information: petInformation, medical_records: medicalRecords, feeding_schedule: feedingSchedule, owner_notes: ownerNotes }, null, 2)}

ROLE INSTRUCTIONS:
${roleSystemInstructions}

RULES:
1. Always prioritize the information stored in the pet's profile before using general pet-care knowledge.
2. If the user asks a health question and there are allergies or conditions in the profile, reference them directly.
3. If information is missing from the profile, guide the user warmly but point out that it is not in the profile records.
4. Keep your answers warm, highly personalized, and pet-friendly.
5. KEEP YOUR ANSWERS EXTREMELY SIMPLE, DIRECT, AND CONCISE. Do NOT write long paragraphs or essays. Answer in 1-3 sentences maximum. Use short bullet points only if listing steps.

PREVIOUS CONVERSATION CONTEXT:
${chatLogs}

Answer the following user question using the context above:
Question: "${question}"
`;

    // 6. Call Google Gemini API (gemini-flash-latest is stable and supported on free quota)
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-3.1-flash-lite' }, { apiVersion: 'v1' });

    const result = await model.generateContent(systemPrompt);
    let responseText = result.response.text();

    // 6.5 For Owner conversations, auto extract facts & apply updates to the database
    if (role === 'owner') {
      try {
        const didUpdate = await extractAndApplyPetUpdates(pet, question, responseText, apiKey);
        if (didUpdate) {
          responseText += `\n\n*(System Alert: I have updated ${pet.name}'s official profile with these details!)*`;
        }
      } catch (err) {
        console.error('Failed to extract pet updates during chat:', err);
      }
    }

    // 7. Save Assistant response to Chat history
    chat.messages.push({ sender: 'ai', content: responseText });
    await chat.save();

    res.json({
      reply: responseText,
      chatHistory: chat.messages
    });

  } catch (error) {
    console.error('AI assistant error:', error);
    if (error.status === 429 || (error.message && (error.message.includes('429') || error.message.includes('quota') || error.message.includes('Quota')))) {
      return res.status(429).json({
        message: 'Google Gemini API quota limit exceeded (20 requests per day limit reached on the Free Tier). Please retry later or configure billing/limits in Google AI Studio to unlock unlimited requests!'
      });
    }
    res.status(500).json({ message: 'Server error generating AI response' });
  }
};

exports.getChatHistory = async (req, res) => {
  try {
    const { petId } = req.query;
    const { uid, role } = req.user;

    if (!petId) {
      return res.status(400).json({ message: 'Pet ID is required' });
    }

    const pet = await Pet.findById(petId);
    if (!pet) {
      return res.status(404).json({ message: 'Pet not found' });
    }

    if (role === 'owner') {
      if (pet.ownerId !== uid) {
        return res.status(403).json({ message: 'Access denied: You do not own this pet' });
      }
    } else {
      const hasAccess = await checkSitterAccess(pet._id, uid);
      if (!hasAccess) {
        return res.status(403).json({ message: 'Access denied: You are not authorized to care for this pet' });
      }
    }

    let chat = await Chat.findOne({ petId, userId: uid, role });
    if (!chat) {
      chat = new Chat({ petId, userId: uid, role, messages: [] });
      await chat.save();
    }

    res.json(chat.messages);
  } catch (error) {
    console.error('Get chat history error:', error);
    res.status(500).json({ message: 'Server error retrieving chat logs' });
  }
};

exports.clearChatHistory = async (req, res) => {
  try {
    const { petId } = req.body;
    const { uid, role } = req.user;

    if (!petId) {
      return res.status(400).json({ message: 'Pet ID is required' });
    }

    const pet = await Pet.findById(petId);
    if (!pet) {
      return res.status(404).json({ message: 'Pet not found' });
    }

    if (role === 'owner') {
      if (pet.ownerId !== uid) {
        return res.status(403).json({ message: 'Access denied: You do not own this pet' });
      }
    } else {
      const hasAccess = await checkSitterAccess(pet._id, uid);
      if (!hasAccess) {
        return res.status(403).json({ message: 'Access denied: You are not authorized to care for this pet' });
      }
    }

    await Chat.findOneAndDelete({ petId, userId: uid, role });
    res.json({ message: 'Chat history cleared successfully', messages: [] });
  } catch (error) {
    console.error('Clear chat history error:', error);
    res.status(500).json({ message: 'Server error clearing chat logs' });
  }
};

