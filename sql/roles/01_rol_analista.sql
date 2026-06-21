/* =====================================================================
   FASE 2 - Paso 2.2: Configuración de la Seguridad por Roles
   Rol Analista: permisos exclusivos de lectura (SELECT)
   Usado por los procesos de Machine Learning y Streamlit
   ===================================================================== */

USE DB_PersonasDesaparecidas;
GO

-- 1) Crear el rol de base de datos
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Analista')
BEGIN
    CREATE ROLE Analista;
END
GO

-- 2) Otorgar permisos de SOLO LECTURA sobre el esquema dbo
GRANT SELECT ON SCHEMA::dbo TO Analista;
GO

-- 3) Asegurarse explícitamente de que el rol NO puede escribir/borrar/modificar estructura
DENY INSERT, UPDATE, DELETE, ALTER, CONTROL ON SCHEMA::dbo TO Analista;
GO

/* ---------------------------------------------------------------------
   4) Crear login + usuario para el servicio (ML / Streamlit)
   Reemplazar 'CAMBIAR_PASSWORD_SEGURA' por una contraseña real
   gestionada vía variable de entorno / secreto, nunca en texto plano.
   --------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'svc_analista')
BEGIN
    CREATE LOGIN svc_analista WITH PASSWORD = 'CAMBIAR_PASSWORD_SEGURA';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'svc_analista')
BEGIN
    CREATE USER svc_analista FOR LOGIN svc_analista;
END
GO

ALTER ROLE Analista ADD MEMBER svc_analista;
GO
