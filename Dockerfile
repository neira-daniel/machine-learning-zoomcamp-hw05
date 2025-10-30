# Basado en https://github.com/astral-sh/uv-docker-example/blob/main/standalone.Dockerfile

# First, build the application in the `/code` directory
FROM ghcr.io/astral-sh/uv:bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Configure the Python directory so it is consistent
ENV UV_PYTHON_INSTALL_DIR=/python

# Only use the managed Python version
ENV UV_PYTHON_PREFERENCE=only-managed

# Install Python before the project for caching
RUN uv python install 3.13

WORKDIR /code
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev

# alternativa a la instrucción siguiente: `COPY . /code`, pero en ese caso debemos usar un archivo
# `.dockerignore` para no copiar todo el contenido del directorio activo local al contenedor
# más información: https://docs.docker.com/build/concepts/context/#dockerignore-files
COPY Q5-server.py pyproject.toml uv.lock /code
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev

# Then, use a final image without uv
FROM agrigorev/zoomcamp-model:2025

# Setup a non-root user
RUN groupadd --system --gid 999 nonroot \
 && useradd --system --gid 999 --uid 999 --create-home nonroot

# Copy the Python version
COPY --from=builder --chown=python:python /python /python

# Copy the application from the builder
COPY --from=builder --chown=nonroot:nonroot /code /code

# Place executables in the environment at the front of the path
ENV PATH="/code/.venv/bin:$PATH"

# Use the non-root user to run our application
USER nonroot

# Use `/code` as the working directory
WORKDIR /code

# Run the FastAPI application by default
CMD ["uvicorn", "Q5-server:app", "--host", "0.0.0.0", "--port", "9696"]
