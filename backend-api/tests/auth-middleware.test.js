const { requireRole, requirePasswordChanged, publicError } = require('../src/middlewares/authenticate');

describe('Auth middleware', () => {
  it('requireRole menolak role yang tidak sesuai', () => {
    const middleware = requireRole('lecturer');
    const req = { user: { role: 'student' } };

    middleware(req, {}, (error) => {
      expect(error.status).toBe(403);
      expect(error.code).toBe('FORBIDDEN');
    });
  });

  it('requirePasswordChanged menolak endpoint privat wajib ganti password', () => {
    const req = { user: { mustChangePassword: true } };

    requirePasswordChanged(req, {}, (error) => {
      expect(error.status).toBe(403);
      expect(error.code).toBe('PASSWORD_CHANGE_REQUIRED');
    });
  });

  it('requirePasswordChanged mengizinkan pengguna yang sudah ganti password', () => {
    const req = { user: { mustChangePassword: false } };
    const next = jest.fn();

    requirePasswordChanged(req, {}, next);

    expect(next).toHaveBeenCalledWith();
  });

  it('publicError menghasilkan struktur status dan kode yang konsisten', () => {
    const error = publicError(401, 'TOKEN_REVOKED', 'Sesi tidak valid');
    expect(error.status).toBe(401);
    expect(error.code).toBe('TOKEN_REVOKED');
  });
});
