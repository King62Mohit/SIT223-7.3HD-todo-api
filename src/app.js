const express = require('express');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(express.json());

// in-memory storage (simple, no DB needed)
let todos = [];

// health endpoint — used by monitoring stage
app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime(), timestamp: Date.now() });
});

// get all todos
app.get('/todos', (req, res) => {
  res.json(todos);
});

// get one todo
app.get('/todos/:id', (req, res) => {
  const todo = todos.find(t => t.id === req.params.id);
  if (!todo) return res.status(404).json({ error: 'Todo not found' });
  res.json(todo);
});

// create a todo
app.post('/todos', (req, res) => {
  const { title } = req.body;
  if (!title) return res.status(400).json({ error: 'Title is required' });

  const todo = { id: uuidv4(), title, completed: false, createdAt: new Date() };
  todos.push(todo);
  res.status(201).json(todo);
});

// update a todo
app.put('/todos/:id', (req, res) => {
  const todo = todos.find(t => t.id === req.params.id);
  if (!todo) return res.status(404).json({ error: 'Todo not found' });

  const { title, completed } = req.body;
  if (title !== undefined) todo.title = title;
  if (completed !== undefined) todo.completed = completed;
  res.json(todo);
});

// delete a todo
app.delete('/todos/:id', (req, res) => {
  const index = todos.findIndex(t => t.id === req.params.id);
  if (index === -1) return res.status(404).json({ error: 'Todo not found' });

  todos.splice(index, 1);
  res.status(204).send();
});

// reset helper (used in tests to clear state)
app.delete('/todos', (req, res) => {
  todos = [];
  res.status(204).send();
});

const PORT = process.env.PORT || 3000;
// only start listening if run directly (not imported in tests)
if (require.main === module) {
  app.listen(PORT, () => console.log(`Todo API running on port ${PORT}`));
}

module.exports = app;