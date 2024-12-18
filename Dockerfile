# Use Python base image
FROM python:3.9

# Install system dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Rasa, Flask, and other dependencies
RUN pip install rasa flask requests

# Initialize a new Rasa project (remove this if you have an existing project)
RUN rasa init --no-prompt
RUN rasa train

# Copy Flask app and templates to the container
COPY app.py .
COPY templates/index.html ./templates/index.html

# Expose Flask and Rasa ports
EXPOSE 5000 5005

# Start Rasa server and Flask app
CMD rasa run --enable-api --cors "*" & python app.py
