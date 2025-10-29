#!/usr/bin/env bash

# Question 1
# ----------

# instalar uv usando el script oficial `install.sh`
if ! command -v uv &> /dev/null; then
    echo "uv no está disponible. Instalándolo..."
    if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
        echo "no se pudo instalar uv" >&2
        return 1
    fi

    echo "uv instalado correctamente"
    echo "reiniciar el intérprete de comandos para poder ocuparlo"
    exit 0
fi

# actualizar uv
uv self update

# imprimir la versión de uv instalada
uv --version

# inicializar un proyecto
_proyecto='machine-learning-zoomcamp-hw05'
_descripcion='DataTalksClub · Machine Learning Zoomcamp 2025 · Homework 5'
uv init --app --python 3.13 --description "${_descripcion}" "${_proyecto}"
cd "${_proyecto}" || {
    echo "no fue posible inicializar ${_proyecto}" >&2
    return 1
}

# Question 2
# ----------

# instalar sklearn versión 1.6.1
uv add scikit-learn==1.6.1
# aprovechamos también de instalar el resto de las dependencias
uv add fastapi uvicorn
uv add --dev requests

# forzar la creación inmediata de `.venv` y `uv.lock`
uv sync

# obtener el hash requerido en la tarea apoyándonos en el script auxiliar `extract_hash.py`
uv run python extract_hash.py uv.lock scikit-learn

# Question 3
# ----------

# obtener la probabilidad de churn
uv run Q3.py

# Question 4
# ----------

# levantar el servidor web (`--log-level debug` para imprimir los mensajes `logger.debug`)
uv run uvicorn Q4-server:app --host 127.0.0.1 --port 9696 --reload --log-level debug
# realizar la consulta
uv run Q4-request.py
# detener el servidor web
# ~nota: terminará todos los procesos iniciados con `uv run uvicorn`
kill -SIGTERM $(pgrep -f "uv run uvicorn")

# Question 5
# ----------

# asumimos que Docker está instalado

# imagen a usar
_imagen="agrigorev/zoomcamp-model:2025"

# descargar la imagen desde Docker Hub
docker pull "${_imagen}"

# obtener el tamaño de la imagen en disco - resultado: 181 MB (Docker @ WSL2)
docker images --format "{{.Size}}" "${_imagen}"

# Question 6
# ----------
