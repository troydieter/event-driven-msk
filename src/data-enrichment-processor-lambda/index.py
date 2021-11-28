import json
import base64

def handler(event, context):
    print(event)
    message = event['records']
    records = event['records']['Transactions-0']
    for record in records:
        payload=base64.b64decode(record["message"]["value"])
        print("Decoded payload: " + str(payload))

