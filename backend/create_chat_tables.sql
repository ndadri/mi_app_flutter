-- Crear tabla de chats/conversaciones
CREATE TABLE IF NOT EXISTS chats (
    id SERIAL PRIMARY KEY,
    usuario1_id INTEGER NOT NULL,
    usuario2_id INTEGER NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario1_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario2_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE(usuario1_id, usuario2_id)
);

-- Crear tabla de mensajes
CREATE TABLE IF NOT EXISTS mensajes (
    id SERIAL PRIMARY KEY,
    chat_id INTEGER NOT NULL,
    de_usuario_id INTEGER NOT NULL,
    para_usuario_id INTEGER NOT NULL,
    mensaje TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leido BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
    FOREIGN KEY (de_usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (para_usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_chats_usuarios ON chats(usuario1_id, usuario2_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_chat ON mensajes(chat_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_fecha ON mensajes(fecha);
CREATE INDEX IF NOT EXISTS idx_mensajes_usuarios ON mensajes(de_usuario_id, para_usuario_id);

-- Función para obtener o crear un chat entre dos usuarios
CREATE OR REPLACE FUNCTION obtener_o_crear_chat(user1_id INTEGER, user2_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    chat_id INTEGER;
    menor_id INTEGER;
    mayor_id INTEGER;
BEGIN
    -- Asegurar que usuario1_id sea el menor para evitar duplicados
    IF user1_id < user2_id THEN
        menor_id := user1_id;
        mayor_id := user2_id;
    ELSE
        menor_id := user2_id;
        mayor_id := user1_id;
    END IF;
    
    -- Buscar chat existente
    SELECT id INTO chat_id 
    FROM chats 
    WHERE usuario1_id = menor_id AND usuario2_id = mayor_id;
    
    -- Si no existe, crear nuevo chat
    IF chat_id IS NULL THEN
        INSERT INTO chats (usuario1_id, usuario2_id) 
        VALUES (menor_id, mayor_id) 
        RETURNING id INTO chat_id;
    END IF;
    
    RETURN chat_id;
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar la última actividad del chat
CREATE OR REPLACE FUNCTION actualizar_ultima_actividad()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chats 
    SET ultima_actividad = CURRENT_TIMESTAMP 
    WHERE id = NEW.chat_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar automáticamente la última actividad
DROP TRIGGER IF EXISTS trigger_actualizar_ultima_actividad ON mensajes;
CREATE TRIGGER trigger_actualizar_ultima_actividad
    AFTER INSERT ON mensajes
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_ultima_actividad();

-- Insertar algunos chats de prueba (opcional)
-- INSERT INTO chats (usuario1_id, usuario2_id) VALUES (2, 3) ON CONFLICT DO NOTHING;
