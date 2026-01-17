import request from 'supertest';
import app from '../src/index.js';

describe('API Endpoints', () => {
  describe('GET /health', () => {
    it('should return 200 with ok status', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('ok');
    });

    it('should return ISO timestamp', async () => {
      const res = await request(app).get('/health');
      expect(res.body.timestamp).toBeDefined();
    });
  });

  describe('GET /api/users', () => {
    it('should return list of users', async () => {
      const res = await request(app).get('/api/users');
      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body.users)).toBe(true);
      expect(res.body.users.length).toBeGreaterThan(0);
    });

    it('should return user with id, name, email', async () => {
      const res = await request(app).get('/api/users');
      const user = res.body.users[0];
      expect(user).toHaveProperty('id');
      expect(user).toHaveProperty('name');
      expect(user).toHaveProperty('email');
    });
  });

  describe('GET /notfound', () => {
    it('should return 404', async () => {
      const res = await request(app).get('/notfound');
      expect(res.statusCode).toBe(404);
    });
  });
});
