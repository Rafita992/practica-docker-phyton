# ──────────────────────────────────────────────
# Stage 1 — base: instala dependencias de producción
# ──────────────────────────────────────────────
FROM python:3.12-slim AS base
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# ──────────────────────────────────────────────
# Stage 2 — test: ejecuta los tests con pytest
# Si fallan, el build se detiene aquí.
# ──────────────────────────────────────────────
FROM base AS test
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt
RUN pytest -v

# ──────────────────────────────────────────────
# Stage 3 — dev: servidor de desarrollo con auto-reload
# Uso: docker build --target dev -t notas-api:dev .
#       docker run -p 5000:5000 notas-api:dev
# ──────────────────────────────────────────────
FROM base AS dev
EXPOSE 5000
CMD ["flask", "--app", "run", "run", "--debug", "--host", "0.0.0.0"]

# ──────────────────────────────────────────────
# Stage 4 — production: servidor Gunicorn
# No contiene pytest ni dependencias de desarrollo.
# ──────────────────────────────────────────────
FROM base AS production
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "run:app"]
