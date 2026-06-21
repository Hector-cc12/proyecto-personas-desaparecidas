USE DB_PersonasDesaparecidas;
GO

-- ============================================================================
-- 1. CREACIÓN DE ROLES DE SEGURIDAD
-- ============================================================================

-- Rol para el equipo de Científicos de Datos (Acceso estricto de solo lectura)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'DataScientistRole')
BEGIN
    CREATE ROLE DataScientistRole;
END
GO

-- Rol para Auditores de TI / Administradores de Datos (Lectura y revisión de logs)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'DataAuditorRole')
BEGIN
    CREATE ROLE DataAuditorRole;
END
GO

-- ============================================================================
-- 2. ASIGNACIÓN DE PERMISOS (GRANT)
-- ============================================================================

-- El Data Scientist solo necesita hacer SELECT para alimentar Jupyter/Python
GRANT SELECT ON Fact_Casos TO DataScientistRole;
GRANT SELECT ON Dim_Persona TO DataScientistRole;
GRANT SELECT ON Dim_Geografia TO DataScientistRole;
GRANT SELECT ON Dim_Motivo TO DataScientistRole;

-- El Auditor puede ver los datos y además las futuras tablas de auditoría (logs)
GRANT SELECT, VIEW DEFINITION TO DataAuditorRole;
GO

PRINT '¡Roles de seguridad configurados con éxito!';
GO