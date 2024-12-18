# Use Python base image
FROM python:3.9

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Initialize a new Rasa project (remove this if you have an existing project)
RUN rasa init --no-prompt
RUN rasa train

# Copy Flask app and templates to the container
COPY app.py .
COPY templates ./templates/

# Copy Supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose the single port (Render uses this for port binding)
EXPOSE 8080

# Start Supervisor to manage Rasa and Flask processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
