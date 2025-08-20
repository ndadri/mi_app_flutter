const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://anderson:123456@localhost:5432/petmatch',
});

async function optimizarEventos() {
    try {
        console.log('🚀 Optimizando tabla de eventos...');
        
        // Crear índices para mejorar rendimiento
        const indices = [
            'CREATE INDEX IF NOT EXISTS idx_eventos_fecha_creacion ON eventos(fecha_creacion DESC);',
            'CREATE INDEX IF NOT EXISTS idx_evento_asistencias_evento_id ON evento_asistencias(evento_id);',
            'CREATE INDEX IF NOT EXISTS idx_evento_asistencias_usuario_id ON evento_asistencias(usuario_id);',
            'CREATE INDEX IF NOT EXISTS idx_eventos_recientes ON eventos(fecha_creacion) WHERE fecha_creacion > NOW() - INTERVAL \'90 days\';'
        ];
        
        for (const indice of indices) {
            try {
                await pool.query(indice);
                console.log('✅ Índice creado:', indice.split(' ')[5]);
            } catch (indexError) {
                console.log('ℹ️  Índice ya existe:', indice.split(' ')[5]);
            }
        }
        
        // Verificar rendimiento de la consulta principal
        console.log('📊 Verificando rendimiento...');
        const start = Date.now();
        
        const query = `
            SELECT 
                e.id,
                e.nombre,
                e.fecha,
                e.hora,
                e.lugar,
                e.imagen,
                e.fecha_creacion,
                e.creado_por,
                ea.asistira,
                COUNT(ea2.id) as total_asistentes
            FROM eventos e
            LEFT JOIN evento_asistencias ea ON e.id = ea.evento_id AND ea.usuario_id = $1
            LEFT JOIN evento_asistencias ea2 ON e.id = ea2.evento_id AND ea2.asistira = true
            WHERE e.fecha_creacion > NOW() - INTERVAL '90 days'
            GROUP BY e.id, e.nombre, e.fecha, e.hora, e.lugar, e.imagen, e.fecha_creacion, e.creado_por, ea.asistira
            ORDER BY e.fecha_creacion DESC
            LIMIT 50
        `;
        
        const result = await pool.query(query, ['2']);
        const end = Date.now();
        
        console.log(`⚡ Consulta ejecutada en ${end - start}ms`);
        console.log(`📋 Eventos encontrados: ${result.rows.length}`);
        
        // Mostrar algunos eventos de muestra
        if (result.rows.length > 0) {
            console.log('🎉 Eventos recientes:');
            result.rows.slice(0, 3).forEach((evento, index) => {
                console.log(`   ${index + 1}. ${evento.nombre} - ${evento.fecha_creacion}`);
            });
        } else {
            console.log('📝 No hay eventos en la base de datos');
        }
        
        console.log('✅ Optimización completada');
        
    } catch (error) {
        console.error('❌ Error al optimizar:', error.message);
    } finally {
        await pool.end();
    }
}

optimizarEventos();
