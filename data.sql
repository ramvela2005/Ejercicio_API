-- Crear el tipo ENUM para el status del incidente
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'incident_status') THEN
      CREATE TYPE incident_status AS ENUM ('Pendiente', 'En proceso', 'Resuelto');
   END IF;
END$$;

-- Tabla category
CREATE TABLE IF NOT EXISTS category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla incident
CREATE TABLE IF NOT EXISTS incident (
    id SERIAL PRIMARY KEY,
    reporter VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    status incident_status NOT NULL DEFAULT 'Pendiente',
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- Tabla intermedia para relación muchos a muchos incident_categories
CREATE TABLE IF NOT EXISTS incident_categories (
    incident_id INTEGER NOT NULL REFERENCES incident(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES category(id) ON DELETE CASCADE,
    PRIMARY KEY (incident_id, category_id)
);

-- Tabla vista materializada
CREATE TABLE IF NOT EXISTS incident_with_categories (
    incident_id INTEGER PRIMARY KEY,
    reporter VARCHAR,
    description TEXT,
    status VARCHAR,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    category_names VARCHAR
);

-- Insertar categorías (por si no están)
INSERT INTO category (name) VALUES
('Infraestructura'),
('Seguridad'),
('Tecnología'),
('Salud')
ON CONFLICT (name) DO NOTHING;

-- Insertar incidentes
INSERT INTO incident (reporter, description, status, created_at) VALUES
('Ana Pérez', 'Fuga de agua en el edificio principal, necesita atención inmediata', 'Pendiente', NOW() - INTERVAL '10 days'),
('Juan López', 'Problemas de acceso a la red inalámbrica en el segundo piso', 'En proceso', NOW() - INTERVAL '8 days'),
('María García', 'Cortocircuito en una de las luminarias del pasillo A', 'Resuelto', NOW() - INTERVAL '7 days'),
('Carlos Ruiz', 'Sistema de control de acceso no reconoce tarjetas nuevas', 'Pendiente', NOW() - INTERVAL '5 days'),
('Lucía Fernández', 'Falta de insumos médicos en la sala de emergencias', 'En proceso', NOW() - INTERVAL '4 days'),
('Diego Martínez', 'Actualización necesaria en software antivirus del servidor', 'Pendiente', NOW() - INTERVAL '3 days'),
('Sofía Ramírez', 'Puerta de emergencia bloqueada en la planta baja', 'Resuelto', NOW() - INTERVAL '12 days'),
('Miguel Torres', 'Caída del sistema de vigilancia durante la noche', 'Pendiente', NOW() - INTERVAL '2 days'),
('Laura Díaz', 'Problemas con la conexión del sistema telefónico', 'En proceso', NOW() - INTERVAL '1 day'),
('Javier Gómez', 'Equipo de respiración asistida con fallas', 'Pendiente', NOW() - INTERVAL '6 days'),
('Natalia Sánchez', 'Fallo en el sistema de alarma contra incendios', 'Resuelto', NOW() - INTERVAL '9 days'),
('Roberto Vargas', 'Lento desempeño de la plataforma web interna', 'En proceso', NOW() - INTERVAL '11 days'),
('Patricia Morales', 'Suministro eléctrico irregular en el laboratorio', 'Pendiente', NOW() - INTERVAL '7 days'),
('Esteban Castro', 'Falta de señalización adecuada en rutas de evacuación', 'Resuelto', NOW() - INTERVAL '15 days'),
('Verónica Ruiz', 'Incidencia con la base de datos del sistema de citas', 'Pendiente', NOW() - INTERVAL '8 days'),
('Jorge Herrera', 'Problema con la calefacción en oficinas administrativas', 'En proceso', NOW() - INTERVAL '5 days'),
('Claudia Soto', 'Desperfecto en el ascensor del bloque B', 'Resuelto', NOW() - INTERVAL '3 days'),
('Andrés Molina', 'Actualización requerida en sistema operativo de PCs', 'Pendiente', NOW() - INTERVAL '2 days'),
('Gabriela Ortiz', 'Falta de desinfectantes en áreas comunes', 'Pendiente', NOW() - INTERVAL '1 day'),
('Ricardo Peña', 'Errores frecuentes en la gestión de turnos', 'En proceso', NOW() - INTERVAL '6 days'),
('Monica Castro', 'Cámaras de seguridad con imágenes borrosas', 'Resuelto', NOW() - INTERVAL '7 days'),
('Felipe Morales', 'Incidente de malware detectado en equipo administrativo', 'Pendiente', NOW() - INTERVAL '4 days'),
('Isabel Navarro', 'Problemas con la ventilación en sala de reuniones', 'Pendiente', NOW() - INTERVAL '9 days'),
('Sergio Díaz', 'Solicitud de mejora en la señal de Wi-Fi en área común', 'En proceso', NOW() - INTERVAL '3 days'),
('Carolina Vega', 'Desperfecto en el sistema de iluminación exterior', 'Resuelto', NOW() - INTERVAL '2 days'),
('Luis Ramírez', 'Problemas con las cerraduras electrónicas de oficinas', 'Pendiente', NOW() - INTERVAL '5 days'),
('Elena Torres', 'Retraso en actualizaciones del sistema de nóminas', 'En proceso', NOW() - INTERVAL '7 days'),
('Pablo Mendoza', 'Falta de mantenimiento en equipos de laboratorio', 'Pendiente', NOW() - INTERVAL '10 days'),
('Andrea Flores', 'Error en el sistema de gestión de inventarios', 'Resuelto', NOW() - INTERVAL '8 days'),
('Marcelo Ruiz', 'Problemas de sincronización en servidores', 'Pendiente', NOW() - INTERVAL '1 day');

-- Insertar relaciones incident_categories
-- Ejemplos de incidentes con múltiples categorías para demostrar relación muchos a muchos

-- Incidente 1: Infraestructura + Salud
INSERT INTO incident_categories (incident_id, category_id) VALUES (1, 1), (1, 4);

-- Incidente 2: Tecnología + Seguridad
INSERT INTO incident_categories (incident_id, category_id) VALUES (2, 3), (2, 2);

-- Incidente 3: Infraestructura
INSERT INTO incident_categories (incident_id, category_id) VALUES (3, 1);

-- Incidente 4: Seguridad
INSERT INTO incident_categories (incident_id, category_id) VALUES (4, 2);

-- Incidente 5: Salud
INSERT INTO incident_categories (incident_id, category_id) VALUES (5, 4);

-- Incidente 6: Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (6, 3);

-- Incidente 7: Infraestructura + Seguridad
INSERT INTO incident_categories (incident_id, category_id) VALUES (7, 1), (7, 2);

-- Incidente 8: Seguridad + Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (8, 2), (8, 3);

-- Incidente 9: Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (9, 3);

-- Incidente 10: Salud
INSERT INTO incident_categories (incident_id, category_id) VALUES (10, 4);

-- Incidente 11: Seguridad
INSERT INTO incident_categories (incident_id, category_id) VALUES (11, 2);

-- Incidente 12: Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (12, 3);

-- Incidente 13: Infraestructura
INSERT INTO incident_categories (incident_id, category_id) VALUES (13, 1);

-- Incidente 14: Infraestructura + Seguridad + Salud
INSERT INTO incident_categories (incident_id, category_id) VALUES (14, 1), (14, 2), (14, 4);

-- Incidente 15: Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (15, 3);

-- Incidente 16: Infraestructura
INSERT INTO incident_categories (incident_id, category_id) VALUES (16, 1);

-- Incidente 17: Infraestructura + Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (17, 1), (17, 3);

-- Incidente 18: Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (18, 3);

-- Incidente 19: Salud
INSERT INTO incident_categories (incident_id, category_id) VALUES (19, 4);

-- Incidente 20: Tecnología + Seguridad
INSERT INTO incident_categories (incident_id, category_id) VALUES (20, 3), (20, 2);

-- Incidente 21: Seguridad
INSERT INTO incident_categories (incident_id, category_id) VALUES (21, 2);

-- Incidente 22: Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (22, 3);

-- Incidente 23: Infraestructura
INSERT INTO incident_categories (incident_id, category_id) VALUES (23, 1);

-- Incidente 24: Tecnología + Seguridad
INSERT INTO incident_categories (incident_id, category_id) VALUES (24, 3), (24, 2);

-- Incidente 25: Seguridad
INSERT INTO incident_categories (incident_id, category_id) VALUES (25, 2);

-- Incidente 26: Infraestructura
INSERT INTO incident_categories (incident_id, category_id) VALUES (26, 1);

-- Incidente 27: Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (27, 3);

-- Incidente 28: Infraestructura + Salud
INSERT INTO incident_categories (incident_id, category_id) VALUES (28, 1), (28, 4);

-- Incidente 29: Tecnología
INSERT INTO incident_categories (incident_id, category_id) VALUES (29, 3);

-- Incidente 30: Seguridad + Infraestructura
INSERT INTO incident_categories (incident_id, category_id) VALUES (30, 2), (30, 1);
