from flask import Flask, render_template, request, jsonify
import requests
import os
import logging

# Set up logging to output to stdout (Render's console)
logging.basicConfig(level=logging.DEBUG, format="%(asctime)s - %(levelname)s - %(message)s", handlers=[logging.StreamHandler()])
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/send", methods=["POST"])
def send_message():
    user_message = request.json.get("message")
    
    # Log the received message from the website
    logger.debug(f"User message received: {user_message}")

    try:
        # Send the user message to Rasa
        response = requests.post(
            "http://localhost:5005/webhooks/rest/webhook",  # Rasa REST API endpoint
            json={"sender": "user", "message": user_message}
        )
        
        if response.status_code == 200:
            # Log the response from Rasa
            logger.debug(f"Rasa response: {response.json()}")
            return jsonify(response.json())
        else:
            logger.error(f"Rasa returned an error: {response.status_code}")
            return jsonify({"error": "Rasa server returned an error"}), 500
            
    except requests.exceptions.RequestException as e:
        # Log the error for better debugging
        logger.error(f"Error during request to Rasa: {e}")
        return jsonify({"error": "Failed to connect to Rasa server"}), 500

if __name__ == "__main__":
    # Use Render's environment variable for the port or default to 8080
    port = 8080
    logger.info(f"Starting Flask app on port {port}")
    app.run(host="0.0.0.0", port=port)  # Flask app will run on the specified port
