FROM python:3.11-slim AS builder 

# Prevents Python from writing .pyc files and buffering stdout —
# both just add noise/latency in a container, no benefit here
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app 

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt 

COPY . .

RUN useradd --create-home appuser 

USER appuser

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
# Uvicorn is a lightning-fast ASGI (Asynchronous Server Gateway Interface) web server implementation for Python