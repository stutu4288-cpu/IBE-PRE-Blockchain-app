# Production Dockerfile for Railway Python PRE Application
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy python application dependencies
COPY python_pre_app/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy python application source code & catalina.sh wrapper
COPY python_pre_app /app
COPY schema.sql /app/schema.sql
COPY catalina.sh /app/catalina.sh
COPY catalina.sh /usr/local/bin/catalina.sh
RUN chmod +x /app/catalina.sh /usr/local/bin/catalina.sh

EXPOSE 8000

ENV PORT=8000
ENV PYTHONUNBUFFERED=1

CMD ["python", "-u", "app.py"]
