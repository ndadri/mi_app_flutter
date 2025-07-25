-- ================================================
-- SCRIPT PARA AGREGAR SISTEMA DE ROLES
-- Pet Match Flutter App - Opción Simple
-- ================================================

-- Agregar columna de rol a la tabla usuarios
ALTER TABLE usuarios 
ADD COLUMN rol VARCHAR(20) DEFAULT 'usuario';

-- Agregar restricción para validar roles válidos
ALTER TABLE usuarios 
ADD CONSTRAINT check_rol_valido 
CHECK (rol IN ('usuario', 'administrador', 'moderador'));

-- Crear índice para búsquedas rápidas por rol
CREATE INDEX idx_usuarios_rol ON usuarios(rol);

-- Comentario en la columna
COMMENT ON COLUMN usuarios.rol IS 'Rol del usuario: usuario, administrador, moderador';

-- ================================================
-- PRE-REGISTRAR ADMINISTRADOR
-- ================================================

-- Opción 1: Crear nuevo usuario administrador
-- (Cambia los datos por los que quieras)
INSERT INTO usuarios (
    nombres, 
    apellidos, 
    correo, 
    contraseña, 
    genero, 
    ubicacion, 
    edad, 
    fecha_nacimiento, 
    rol, 
    verificado,
    codigo_verificacion
) VALUES (
    'Admin',
    'Principal', 
    'admin@petmatch.com',
    '$2b$10$example.hash.password', -- Debes hashear la contraseña
    'Otro',
    'Sistema',
    25,
    '1999-01-01',
    'administrador',
    true,
    '000000'
);

-- Opción 2: Convertir usuario existente en administrador
-- (Descomenta y cambia el email por el tuyo)
-- UPDATE usuarios 
-- SET rol = 'administrador' 
-- WHERE correo = 'tu-email@ejemplo.com';

-- ================================================
-- VERIFICAR RESULTADOS
-- ================================================

-- Ver todos los usuarios con sus roles
SELECT id, nombres, apellidos, correo, rol, verificado 
FROM usuarios 
ORDER BY rol, nombres;

-- Contar usuarios por rol
SELECT rol, COUNT(*) as cantidad 
FROM usuarios 
GROUP BY rol;

-- ================================================
-- INSTRUCCIONES:
-- ================================================
-- 1. Ejecuta este script en tu base de datos
-- 2. Para crear admin con contraseña hasheada, usa el script JS
-- 3. O convierte un usuario existente en administrador
-- ================================================
