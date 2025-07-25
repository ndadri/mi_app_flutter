// Importamos el módulo 'express' y creamos un router
const express = require('express');
const router = express.Router();

// Importamos el módulo 'pg' para conectar con PostgreSQL
const { Pool } = require('pg');

// Creamos una nueva instancia de Pool usando la cadena de conexión desde las variables de entorno
const pool = new Pool({
    connectionString: process.env.DATABASE_URL, // Debes tener esta variable definida en tu entorno (.env)
});

// 📌 Ruta POST para registrar una mascota
router.post('/', async (req, res) => {
    console.log('🐕 Intentando registrar mascota...');
    console.log('📦 Datos recibidos:', req.body);
    
    // Extraemos los datos del cuerpo de la solicitud (request body)
    const {
        nombre,
        edad,
        tipo_animal,
        sexo,
        ciudad,
        foto_url,
        estado,
        id_usuario
    } = req.body;

    console.log('📋 Datos extraídos:', {
        nombre, edad, tipo_animal, sexo, ciudad, foto_url, estado, id_usuario
    });

    try {
        // Validación exhaustiva de todos los campos obligatorios
        if (!nombre || !edad || !tipo_animal || !sexo || !ciudad || !estado || !id_usuario) {
            return res.status(400).json({ 
                success: false, 
                message: 'Todos los campos son obligatorios: nombre, edad, tipo_animal, sexo, ciudad, estado, id_usuario' 
            });
        }

        // Validación específica de la foto (opcional para pruebas)
        // if (!foto_url || foto_url.trim() === '') {
        //     return res.status(400).json({ 
        //         success: false, 
        //         message: 'La foto de la mascota es obligatoria' 
        //     });
        // }

        // Validación del nombre
        if (typeof nombre !== 'string' || nombre.trim().length < 2 || nombre.trim().length > 30) {
            return res.status(400).json({ 
                success: false, 
                message: 'El nombre debe tener entre 2 y 30 caracteres' 
            });
        }

        // Validación de caracteres especiales en el nombre (solo letras y espacios)
        const nombreRegex = /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/;
        if (!nombreRegex.test(nombre.trim())) {
            return res.status(400).json({ 
                success: false, 
                message: 'El nombre solo puede contener letras y espacios' 
            });
        }

        // Validación de nombres de prueba o muy simples
        const nombresInvalidos = ['test', 'prueba', 'ejemplo', 'aaa', 'bbb', 'xxx', 'zzz'];
        if (nombresInvalidos.includes(nombre.trim().toLowerCase())) {
            return res.status(400).json({ 
                success: false, 
                message: 'Por favor ingresa un nombre real para tu mascota' 
            });
        }

        // Validación de la edad (unificada con frontend)
        const edadNum = parseInt(edad);
        if (isNaN(edadNum) || edadNum <= 0 || edadNum > 20) {
            return res.status(400).json({ 
                success: false, 
                message: 'La edad debe ser un número entre 1 y 20 años' 
            });
        }

        // Validación del tipo de animal
        const tiposValidos = ['Perro', 'Gato', 'Ave', 'Otro'];
        if (!tiposValidos.includes(tipo_animal)) {
            return res.status(400).json({ 
                success: false, 
                message: 'Tipo de animal no válido. Debe ser: Perro, Gato, Ave u Otro' 
            });
        }

        // Validación del sexo
        const sexosValidos = ['Macho', 'Hembra', 'Otro'];
        if (!sexosValidos.includes(sexo)) {
            return res.status(400).json({ 
                success: false, 
                message: 'Sexo no válido. Debe ser: Macho, Hembra u Otro' 
            });
        }

        // Validación de la ciudad (viene de la ubicación del usuario)
        if (typeof ciudad !== 'string' || ciudad.trim().length < 2) {
            return res.status(400).json({ 
                success: false, 
                message: 'Error: Ubicación del usuario no válida' 
            });
        }

        // Validación del estado
        const estadosValidos = ['Soltero', 'Buscando pareja'];
        if (!estadosValidos.includes(estado)) {
            return res.status(400).json({ 
                success: false, 
                message: 'Estado no válido. Debe ser: Soltero o Buscando pareja' 
            });
        }

        // Validación del ID de usuario
        const idUsuarioNum = parseInt(id_usuario);
        if (isNaN(idUsuarioNum) || idUsuarioNum <= 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'ID de usuario no válido' 
            });
        }

        // Verificar si ya existe una mascota con el mismo nombre para este usuario
        const existingPet = await pool.query(
            'SELECT id, nombre FROM mascotas WHERE LOWER(nombre) = LOWER($1) AND id_usuario = $2',
            [nombre.trim(), idUsuarioNum]
        );

        if (existingPet.rows.length > 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'Ya tienes una mascota registrada con ese nombre' 
            });
        }

        // Insertamos los datos en la base de datos (tabla 'mascotas')
        console.log('💾 Intentando insertar en base de datos...');
        const result = await pool.query(
            `INSERT INTO mascotas (nombre, edad, tipo_animal, sexo, ciudad, foto_url, estado, id_usuario)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
             RETURNING *`, // Devolvemos la fila recién insertada
            [nombre.trim(), edadNum, tipo_animal, sexo, ciudad.trim(), foto_url, estado, idUsuarioNum]
        );
        
        console.log('✅ Mascota registrada exitosamente:', result.rows[0]);

        // Si todo va bien, devolvemos la mascota registrada
        res.json({ success: true, mascota: result.rows[0] });

    } catch (err) {
        // Si ocurre un error en el servidor o la base de datos, lo mostramos en consola y enviamos respuesta de error
        console.error('❌ Error al registrar mascota:', err);
        console.error('📋 Detalles del error:', err.message);
        console.error('📋 Stack trace:', err.stack);
        res.status(500).json({ success: false, message: 'Error interno del servidor: ' + err.message });
    }
});

// 📌 Ruta GET para obtener todas las mascotas de un usuario
router.get('/user/:id_usuario', async (req, res) => {
    const { id_usuario } = req.params;

    try {
        // Validación: Verificamos que se proporcione el ID del usuario
        if (!id_usuario) {
            return res.status(400).json({ success: false, message: 'ID de usuario requerido' });
        }

        // Obtenemos todas las mascotas del usuario desde la base de datos
        const result = await pool.query(
            `SELECT * FROM mascotas WHERE id_usuario = $1 ORDER BY nombre`,
            [id_usuario]
        );

        // Devolvemos las mascotas encontradas
        res.json({ success: true, mascotas: result.rows });

    } catch (err) {
        // Si ocurre un error en el servidor o la base de datos, lo mostramos en consola y enviamos respuesta de error
        console.error('❌ Error al obtener mascotas del usuario:', err.message);
        res.status(500).json({ success: false, message: 'Error interno del servidor' });
    }
});

// 📌 Ruta DELETE para eliminar una mascota
router.delete('/:id', async (req, res) => {
    const { id } = req.params;

    try {
        // Validar que el ID sea un número válido
        const idMascota = parseInt(id);
        if (isNaN(idMascota) || idMascota <= 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'ID de mascota inválido' 
            });
        }

        // Verificar que la mascota existe antes de eliminarla
        const checkResult = await pool.query(
            'SELECT id, nombre FROM mascotas WHERE id = $1',
            [idMascota]
        );

        if (checkResult.rows.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'Mascota no encontrada' 
            });
        }

        const nombreMascota = checkResult.rows[0].nombre;

        // Eliminar la mascota de la base de datos
        const deleteResult = await pool.query(
            'DELETE FROM mascotas WHERE id = $1 RETURNING id',
            [idMascota]
        );

        if (deleteResult.rows.length > 0) {
            console.log(`✅ Mascota "${nombreMascota}" (ID: ${idMascota}) eliminada exitosamente`);
            res.json({ 
                success: true, 
                message: `Mascota "${nombreMascota}" eliminada exitosamente`,
                deletedId: idMascota
            });
        } else {
            res.status(500).json({ 
                success: false, 
                message: 'No se pudo eliminar la mascota' 
            });
        }

    } catch (err) {
        console.error('❌ Error al eliminar mascota:', err.message);
        res.status(500).json({ 
            success: false, 
            message: 'Error interno del servidor al eliminar mascota' 
        });
    }
});

// 📌 Ruta PUT para actualizar una mascota
router.put('/update', async (req, res) => {
    const { 
        id, 
        nombre, 
        edad, 
        tipo_animal, 
        sexo, 
        ciudad, 
        foto_url, 
        estado, 
        id_usuario 
    } = req.body;

    try {
        // Validación de campos obligatorios
        if (!id || !nombre || !edad || !tipo_animal || !sexo || !ciudad || !id_usuario) {
            return res.status(400).json({
                success: false,
                message: 'Todos los campos son obligatorios: id, nombre, edad, tipo_animal, sexo, ciudad, id_usuario'
            });
        }

        // Validar que el ID sea un número válido
        const idMascota = parseInt(id);
        const edadNum = parseInt(edad);
        const idUsuarioNum = parseInt(id_usuario);

        if (isNaN(idMascota) || idMascota <= 0) {
            return res.status(400).json({
                success: false,
                message: 'ID de mascota no válido'
            });
        }

        if (isNaN(edadNum) || edadNum <= 0 || edadNum > 30) {
            return res.status(400).json({
                success: false,
                message: 'Edad debe ser un número entre 1 y 30'
            });
        }

        if (isNaN(idUsuarioNum) || idUsuarioNum <= 0) {
            return res.status(400).json({
                success: false,
                message: 'ID de usuario no válido'
            });
        }

        // Verificar que la mascota existe y pertenece al usuario
        const existingPet = await pool.query(
            'SELECT id, id_usuario FROM mascotas WHERE id = $1',
            [idMascota]
        );

        if (existingPet.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Mascota no encontrada'
            });
        }

        if (existingPet.rows[0].id_usuario !== idUsuarioNum) {
            return res.status(403).json({
                success: false,
                message: 'No tienes permisos para editar esta mascota'
            });
        }

        // Verificar si ya existe otra mascota con el mismo nombre para este usuario
        const duplicateCheck = await pool.query(
            'SELECT id FROM mascotas WHERE LOWER(nombre) = LOWER($1) AND id_usuario = $2 AND id != $3',
            [nombre.trim(), idUsuarioNum, idMascota]
        );

        if (duplicateCheck.rows.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'Ya tienes otra mascota registrada con ese nombre'
            });
        }

        // Actualizar la mascota
        console.log('💾 Actualizando mascota en base de datos...');
        const result = await pool.query(
            `UPDATE mascotas 
             SET nombre = $1, edad = $2, tipo_animal = $3, sexo = $4, 
                 ciudad = $5, foto_url = $6, estado = $7
             WHERE id = $8 AND id_usuario = $9
             RETURNING *`,
            [
                nombre.trim(), 
                edadNum, 
                tipo_animal, 
                sexo, 
                ciudad.trim(), 
                foto_url, 
                estado || 'Soltero', 
                idMascota, 
                idUsuarioNum
            ]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'No se pudo actualizar la mascota'
            });
        }

        console.log('✅ Mascota actualizada exitosamente:', result.rows[0]);

        res.json({
            success: true,
            message: 'Mascota actualizada exitosamente',
            mascota: result.rows[0]
        });

    } catch (err) {
        console.error('❌ Error al actualizar mascota:', err);
        console.error('📋 Detalles del error:', err.message);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor: ' + err.message
        });
    }
});

// Exportamos el router para que pueda ser utilizado en otros archivos del backend
module.exports = router;