from __future__ import print_function

import boto3
import json
import os
import sys
import uuid
from datetime import datetime

bucket_name = os.environ['BUCKET_NAME']
rando_id = os.environ['RANDO_ID']


def handler(event, context):
    s3_client = boto3.client('s3')
    dt = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")

    for record in event['Records']:
        s3 = boto3.resource('s3')
        s3_bucket_name = bucket_name
        file_name = f"event_{rando_id}_{dt}.json"
        folder_path = f"{dt}"
        s3.Bucket(s3_bucket_name).put_object(Bucket=s3_bucket_name, Key=f"{folder_path}/{file_name}",
                                             ContentType="application/json", Body=record["body"])
        payload = record["body"]
        print(str(payload))
