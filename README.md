# Análisis Predictivo de Personas Desaparecidas (2017–2025)

Proyecto de ingeniería de datos, machine learning y visualización para el análisis de casos de personas desaparecidas en Ecuador, basado en el dataset `personasdesaparecidas.csv`.

El proyecto cubre el ciclo de vida completo del dato: desde el ETL inicial hasta una aplicación web de inferencia en tiempo real.

## 🛠️ Estructura del Proyecto: 4 Fases

### 📁 Fase 1 — Ingeniería y Preparación de Datos (ETL)
- Creación de la base de datos `DB_PersonasDesaparecidas` (modelo dimensional: `Dim_Persona`, `Dim_Geografia`, `Dim_Motivo`, `Fact_Casos`).
- Limpieza de datos en Python/Pandas (nulos, estandarización de texto).
- Feature engineering: cálculo de `dias_solucion`.
- Carga de datos a SQL Server vía `sqlalchemy`/`pyodbc`.

### 🔐 Fase 2 — Gobernanza de Datos y Seguridad Operativa (SQL Server)
- Trigger de auditoría sobre `Fact_Casos` → `Auditoria_Casos`.
- Rol `Analista` con permisos de solo lectura (`SELECT`).
- Plan de recuperación ante desastres (DRP): backups full semanales, diferenciales diarios, log cada hora.

### 🤖 Fase 3 — Modelado Analítico y Machine Learning (Python)
- Extracción segura vía rol `Analista`.
- Clustering (K-Means) con validación por Método del Codo y Coeficiente de Silueta.
- Modelos supervisados (`random_state=42`, split 80/20):
  - Clasificación: Árbol de Decisión y Random Forest → `estado_desaparecido` (métrica F1-Score).
  - Regresión: modelos homólogos → `dias_solucion` (métricas MSE y R²).
- Persistencia de modelos (`pickle`/`joblib`) y trazabilidad de métricas en MongoDB.

### 🌐 Fase 4 — Interfaz y Despliegue (Streamlit)
- Formulario interactivo para ingreso de nuevas denuncias.
- Carga de modelos en memoria + logging de uso en MongoDB.
- Inferencia en tiempo real: probabilidad de localización y tiempo estimado de resolución.

## 📂 Estructura de Carpetas

```
proyecto-personas-desaparecidas/
├── data/
│   ├── raw/              # Archivo original (.xlsx) - no versionado
│   └── processed/        # Datos limpios/listos para carga
├── sql/
│   ├── ddl/              # Creación de BD y tablas (dimensiones + hechos)
│   ├── triggers/         # Auditoría
│   ├── roles/            # Seguridad por roles
│   └── backup/           # Scripts/plan DRP
├── notebooks/
│   ├── 01_etl/           # Limpieza, feature engineering, carga a SQL
│   ├── 02_clustering/    # K-Means, Codo, Silueta
│   └── 03_supervisado/   # Clasificación y regresión
├── models/                # Modelos serializados (.pkl) - no versionados
├── app/
│   ├── streamlit/        # app.py y módulos de la interfaz
│   └── assets/           # imágenes, estilos, etc.
└── docs/                  # Diagramas, documentación adicional
```

## ⚙️ Requisitos

```bash
pip install -r requirements.txt
```

Dependencias principales: `pandas`, `sqlalchemy`, `pyodbc`, `scikit-learn`, `pymongo`, `streamlit`, `joblib`.

## 🚀 Cómo ejecutar

1. **Fase 1 (ETL)**: ejecutar los notebooks en `notebooks/01_etl/` en orden.
2. **Fase 2 (SQL)**: ejecutar los scripts de `sql/ddl/`, luego `sql/triggers/` y `sql/roles/` en tu instancia de SQL Server.
3. **Fase 3 (ML)**: ejecutar `notebooks/02_clustering/` y `notebooks/03_supervisado/`.
4. **Fase 4 (App)**:
   ```bash
   cd app/streamlit
   streamlit run app.py
   ```

## 📊 Dataset

Fuente: `mdi_personasdesaparecidas_pm_2017_2025.xlsx` (Ministerio del Interior, Ecuador). Colocar el archivo original en `data/raw/` (no se versiona por tamaño/privacidad — ver `.gitignore`).

## 📄 Licencia

Definir según corresponda (ej. MIT).
