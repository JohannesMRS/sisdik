const { validatePasswordPolicy } = require('../src/utils/password');

describe('Password policy', () => {
  it('menolak password lemah dan sama dengan identifier', () => {
    const details = validatePasswordPolicy('2301001', '2301001', 'Awal12345');
    expect(details.map((item) => item.field)).toContain('newPassword');
  });

  it('menerima password kuat yang berbeda', () => {
    const details = validatePasswordPolicy('BaruRahasia123', '2301001', 'Awal12345');
    expect(details).toEqual([]);
  });

  it('menolak password yang sama dengan password lama', () => {
    const details = validatePasswordPolicy('Awal12345', '2301001', 'Awal12345');
    expect(details.some((item) => item.message.includes('password lama'))).toBe(true);
  });
});
