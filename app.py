from flask import Flask, render_template, request, jsonify
import requests

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/send", methods=["POST"])
def send_message():
    user_message = request.json.get("message")
    response = requests.post(
        "http://localhost:5005/webhooks/rest/webhook",  # Rasa REST API endpoint
        json={"sender": "user", "message": user_message}
    )
    return jsonify(response.json())

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)