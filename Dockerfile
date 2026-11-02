# =====================================
# Stage 1: Builder
# =====================================
FROM python:3.9 AS builder

WORKDIR /app/backend

# Create virtual environment
RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# Install build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       default-libmysqlclient-dev \
       pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt


# =====================================
# Stage 2: Runtime
# =====================================
FROM python:3.9-slim

WORKDIR /app/backend

# Install MySQL runtime library and curl
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       libmariadb3 \
       curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python virtual environment
COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# Copy application
COPY . .

EXPOSE 8000

CMD ["gunicorn", "notesapp.wsgi:application", "--bind", "0.0.0.0:8000"]
