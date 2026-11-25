const request = require('supertest');
const app = require('../src/app');

jest.mock('../src/config/db', () => ({
  query: jest.fn().mockResolvedValue({ rows: [{ '?column?': 1 }] }),
}));

describe('GET /api/v1/health', () => {
  it('mengembalikan status database up', async () => {
    const response = await request(app).get('/api/v1/health');
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ data: { status: 'ok', db: 'up' } });
  });

  it('mengembalikan 503 tanpa detail database saat query gagal', async () => {
    const db = require('../src/config/db');
    db.query.mockRejectedValueOnce(new Error('detail internal rahasia'));

    const response = await request(app).get('/api/v1/health');

    expect(response.status).toBe(503);
    expect(response.body.error.details).toEqual([]);
    expect(JSON.stringify(response.body)).not.toContain('detail internal rahasia');
  });
});
