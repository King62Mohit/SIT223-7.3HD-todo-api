const request = require('supertest');
const app = require('../src/app');

// clear todos before each test so they don't bleed into each other
beforeEach(async () => {
  await request(app).delete('/todos');
});

describe('Health Check', () => {
  test('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('Todo CRUD', () => {
  test('GET /todos returns empty array initially', async () => {
    const res = await request(app).get('/todos');
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual([]);
  });

  test('POST /todos creates a todo', async () => {
    const res = await request(app)
      .post('/todos')
      .send({ title: 'Buy groceries' });
    expect(res.statusCode).toBe(201);
    expect(res.body.title).toBe('Buy groceries');
    expect(res.body.completed).toBe(false);
    expect(res.body.id).toBeDefined();
  });

  test('POST /todos fails without title', async () => {
    const res = await request(app).post('/todos').send({});
    expect(res.statusCode).toBe(400);
  });

  test('GET /todos/:id returns the todo', async () => {
    const created = await request(app).post('/todos').send({ title: 'Test todo' });
    const res = await request(app).get(`/todos/${created.body.id}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.title).toBe('Test todo');
  });

  test('GET /todos/:id returns 404 for missing todo', async () => {
    const res = await request(app).get('/todos/nonexistent-id');
    expect(res.statusCode).toBe(404);
  });

  test('PUT /todos/:id updates a todo', async () => {
    const created = await request(app).post('/todos').send({ title: 'Old title' });
    const res = await request(app)
      .put(`/todos/${created.body.id}`)
      .send({ title: 'New title', completed: true });
    expect(res.body.title).toBe('New title');
    expect(res.body.completed).toBe(true);
  });

  test('DELETE /todos/:id removes the todo', async () => {
    const created = await request(app).post('/todos').send({ title: 'Delete me' });
    const del = await request(app).delete(`/todos/${created.body.id}`);
    expect(del.statusCode).toBe(204);

    const get = await request(app).get(`/todos/${created.body.id}`);
    expect(get.statusCode).toBe(404);
  });
});