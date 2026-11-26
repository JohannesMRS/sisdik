const request = require('supertest');

jest.mock('../src/middlewares/authenticate', () => {
  const publicError = (status, code, message, details = []) => {
    const error = new Error(message);
    error.status = status;
    error.code = code;
    error.publicMessage = message;
    error.details = details;
    return error;
  };
  return {
    publicError,
    authenticate: (req, res, next) => { req.user = { id: '11111111-1111-4111-8111-111111111111', role: 'student', identifier: '2301001' }; next(); },
    requireRole: () => (req, res, next) => next(),
    requirePasswordChanged: (req, res, next) => next(),
  };
});

jest.mock('../src/config/db', () => {
  const query = jest.fn();
  const client = {
    query: jest.fn(),
    release: jest.fn(),
  };
  const pool = { connect: jest.fn(async () => client) };
  return { pool, query, testConnection: jest.fn(), __client: client };
});

const app = require('../src/app');
const { query, __client } = require('../src/config/db');

describe('Student API', () => {
  beforeEach(() => {
    jest.resetAllMocks();
    const db = require('../src/config/db');
    db.__client.query.mockResolvedValue({ rows: [] });
    db.pool.connect.mockResolvedValue(db.__client);
  });

  it('mengembalikan home assignments milik mahasiswa', async () => {
    query.mockResolvedValueOnce({ rows: [{
      id: '22222222-2222-4222-8222-222222222222', course_code: 'IF301', course_name: 'Mobile',
      title: 'Layout', description: 'Buat layout', deadline: '2026-12-08T09:59:00.000Z', submitted_at: null,
    }] });

    const response = await request(app).get('/api/v1/student/home/assignments');

    expect(response.status).toBe(200);
    expect(response.body.data[0].status).toBe('Belum dikumpulkan');
  });

  it('mengembalikan 404 untuk course milik mahasiswa lain', async () => {
    query.mockResolvedValueOnce({ rows: [] });

    const response = await request(app).get('/api/v1/student/courses/33333333-3333-4333-8333-333333333333');

    expect(response.status).toBe(404);
    expect(response.body.error.code).toBe('NOT_FOUND');
  });

  it('menolak ekstensi PDF dengan isi bukan PDF', async () => {
    query.mockResolvedValueOnce({ rows: [{ deadline: '2099-12-08T09:59:00.000Z' }] });

    const response = await request(app)
      .post('/api/v1/student/assignments/44444444-4444-4444-8444-444444444444/submissions')
      .attach('file', Buffer.from('bukan-pdf'), { filename: 'tugas.pdf', contentType: 'application/pdf' });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('FILE_TYPE_NOT_ALLOWED');
  });

  it('menolak pengumpulan setelah deadline', async () => {
    query.mockResolvedValueOnce({ rows: [{ deadline: '2020-12-08T09:59:00.000Z' }] });

    const response = await request(app)
      .post('/api/v1/student/assignments/44444444-4444-4444-8444-444444444444/submissions')
      .attach('file', Buffer.from('%PDF-1.4\n%%EOF'), { filename: 'tugas.pdf', contentType: 'application/pdf' });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('DEADLINE_PASSED');
  });

  it('riwayat menghindari pengiriman path file', async () => {
    query.mockResolvedValueOnce({ rows: [{ '1': 1 }] });
    query.mockResolvedValueOnce({ rows: [{
      id: '55555555-5555-4555-8555-555555555555', original_filename: 'tugas.pdf', mime_type: 'application/pdf',
      size_bytes: 20, submitted_at: '2026-11-26T08:00:00.000Z', is_latest: true,
    }] });

    const response = await request(app).get('/api/v1/student/assignments/44444444-4444-4444-8444-444444444444/submissions');

    expect(response.status).toBe(200);
    expect(JSON.stringify(response.body)).not.toContain('stored_filename');
    expect(response.body.data[0].originalFilename).toBe('tugas.pdf');
  });
});
