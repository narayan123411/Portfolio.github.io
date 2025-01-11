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
RUN rm -rf models/*

# Train the Rasa model during the image build
# You can control the training size by providing specific training data
RUN rasa train --nlu --core --config config.yml --stories data/stories.yml --domain domain.yml

# Optionally, compress the trained model to reduce its size (gzip example)
RUN tar -czf models/$(ls models | head -n 1) models/$(ls models | head -n 1)

# Copy Supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose Flask and Rasa ports
EXPOSE 8080 5005

# Start Supervisor to manage Rasa and Flask
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
