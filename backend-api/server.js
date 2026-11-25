require('dotenv').config();

const { validateEnv } = require('./src/config/env');

let env;
try {
  env = validateEnv(process.env);
} catch (error) {
  console.error(error.message);
  process.exit(1);
}

const app = require('./src/app');

app.listen(env.PORT, '0.0.0.0', () => {
  console.log(`Server SISDIK jalan di port ${env.PORT}`);
});