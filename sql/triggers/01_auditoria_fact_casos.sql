USE DB_PersonasDesaparecidas;
GO

-- ============================================================================
-- 1. CREACIÓN DE LA TABLA DE AUDITORÍA (HISTÓRICO DE CAMBIOS)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Log_Auditoria_Casos]') AND type in (N'U'))
BEGIN
    CREATE TABLE Log_Auditoria_Casos (
        id_log INT IDENTITY(1,1) NOT NULL,
        id_caso_afectado INT NOT NULL,
        accion_realizada VARCHAR(20) NOT NULL, -- 'UPDATE' o 'DELETE'
        usuario_ejecutor VARCHAR(100) NOT NULL,
        fecha_registro DATETIME DEFAULT GETDATE(),
        situacion_anterior VARCHAR(50),
        situacion_nueva VARCHAR(50),
        CONSTRAINT PK_Log_Auditoria PRIMARY KEY CLUSTERED (id_log)
    );
END
GO

-- ============================================================================
-- 2. TRIGGER DE CONTROL E INTEGRIDAD SOBRE FACT_CASOS
-- ============================================================================
CREATE OR ALTER TRIGGER TR_Auditar_Cambios_Casos
ON Fact_Casos
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable para identificar la acción
    DECLARE @accion VARCHAR(20);
    
    IF EXISTS(SELECT * FROM DELETED) AND EXISTS(SELECT * FROM INSERTED)
        SET @accion = 'UPDATE';
    ELSE
        SET @accion = 'DELETE';

    -- Si es un UPDATE, registramos el cambio de estado de la persona
    IF @accion = 'UPDATE'
    BEGIN
        INSERT INTO Log_Auditoria_Casos (id_caso_afectado, accion_realizada, usuario_ejecutor, situacion_anterior, situacion_nueva)
        SELECT 
            i.id_caso,
            'UPDATE',
            SYSTEM_USER,
            d.situacion_actual,
            i.situacion_actual
        FROM INSERTED i
        INNER JOIN DELETED d ON i.id_caso = d.id_caso;
    END

    -- Si es un DELETE, registramos la alerta de eliminación del caso crítico
    IF @accion = 'DELETE'
    BEGIN
        INSERT INTO Log_Auditoria_Casos (id_caso_afectado, accion_realizada, usuario_ejecutor, situacion_anterior, situacion_nueva)
        SELECT 
            d.id_caso,
            'DELETE',
            SYSTEM_USER,
            d.situacion_actual,
            'REGISTRO ELIMINADO'
        FROM DELETED d;
    END
END;
GO

PRINT '¡Tabla de auditoría y Trigger preventivo desplegados con éxito!';
GO