# app.py
from flask import Flask, jsonify, abort, request, make_response
import json

app = Flask(__name__)

@app.route("/api/qr-pay/prepare")
def prepare():
    data = {
        "type": "CallTransactionCommand",
        "TransactionName": "MoneyTransferToOtherAccountFlow",
        "ClientIPAddress": "XXX",
        "Culture": "tr-TR",
        "data": {
            "RequestTypeName": "MoneyTransferFlowRequest",
            "ApplicationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRJcCI6IjEwLjMwLjYuMTQxIiwiVG9rZW5EYXRlVGltZSI6IjI3LjAyLjIwMjAgMTQ6MTk6NDUiLCJUb2tlblNjb3BlIjoiSGFja2F0aG9uIiwiQXBwbGljYXRpb25OYW1lIjoiSGFja2F0aG9uIiwibmJmIjoxNTgyODAyMzg1LCJleHAiOjE4OTgxNjIzODUsImlhdCI6MTU4MjgwMjM4NX0.Fhk0fyGyEDROfl63PhwjYAmb5r37ti8qOziHI4_anWk",
            "Message": {
                "$type": "VeriBranch.Common.MessageDefinitions.MoneyTransferFlowRequest, VeriBranch.Common.MessageDefinitions, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null",
                "SourceAccount": {
                    "BranchCode": "9043",
                    "Number": "682786",
                    "Suffix": "352",
                    "Branch": {
                        "Name": "Kozyatagı Şube",
                        "Code": "9043"
                    },
                    "Currency": {
                        "Code": "TRY",
                        "Name": "TL"
                    },
                    "IBAN": "TR450012400000068278600001"
                },
                "TransferAmount": {
                    "Value":15.25,
                    "Currency": {
                        "Code": "TRY",
                        "Name": "TL"
                    }
                },
                "EFTPaymentType": 4,
                "Description": "Hesaba Havale İşlemi",
                "RecipientAccountInfo": {
                    "Branch": {
                        "Code": "9043"
                    },
                    "Number": 683922,
                    "Suffix": 351
                }
            }
        }
    }
    
    data["ClientIPAddress"] = request.args.get("ip")
    data["data"]["Message"]["TransferAmount"]["Value"] = request.args.get("price")
    
    return make_response(jsonify(data), 200)
    
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
