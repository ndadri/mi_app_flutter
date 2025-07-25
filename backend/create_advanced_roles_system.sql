-- ================================================
-- SISTEMA DE ROLES AVANZADO - PET MATCH V2
-- Creación de tabla de roles y relación con usuarios
-- ================================================

-- 1. CREAR TABLA DE ROLES (si no existe)
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    permisos JSONB DEFAULT '{}',
    activo BOOLEAN DEFAULT true,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. LIMPIAR E INSERTAR ROLES PREDEFINIDOS
DELETE FROM roles;
INSERT INTO roles (id, nombre, descripcion, permisos) VALUES
(1, 'usuario', 'Usuario normal con permisos básicos', '{
    "usuarios": {"crear": false, "leer": false, "actualizar": false, "eliminar": false},
    "mascotas": {"crear": true, "leer": true, "actualizar": true, "eliminar": true},
    "reportes": {"generar": false, "exportar": false},
    "panel_admin": false
}'),
(2, 'administrador', 'Administrador del sistema con acceso completo', '{
    "usuarios": {"crear": true, "leer": true, "actualizar": true, "eliminar": true},
    "mascotas": {"crear": true, "leer": true, "actualizar": true, "eliminar": true},
    "reportes": {"generar": true, "exportar": true},
    "panel_admin": true
}'),
(3, 'moderador', 'Moderador con permisos intermedios', '{
    "usuarios": {"crear": false, "leer": true, "actualizar": false, "eliminar": false},
    "mascotas": {"crear": true, "leer": true, "actualizar": true, "eliminar": true},
    "reportes": {"generar": true, "exportar": false},
    "panel_admin": false
}');

-- Reiniciar secuencia para que el próximo ID sea 4
SELECT setval('roles_id_seq', 3, true);

-- 3. AGREGAR COLUMNA id_rol A TABLA USUARIOS (si no existe)
ALTER TABLE usuarios 
ADD COLUMN IF NOT EXISTS id_rol INTEGER DEFAULT 1;

-- 4. ELIMINAR CONSTRAINT EXISTENTE SI EXISTE Y CREAR NUEVA
ALTER TABLE usuarios DROP CONSTRAINT IF EXISTS fk_usuarios_rol;
ALTER TABLE usuarios 
ADD CONSTRAINT fk_usuarios_rol 
FOREIGN KEY (id_rol) REFERENCES roles(id);

-- 5. ASIGNAR ROL USUARIO POR DEFECTO A USUARIOS EXISTENTES
UPDATE usuarios 
SET id_rol = 1 
WHERE id_rol IS NULL OR id_rol NOT IN (1, 2, 3);

-- 6. CREAR ÍNDICES PARA MEJORAR RENDIMIENTO
DROP INDEX IF EXISTS idx_usuarios_id_rol;
DROP INDEX IF EXISTS idx_usuarios_rol;
DROP INDEX IF EXISTS idx_roles_nombre;

CREATE INDEX idx_usuarios_id_rol ON usuarios(id_rol);
CREATE INDEX idx_roles_nombre ON roles(nombre);

-- 7. CREAR/ACTUALIZAR VISTA PARA CONSULTAS FÁCILES
DROP VIEW IF EXISTS vista_usuarios_roles;
CREATE VIEW vista_usuarios_roles AS
SELECT 
    u.id,
    u.nombres,
    u.apellidos,
    u.correo,
    u.genero,
    u.ubicacion,
    u.edad,
    u.fecha_nacimiento,
    u.foto_perfil_url,
    u.verificado,
    u.fecha_registro,
    r.id as rol_id,
    r.nombre as rol_nombre,
    r.descripcion as rol_descripcion,
    r.permisos as rol_permisos
FROM usuarios u
LEFT JOIN roles r ON u.id_rol = r.id;

-- 8. FUNCIÓN PARA VERIFICAR PERMISOS
CREATE OR REPLACE FUNCTION verificar_permiso(
    usuario_id INTEGER,
    recurso TEXT,
    accion TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    permisos_usuario JSONB;
BEGIN
    SELECT r.permisos INTO permisos_usuario
    FROM usuarios u
    JOIN roles r ON u.id_rol = r.id
    WHERE u.id = usuario_id;
    
    IF permisos_usuario IS NULL THEN
        RETURN FALSE;
    END IF;
    
    RETURN COALESCE(
        (permisos_usuario -> recurso ->> accion)::BOOLEAN,
        FALSE
    );
END;
$$ LANGUAGE plpgsql;

-- 9. VERIFICAR ESTRUCTURA CREADA
SELECT 'Roles creados:' as info;
SELECT id, nombre, descripcion FROM roles ORDER BY id;

SELECT 'Usuarios con roles:' as info;
SELECT COUNT(*) as total_usuarios FROM usuarios;

-- ================================================
-- INSTRUCCIONES DE USO:
-- ================================================
-- INSTRUCCIONES DE USO:
-- ================================================
-- 1. Ejecutar este script para crear la estructura completa
-- 2. Usar create_admin.js para crear el primer administrador
-- 3. Los nuevos usuarios tendrán rol 'usuario' por defecto (id_rol = 1)
-- 4. Usar verificar_permiso(user_id, 'mascotas', 'crear') para validar permisos
-- ================================================

SELECT '✅ Sistema de roles avanzado creado exitosamente!' as resultado;
