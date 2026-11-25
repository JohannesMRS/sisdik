const request = require('supertest');
const app = require('../src/app');

jest.mock('../src/config/db', () => {
  const query = jest.fn();
  const pool = { connect: jest.fn() };
  return { pool, query, testConnection: jest.fn() };
});

const { query, pool } = require('../src/config/db');

describe('Auth API', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('login gagal dengan kredensial tidak ditemukan menggunakan pesan generik', async () => {
    query.mockResolvedValueOnce({ rows: [] });

    const response = await request(app)
      .post('/api/v1/auth/login')
      .send({ identifier: 'tidakada', password: 'Password123' });

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('INVALID_CREDENTIALS');
  });

  it('change-password menolak tanpa token', async () => {
    const response = await request(app)
      .post('/api/v1/auth/change-password')
      .send({ currentPassword: 'Awal12345', newPassword: 'Baru12345', confirmPassword: 'Baru12345' });

    expect(response.status).toBe(401);
  });

  it('me menolak tanpa token', async () => {
    const response = await request(app).get('/api/v1/me');
    expect(response.status).toBe(401);
  });

  it('logout menolak tanpa token', async () => {
    const response = await request(app).post('/api/v1/auth/logout');
    expect(response.status).toBe(401);
  });

  it('forgot-password tetap mengembalikan sukses generik untuk identifier tidak terdaftar', async () => {
    query.mockResolvedValueOnce({ rows: [] });
    query.mockResolvedValueOnce({ rows: [] });

    const response = await request(app)
      .post('/api/v1/auth/forgot-password')
      .send({ identifier: 'tidakada' });

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ data: {} });
  });
});
