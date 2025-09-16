const { Pool } = require('pg');

const pool = new Pool({
    connectionString: 'postgresql://Alexis:123@localhost:5432/petmatch'
});

async function checkCompleteDatabase() {
    try {
        console.log('🔍 VERIFICANDO BASE DE DATOS COMPLETA...\n');
        
        // 1. Mostrar todas las tablas existentes
        console.log('📋 TABLAS EXISTENTES:');
        const tablesResult = await pool.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name;
        `);
        
        if (tablesResult.rows.length === 0) {
            console.log('❌ No se encontraron tablas en la base de datos.');
            return;
        }
        
        tablesResult.rows.forEach((row, index) => {
            console.log(`${index + 1}. ${row.table_name}`);
        });
        
        console.log('\n' + '='.repeat(60) + '\n');
        
        // 2. Para cada tabla, mostrar estructura y contenido
        for (const tableRow of tablesResult.rows) {
            const tableName = tableRow.table_name;
            
            console.log(`📊 TABLA: ${tableName.toUpperCase()}`);
            console.log('-'.repeat(40));
            
            // Estructura de la tabla
            const structureResult = await pool.query(`
                SELECT 
                    column_name, 
                    data_type, 
                    is_nullable, 
                    column_default,
                    character_maximum_length
                FROM information_schema.columns 
                WHERE table_name = $1 
                ORDER BY ordinal_position;
            `, [tableName]);
            
            console.log('🏗️  ESTRUCTURA:');
            structureResult.rows.forEach((col, index) => {
                const length = col.character_maximum_length ? `(${col.character_maximum_length})` : '';
                const nullable = col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL';
                const defaultValue = col.column_default ? ` DEFAULT ${col.column_default}` : '';
                console.log(`   ${index + 1}. ${col.column_name} - ${col.data_type}${length} ${nullable}${defaultValue}`);
            });
            
            // Contar registros
            const countResult = await pool.query(`SELECT COUNT(*) as total FROM ${tableName}`);
            const totalRecords = countResult.rows[0].total;
            
            console.log(`\n📊 TOTAL DE REGISTROS: ${totalRecords}`);
            
            // Si hay registros, mostrar algunos ejemplos
            if (totalRecords > 0) {
                const sampleResult = await pool.query(`SELECT * FROM ${tableName} LIMIT 3`);
                console.log('\n📝 EJEMPLOS DE DATOS:');
                
                if (sampleResult.rows.length > 0) {
                    // Mostrar nombres de columnas
                    const columnNames = Object.keys(sampleResult.rows[0]);
                    console.log(`   Columnas: ${columnNames.join(' | ')}`);
                    
                    // Mostrar datos de ejemplo
                    sampleResult.rows.forEach((row, index) => {
                        const values = columnNames.map(col => {
                            const value = row[col];
                            if (value === null) return 'NULL';
                            if (typeof value === 'string' && value.length > 30) {
                                return value.substring(0, 30) + '...';
                            }
                            return value;
                        });
                        console.log(`   ${index + 1}. ${values.join(' | ')}`);
                    });
                }
            }
            
            // Mostrar índices
            const indexResult = await pool.query(`
                SELECT 
                    indexname,
                    indexdef
                FROM pg_indexes 
                WHERE tablename = $1 
                AND schemaname = 'public'
            `, [tableName]);
            
            if (indexResult.rows.length > 0) {
                console.log('\n🔗 ÍNDICES:');
                indexResult.rows.forEach((idx, index) => {
                    console.log(`   ${index + 1}. ${idx.indexname}`);
                });
            }
            
            console.log('\n' + '='.repeat(60) + '\n');
        }
        
        // 3. Mostrar relaciones/foreign keys
        console.log('🔗 RELACIONES ENTRE TABLAS:');
        const foreignKeysResult = await pool.query(`
            SELECT
                tc.table_name,
                kcu.column_name,
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name
            FROM
                information_schema.table_constraints AS tc
                JOIN information_schema.key_column_usage AS kcu
                  ON tc.constraint_name = kcu.constraint_name
                  AND tc.table_schema = kcu.table_schema
                JOIN information_schema.constraint_column_usage AS ccu
                  ON ccu.constraint_name = tc.constraint_name
                  AND ccu.table_schema = tc.table_schema
            WHERE tc.constraint_type = 'FOREIGN KEY'
            AND tc.table_schema = 'public';
        `);
        
        if (foreignKeysResult.rows.length > 0) {
            foreignKeysResult.rows.forEach((fk, index) => {
                console.log(`${index + 1}. ${fk.table_name}.${fk.column_name} → ${fk.foreign_table_name}.${fk.foreign_column_name}`);
            });
        } else {
            console.log('No se encontraron relaciones de foreign keys.');
        }
        
    } catch (error) {
        console.error('❌ Error al verificar la base de datos:', error.message);
        console.error('Stack:', error.stack);
    } finally {
        await pool.end();
    }
}

checkCompleteDatabase();
