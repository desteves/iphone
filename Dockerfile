# Use a slim Python base image
FROM python:3.12-slim

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install system dependencies (minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency specification and install
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py ./

# Environment defaults (can be overridden at runtime)
ENV MONGO_URI=mongodb://host.docker.internal:27017 \
    MONGO_DB=iot \
    MONGO_COLLECTION=raw_iphone \
    PORT=3333

# Expose app port
EXPOSE 3333

# Run the service
CMD ["python", "app.py"]
