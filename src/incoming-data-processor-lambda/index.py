from __future__ import print_function

import boto3
import json
import os
import sys
import uuid

bucket_name = os.environ['BUCKET_NAME']
rando_id = os.environ['RANDO_ID']


def handler(event, context):
    s3_client = boto3.client('s3')
    dt = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")

    for record in event['Records']:
        s3 = boto3.resource('s3')
        s3_bucket_name = os.environ['BUCKET_NAME']
        file_name = f"event_{rando_id}_{dt}.csv"
        folder_path = f"{dt}" + file_name
        s3.Bucket(s3_bucket_name).put_object(Bucket=s3_bucket_name, Key=folder_path, Body=record["body"])
        print("test")
        payload = record["body"]
        print(str(payload))
