# app.py
from flask import Flask, jsonify, abort, request, make_response
import json

app = Flask(__name__)

@app.route("/api/qr-pay/receive")
def receive():
    data = {}

    data["authenticated"] = request.args.get("authenticated")
    data["message"] = request.args.get("message")

    with open('data.json', 'w') as outfile:
        json.dump(data, outfile)

    return make_response(jsonify(data), 200)

@app.route("/api/qr-pay/read")
def read():
    with open("data.json") as json_file:
        return make_response(jsonify(json.load(json_file)), 200)

if __name__ == "__main__":
    app.run('0.0.0.0', '7880', debug=True)
