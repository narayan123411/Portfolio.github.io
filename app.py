from flask import Flask, render_template, request, jsonify
import requests

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/send", methods=["POST"])
def send_message():
    user_message = request.json.get("message")
    # Log the received message from the website
    print(f"User message received: {user_message}")

    try:
        # Send the user message to Rasa
        response = requests.post(
            "http://localhost:5005/webhooks/rest/webhook",  # Rasa REST API endpoint
            json={"sender": "user", "message": user_message}
        )
        # Log the response from Rasa
        print(f"Rasa response: {response.json()}")
        return jsonify(response.json())
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": "Failed to connect to Rasa server"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # Flask app will run on port 8080
