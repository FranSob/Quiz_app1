const express = require('express');
const cors = require('cors');
const quizData = require('./quizData.json');

const app = express();
app.use(cors());
app.use(express.json());

/* ===== ROOT (żeby nie było Cannot GET /) ===== */
app.get('/', (req, res) => {
  res.send('Quiz backend działa ✅');
});

/* ===== LISTA TEMATÓW KURSU ===== */
app.get('/quizzes/:course', (req, res) => {
  const course = req.params.course;
  const courseData = quizData[course];

  if (!courseData) {
    return res.status(404).json({ error: 'Course not found' });
  }

  const result = Object.keys(courseData).map(topic => ({
    topic,
    questions: courseData[topic]
  }));

  res.json(result);
});

/* ===== QUIZ: CAŁY KURS ===== */
app.get('/quiz/:course', (req, res) => {
  const course = req.params.course;
  const courseData = quizData[course];

  if (!courseData) {
    return res.status(404).json({ error: 'Course not found' });
  }

  const allQuestions = Object.values(courseData).flat();
  res.json(allQuestions);
});

/* ===== QUIZ: KONKRETNY TEMAT ===== */
app.get('/quiz/:course/:topic', (req, res) => {
  const { course, topic } = req.params;
  const courseData = quizData[course];

  if (!courseData) {
    return res.status(404).json({ error: 'Course not found' });
  }

  const topicData = courseData[topic];

  if (!topicData) {
    return res.status(404).json({ error: 'Topic not found' });
  }

  res.json(topicData);
});

/* ===== START ===== */
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Backend działa na http://localhost:${PORT}`);
});