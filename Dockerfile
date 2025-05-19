# ---------- Build stage ----------
    FROM python:3.12-slim AS builder

    WORKDIR /app
    
    # Install build dependencies
    RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        && rm -rf /var/lib/apt/lists/*
    
    # Copy only necessary files for installation
    COPY pyproject.toml README.rst ./
    COPY flaskr ./flaskr
    COPY tests ./tests
    
    # Install your package in editable mode with dependencies
    RUN pip install --upgrade pip setuptools wheel && \
        pip install --prefix=/install -e .
    
    # ---------- Final stage ----------
    FROM python:3.12-slim
    
    WORKDIR /app
    
    # Copy installed packages from builder image
    COPY --from=builder /install /usr/local
    
    # Copy your application source code
    COPY flaskr ./flaskr
    COPY tests ./tests
    COPY pyproject.toml README.rst ./
    COPY entrypoint.sh /entrypoint.sh
    
    # Ensure the script is executable
    RUN chmod +x /entrypoint.sh
    
    # Expose the Flask default port
    EXPOSE 5000
    
    # Environment variables for Flask
    ENV FLASK_APP=flaskr
    ENV FLASK_RUN_HOST=0.0.0.0
    
    # Use entrypoint to handle DB init and run
    ENTRYPOINT ["/entrypoint.sh"]
    