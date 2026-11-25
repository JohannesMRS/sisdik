function notFoundHandler(req, res) {
  res.status(404).json({
    error: {
      code: 'NOT_FOUND',
      message: 'Rute tidak ditemukan.',
      details: [],
    },
  });
}

function errorHandler(error, req, res, next) {
  const status = error.status || 500;
  const code = error.code || 'INTERNAL_SERVER_ERROR';
  res.status(status).json({
    error: {
      code,
      message: status >= 500
        ? 'Terjadi gangguan pada server. Coba lagi sebentar lagi.'
        : (error.publicMessage || 'Permintaan tidak dapat diproses.'),
      details: status >= 500 ? [] : (error.details || []),
    },
  });
}

module.exports = { notFoundHandler, errorHandler };
