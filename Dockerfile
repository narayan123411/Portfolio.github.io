# Use Python base image
FROM python:3.9

# Install system dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Rasa and Flask
RUN pip install rasa flask requests

# Initialize Rasa project
RUN rasa init --no-prompt

# Copy Flask app and templates
COPY app.py . 
COPY templates/index.html templates/index.html

# Expose Flask and Rasa ports
EXPOSE 5005 8080

# Start Rasa server and Flask app
CMD rasa run --enable-api --cors "*" --port 5005 & python app.py
