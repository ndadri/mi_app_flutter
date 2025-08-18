// globalConfig.js
// Módulo para manejar parámetros globales
const { Pool } = require('pg');
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'flutter_app',
    password: 'password',
    port: 5432,
});

// Obtener todos los parámetros globales
async function getGlobalConfig() {
    const result = await pool.query('SELECT * FROM global_config LIMIT 1');
    return result.rows[0] || {};
}

// Actualizar parámetros globales
async function updateGlobalConfig(params) {
    const {
        max_image_size,
        terms_text,
        features_enabled
    } = params;
    await pool.query(
        `UPDATE global_config SET max_image_size = $1, terms_text = $2, features_enabled = $3 WHERE id = 1`,
        [max_image_size, terms_text, features_enabled]
    );
    return true;
}

module.exports = {
    getGlobalConfig,
    updateGlobalConfig
};
