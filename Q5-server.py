import pickle

from fastapi import FastAPI
from contextlib import asynccontextmanager

import logging

logger = logging.getLogger("uvicorn.error")
logger.setLevel(logging.DEBUG)

ml_model = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.debug("Iniciando el servicio")
    model_file_path = "pipeline_v2.bin"

    try:
        with open(model_file_path, "rb") as f_in:
            ml_model["pipeline"] = pickle.load(f_in)
    except FileNotFoundError:
        print(f"El archivo '{model_file_path}' no existe")

    yield

    ml_model.clear()
    logger.debug("Desconectando el servicio")


app = FastAPI(title="customer-churn-prediction", lifespan=lifespan)


def predict_single(customer):
    result = ml_model["pipeline"].predict_proba(customer)[0, 1]
    return float(result)


@app.post("/predict")
def predict(
    customer: dict,
):  # si no declaramos el tipo de `customer`, el servidor responderá con 422 y no ejecutará esta función
    prob = predict_single(customer)

    return {"churn_probability": prob, "churn": bool(prob >= 0.5)}
