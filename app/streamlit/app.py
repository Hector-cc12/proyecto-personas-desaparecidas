"""
Fase 4 — Aplicación Streamlit para inferencia en tiempo real
de probabilidad de localización y tiempo estimado de resolución.
"""

import os
from datetime import datetime

import joblib
import pandas as pd
import streamlit as st
from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

st.set_page_config(
    page_title="Predicción de Casos - Personas Desaparecidas",
    page_icon="🔎",
    layout="centered",
)

# ---------------------------------------------------------------------
# Paso 4.2: Carga de modelos en memoria + conexión a MongoDB
# ---------------------------------------------------------------------
RUTA_MODELOS = os.path.join(os.path.dirname(__file__), "..", "..", "models")


@st.cache_resource
def cargar_modelos():
    modelo_clasificacion = joblib.load(
        os.path.join(RUTA_MODELOS, "modelo_clasificacion.pkl")
    )
    modelo_regresion = joblib.load(
        os.path.join(RUTA_MODELOS, "modelo_regresion.pkl")
    )
    return modelo_clasificacion, modelo_regresion


@st.cache_resource
def conectar_mongo():
    mongo_uri = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    cliente = MongoClient(mongo_uri)
    return cliente["DB_PersonasDesaparecidas_ML"]


modelo_clasificacion, modelo_regresion = cargar_modelos()
db_mongo = conectar_mongo()
coleccion_logs = db_mongo["logs_consultas"]

# ---------------------------------------------------------------------
# Paso 4.1: Formulario interactivo
# ---------------------------------------------------------------------
st.title("🔎 Predicción de Casos de Personas Desaparecidas")
st.write(
    "Completa los datos del caso para estimar la probabilidad de "
    "localización y el tiempo aproximado de resolución."
)

with st.form("formulario_caso"):
    col1, col2 = st.columns(2)

    with col1:
        edad = st.number_input("Edad", min_value=0, max_value=120, value=30)
        sexo = st.selectbox("Sexo", ["MASCULINO", "FEMENINO"])

    with col2:
        provincia = st.text_input("Provincia", value="GUAYAS")
        # Agregar más campos según las columnas reales del modelo

    enviado = st.form_submit_button("Predecir")

# ---------------------------------------------------------------------
# Paso 4.3: Inferencia en tiempo real
# ---------------------------------------------------------------------
if enviado:
    datos_entrada = pd.DataFrame(
        [{"edad": edad, "sexo": sexo, "provincia": provincia}]
    )

    try:
        prediccion_estado = modelo_clasificacion.predict(datos_entrada)[0]
        probabilidades = modelo_clasificacion.predict_proba(datos_entrada)[0]
        prob_localizado = max(probabilidades)

        dias_estimados = modelo_regresion.predict(datos_entrada)[0]

        st.success("Predicción generada correctamente")
        col_a, col_b = st.columns(2)
        col_a.metric("Probabilidad de localización", f"{prob_localizado * 100:.1f}%")
        col_b.metric("Tiempo estimado de resolución", f"{dias_estimados:.0f} días")

        st.caption(f"Estado predicho: {prediccion_estado}")

        # Registrar bitácora de uso en MongoDB
        coleccion_logs.insert_one(
            {
                "timestamp": datetime.now().isoformat(),
                "entrada": datos_entrada.to_dict(orient="records")[0],
                "resultado": {
                    "estado_predicho": str(prediccion_estado),
                    "probabilidad_localizacion": float(prob_localizado),
                    "dias_estimados": float(dias_estimados),
                },
            }
        )

    except Exception as e:
        st.error(f"Ocurrió un error al generar la predicción: {e}")
