// server.js
const express = require('express');
const cors = require('cors');
const quizData = require('./quizData.json');

const app = express();
app.use(cors()); // dla dev: zezwalaj na żądania ze wszystkich originów
app.use(express.json());

// helper: znajdź klucz w obiekcie ignorując wielkość liter
function findKeyIgnoreCase(obj, key) {
  if (!obj || typeof obj !== 'object') return null;
  const lower = key.toString().toLowerCase();
  return Object.keys(obj).find(k => k.toLowerCase() === lower) || null;
}

// GET /quizzes/:course
// Zwraca listę grup: [{ topic: 'Komórki', questions: [ {...}, ... ] }, ...]
app.get('/quizzes/:course', (req, res) => {
  try {
    const courseParam = req.params.course;
    const courseKey = findKeyIgnoreCase(quizData, courseParam);
    if (!courseKey) return res.status(404).json({ error: 'Course not found' });

    const courseObj = quizData[courseKey];
    const topics = Object.keys(courseObj).map(topicKey => ({
      topic: topicKey,
      questions: courseObj[topicKey]
    }));

    return res.json(topics);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /quiz/:course
// Zwraca spłaszczoną tablicę wszystkich pytań w kursie: [ {question, options, correctIndex}, ... ]
app.get('/quiz/:course', (req, res) => {
  try {
    const courseParam = req.params.course;
    const courseKey = findKeyIgnoreCase(quizData, courseParam);
    if (!courseKey) return res.status(404).json({ error: 'Course not found' });

    const courseObj = quizData[courseKey];
    const all = Object.values(courseObj).flat();
    return res.json(all);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /quiz/:course/:topic
// Zwraca tablicę pytań dla konkretnego tematu: [ {...}, ... ]
app.get('/quiz/:course/:topic', (req, res) => {
  try {
    const courseParam = req.params.course;
    const topicParam = req.params.topic;

    const courseKey = findKeyIgnoreCase(quizData, courseParam);
    if (!courseKey) return res.status(404).json({ error: 'Course not found' });

    const courseObj = quizData[courseKey];
    const topicKey = findKeyIgnoreCase(courseObj, topicParam);
    if (!topicKey) return res.status(404).json({ error: 'Topic not found in course' });

    return res.json(courseObj[topicKey]);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// optional health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Quiz API running on http://localhost:${PORT}`);
});