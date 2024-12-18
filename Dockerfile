# Use Python base image
FROM python:3.9

# Install system dependencies
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

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

# Expose the required port
EXPOSE 8080

# Start Rasa server and Flask app using supervisord
RUN apt-get update && apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
