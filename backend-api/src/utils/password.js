const argon2 = require('argon2');

const options = {
  type: argon2.argon2id,
  memoryCost: 19456,
  timeCost: 2,
  parallelism: 1,
};

async function hashPassword(password) {
  return argon2.hash(password, options);
}

async function verifyPassword(passwordHash, password) {
  return argon2.verify(passwordHash, password);
}

function validatePasswordPolicy(password, identifier, currentPassword) {
  const details = [];
  if (typeof password !== 'string' || password.length < 8) {
    details.push({ field: 'newPassword', message: 'Password minimal 8 karakter.' });
  }
  if (typeof password === 'string' && password.length > 72) {
    details.push({ field: 'newPassword', message: 'Password maksimal 72 karakter.' });
  }
  if (typeof password !== 'string' || !/[A-Za-z]/.test(password) || !/[0-9]/.test(password)) {
    details.push({ field: 'newPassword', message: 'Password harus mengandung huruf dan angka.' });
  }
  if (typeof password === 'string' && typeof identifier === 'string' && password === identifier) {
    details.push({ field: 'newPassword', message: 'Password tidak boleh sama dengan NIM/NIP.' });
  }
  if (typeof password === 'string' && typeof currentPassword === 'string' && password === currentPassword) {
    details.push({ field: 'newPassword', message: 'Password baru tidak boleh sama dengan password lama.' });
  }
  return details;
}

module.exports = { hashPassword, verifyPassword, validatePasswordPolicy };
