const { GoogleGenerativeAI } = require('@google/generative-ai');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../.env') });
const apiKey = process.env.GEMINI_API_KEY;
console.log('Using API key:', apiKey ? apiKey.substring(0, 10) + '...' : 'NULL');

async function testModel(modelName) {
  try {
    console.log(`Testing model: ${modelName}...`);
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: modelName }, { apiVersion: 'v1' });
    const result = await model.generateContent('Hello, respond in exactly 3 words.');
    console.log(`Success with ${modelName}:`, result.response.text().trim());
    return true;
  } catch (err) {
    console.error(`Error with ${modelName}:`, err.message);
    return false;
  }
}

async function run() {
  const models = [
    'gemini-3.5-flash',
    'gemini-3.1-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.0-flash'
  ];
  for (const m of models) {
    const success = await testModel(m);
    if (success) {
      console.log(`Model ${m} worked!`);
    }
    console.log('-----------------');
  }
}

run();
