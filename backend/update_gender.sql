-- Script para actualizar la restricción de género
ALTER TABLE usuarios DROP CONSTRAINT IF EXISTS usuarios_genero_check;
ALTER TABLE usuarios ADD CONSTRAINT usuarios_genero_check 
CHECK (genero IN ('Hombre', 'Mujer', 'No Binario', 'Prefiero no decirlo'));
