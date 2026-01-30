const express = require('express');
const cors = require('cors');
const quizData = require('./quizData.json');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/quiz/:course', (req, res) => {
  const course = req.params.course;
  const courseData = quizData[course];
  if (!courseData) return res.status(404).json({ error: 'Course not found' });
  const all = Object.values(courseData).flat();
  res.json(all);
});

app.get('/quiz/:course/:topic', (req, res) => {
  const course = req.params.course;
  const topic = req.params.topic;
  const courseData = quizData[course];
  if (!courseData) return res.status(404).json({ error: 'Course not found' });
  const topicData = courseData[topic];
  if (!topicData) return res.status(404).json({ error: 'Topic not found' });
  res.json(topicData);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Quiz API running on http://localhost:${PORT}`));