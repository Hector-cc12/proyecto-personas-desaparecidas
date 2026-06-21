-- 1. CREACIÓN DE LA BASE DE DATOS
CREATE DATABASE DB_PersonasDesaparecidas;
GO

USE DB_PersonasDesaparecidas;
GO

-- Tabla Dimensional: Características demográficas
CREATE TABLE Dim_Persona (
    id_persona INT IDENTITY(1,1) NOT NULL,
    sexo VARCHAR(20) NOT NULL,
    edad INT NOT NULL,
    rango_edad VARCHAR(50) NOT NULL,
    nacionalidad VARCHAR(50) NOT NULL,
    etnia VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Dim_Persona PRIMARY KEY CLUSTERED (id_persona)
);
GO

-- Tabla Dimensional: División político-administrativa
CREATE TABLE Dim_Geografia (
    id_geografia INT IDENTITY(1,1) NOT NULL,
    codigo_provincia VARCHAR(10) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    codigo_canton VARCHAR(10) NOT NULL,
    canton VARCHAR(100) NOT NULL,
    zona VARCHAR(50) NOT NULL,
    distrito VARCHAR(100) NOT NULL,
    circuito VARCHAR(100) NOT NULL,
    subcircuito VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Dim_Geografia PRIMARY KEY CLUSTERED (id_geografia)
);
GO

-- Tabla Dimensional: Categorización de las causas
CREATE TABLE Dim_Motivo (
    id_motivo INT IDENTITY(1,1) NOT NULL,
    motivo_desaparicion VARCHAR(100) NOT NULL,              
    motivacion_desaparicion_observada VARCHAR(255) NOT NULL, 
    CONSTRAINT PK_Dim_Motivo PRIMARY KEY CLUSTERED (id_motivo)
);
GO

-- Tabla Central de Hechos (FACT_CASOS)
CREATE TABLE Fact_Casos (
    id_caso INT IDENTITY(1,1) NOT NULL,
    id_persona INT NOT NULL,
    id_geografia INT NOT NULL,
    id_motivo INT NOT NULL,
    fecha_desaparicion DATE NOT NULL,
    fecha_denuncia DATE NOT NULL,
    latitud_desaparicion DECIMAL(9,6) NOT NULL,
    longitud_desaparicion DECIMAL(9,6) NOT NULL,
    dias_solucion INT NULL,                                 
    situacion_actual VARCHAR(50) NOT NULL,                  
    estado_desaparecido VARCHAR(50) NOT NULL,               
    
    CONSTRAINT PK_Fact_Casos PRIMARY KEY CLUSTERED (id_caso),
    CONSTRAINT FK_Fact_Casos_Dim_Persona FOREIGN KEY (id_persona) REFERENCES Dim_Persona (id_persona),
    CONSTRAINT FK_Fact_Casos_Dim_Geografia FOREIGN KEY (id_geografia) REFERENCES Dim_Geografia (id_geografia),
    CONSTRAINT FK_Fact_Casos_Dim_Motivo FOREIGN KEY (id_motivo) REFERENCES Dim_Motivo (id_motivo)
);
GO