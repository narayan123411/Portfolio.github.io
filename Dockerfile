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

# Copy Rasa project files
COPY . .

# Remove any existing models to ensure a fresh training
RUN rm -rf models

# Create the models directory if it doesn't exist
RUN mkdir -p models

# Train the Rasa model during the image build
RUN rasa train

RUN ls -l models/

# After training, compress the model if it exists
RUN if [ "$(ls -A models)" ]; then \
    tar -czf models/$(ls models | head -n 1).tar.gz -C models $(ls models | head -n 1); \
    else echo "No models to compress"; \
    fi

# Copy Supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose Flask and Rasa ports
EXPOSE 8080 5005

# Start Supervisor to manage Rasa and Flask
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
