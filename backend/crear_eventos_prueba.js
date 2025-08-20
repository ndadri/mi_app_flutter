const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://anderson:123456@localhost:5432/petmatch',
});

async function crearEventosPrueba() {
    try {
        console.log('🎉 Creando eventos de prueba para mejorar la experiencia...');
        
        const eventos = [
            {
                nombre: 'Adopción de Mascotas - Plaza Principal',
                fecha: '2025-08-25',
                hora: '10:00',
                lugar: 'Plaza Principal, Centro de la Ciudad',
                creado_por: 2
            },
            {
                nombre: 'Caminata Canina Dominical',
                fecha: '2025-08-24',
                hora: '08:00',
                lugar: 'Parque Central',
                creado_por: 2
            },
            {
                nombre: 'Charla sobre Cuidado de Mascotas',
                fecha: '2025-08-26',
                hora: '15:30',
                lugar: 'Veterinaria San Antonio',
                creado_por: 2
            }
        ];
        
        for (const evento of eventos) {
            try {
                const query = `
                    INSERT INTO eventos (nombre, fecha, hora, lugar, creado_por, fecha_creacion)
                    VALUES ($1, $2, $3, $4, $5, NOW())
                    RETURNING id, nombre
                `;
                
                const result = await pool.query(query, [
                    evento.nombre,
                    evento.fecha,
                    evento.hora,
                    evento.lugar,
                    evento.creado_por
                ]);
                
                console.log(`✅ Evento creado: ${result.rows[0].nombre} (ID: ${result.rows[0].id})`);
                
            } catch (error) {
                if (error.code === '23505') {
                    console.log(`ℹ️  Evento ya existe: ${evento.nombre}`);
                } else {
                    console.error(`❌ Error creando evento ${evento.nombre}:`, error.message);
                }
            }
        }
        
        // Verificar eventos totales
        const countResult = await pool.query('SELECT COUNT(*) FROM eventos');
        console.log(`📊 Total de eventos en la base de datos: ${countResult.rows[0].count}`);
        
        console.log('✅ Proceso completado');
        
    } catch (error) {
        console.error('❌ Error general:', error.message);
    } finally {
        await pool.end();
    }
}

crearEventosPrueba();
