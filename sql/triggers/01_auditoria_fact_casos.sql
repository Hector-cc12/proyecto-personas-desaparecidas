/* =====================================================================
   FASE 2 - Paso 2.1: Implementación de la Auditoría Activa
   Trigger sobre Fact_Casos que registra UPDATE/DELETE en Auditoria_Casos
   ===================================================================== */

USE DB_PersonasDesaparecidas;
GO

IF OBJECT_ID('dbo.Auditoria_Casos', 'U') IS NOT NULL DROP TABLE dbo.Auditoria_Casos;
GO
CREATE TABLE dbo.Auditoria_Casos (
    id_auditoria    INT IDENTITY(1,1) PRIMARY KEY,
    id_caso         INT NOT NULL,
    tipo_operacion  VARCHAR(10) NOT NULL,   -- 'UPDATE' o 'DELETE'
    usuario_db      VARCHAR(128) NOT NULL DEFAULT SUSER_NAME(),
    fecha_evento    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    datos_anteriores NVARCHAR(MAX) NULL     -- snapshot en JSON del registro afectado
);
GO

IF OBJECT_ID('dbo.trg_Auditoria_Fact_Casos', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Auditoria_Fact_Casos;
GO

CREATE TRIGGER dbo.trg_Auditoria_Fact_Casos
ON dbo.Fact_Casos
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Registrar UPDATE: guarda el estado ANTERIOR (deleted) del registro
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Auditoria_Casos (id_caso, tipo_operacion, datos_anteriores)
        SELECT
            d.id_caso,
            'UPDATE',
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM deleted d;
    END

    -- Registrar DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Auditoria_Casos (id_caso, tipo_operacion, datos_anteriores)
        SELECT
            d.id_caso,
            'DELETE',
            (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        FROM deleted d;
    END
END;
GO
