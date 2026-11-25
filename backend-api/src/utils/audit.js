const { query } = require('../config/db');

async function writeAudit({ userId = null, action, entityType = null, entityId = null, ipAddress = null, metadata = null }) {
  await query(
    `INSERT INTO audit_logs (user_id, action, entity_type, entity_id, ip_address, metadata)
     VALUES ($1, $2, $3, $4, $5, $6::jsonb)`,
    [userId, action, entityType, entityId, ipAddress, metadata ? JSON.stringify(metadata) : null],
  );
}

module.exports = { writeAudit };
