/* =====================================================================
   FASE 1 - Paso 1.1: Inicialización del Servidor SQL
   Base de datos: DB_PersonasDesaparecidas
   Modelo: esquema en estrella (Dim_Persona, Dim_Geografia, Dim_Motivo, Fact_Casos)
   ===================================================================== */

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'DB_PersonasDesaparecidas')
BEGIN
    CREATE DATABASE DB_PersonasDesaparecidas;
END
GO

USE DB_PersonasDesaparecidas;
GO

/* ---------------------------------------------------------------------
   DIMENSIÓN: Persona
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.Dim_Persona', 'U') IS NOT NULL DROP TABLE dbo.Dim_Persona;
GO
CREATE TABLE dbo.Dim_Persona (
    id_persona      INT IDENTITY(1,1) PRIMARY KEY,
    edad            INT NULL,
    sexo            VARCHAR(20) NULL,
    nacionalidad    VARCHAR(80) NULL
);
GO

/* ---------------------------------------------------------------------
   DIMENSIÓN: Geografía
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.Dim_Geografia', 'U') IS NOT NULL DROP TABLE dbo.Dim_Geografia;
GO
CREATE TABLE dbo.Dim_Geografia (
    id_geografia    INT IDENTITY(1,1) PRIMARY KEY,
    provincia       VARCHAR(80) NOT NULL,
    canton          VARCHAR(80) NOT NULL,
    CONSTRAINT UQ_Geografia UNIQUE (provincia, canton)
);
GO

/* ---------------------------------------------------------------------
   DIMENSIÓN: Motivo
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.Dim_Motivo', 'U') IS NOT NULL DROP TABLE dbo.Dim_Motivo;
GO
CREATE TABLE dbo.Dim_Motivo (
    id_motivo       INT IDENTITY(1,1) PRIMARY KEY,
    descripcion     VARCHAR(150) NOT NULL UNIQUE
);
GO

/* ---------------------------------------------------------------------
   TABLA DE HECHOS: Casos
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.Fact_Casos', 'U') IS NOT NULL DROP TABLE dbo.Fact_Casos;
GO
CREATE TABLE dbo.Fact_Casos (
    id_caso             INT IDENTITY(1,1) PRIMARY KEY,
    id_persona          INT NOT NULL,
    id_geografia        INT NOT NULL,
    id_motivo           INT NULL,
    fecha_desaparicion  DATE NOT NULL,
    fecha_localizacion  DATE NULL,
    dias_solucion       INT NULL,           -- Paso 1.3: feature engineering
    estado_desaparecido VARCHAR(30) NOT NULL, -- ej: 'Localizado', 'No localizado'
    fecha_carga         DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Casos_Persona   FOREIGN KEY (id_persona)   REFERENCES dbo.Dim_Persona(id_persona),
    CONSTRAINT FK_Casos_Geografia FOREIGN KEY (id_geografia) REFERENCES dbo.Dim_Geografia(id_geografia),
    CONSTRAINT FK_Casos_Motivo    FOREIGN KEY (id_motivo)    REFERENCES dbo.Dim_Motivo(id_motivo)
);
GO

/* ---------------------------------------------------------------------
   Índices de apoyo para consultas analíticas frecuentes
   --------------------------------------------------------------------- */
CREATE INDEX IX_Casos_Estado ON dbo.Fact_Casos(estado_desaparecido);
CREATE INDEX IX_Casos_Geografia ON dbo.Fact_Casos(id_geografia);
GO
