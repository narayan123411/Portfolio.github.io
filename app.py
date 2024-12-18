from flask import Flask, render_template, request, jsonify
import requests
import os

app = Flask(__name__)

# Dynamically get Rasa server URL from environment variable
RASA_SERVER = os.getenv("RASA_SERVER_URL", "http://localhost:5005/webhooks/rest/webhook")

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/send", methods=["POST"])
def send_message():
    user_message = request.json.get("message")
    try:
        response = requests.post(
            RASA_SERVER,
            json={"sender": "user", "message": user_message},
            timeout=5
        )
        response.raise_for_status()
        return jsonify(response.json())
    except requests.RequestException as e:
        app.logger.error(f"Error occurred while communicating with Rasa: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
