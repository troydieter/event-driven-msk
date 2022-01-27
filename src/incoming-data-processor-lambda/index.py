from __future__ import print_function
import json

def handler(event, context):
    for record in event['Records']:
        print("test")
        payload = record["body"]
        print(str(payload))

