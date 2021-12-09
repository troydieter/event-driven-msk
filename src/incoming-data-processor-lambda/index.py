from __future__ import print_function
import json
import os
from time import time
from confluent_kafka import Producer

KAFKA_BROKER = os.environ.get('KAFKA_BROKER')
KAFKA_TOPIC = os.environ.get('KAFKA_TOPIC')

kafka_producer = Producer({
    'bootstrap.servers': KAFKA_BROKER,
    'socket.timeout.ms': 100,
    'api.version.request': 'false',
    'broker.version.fallback': '0.9.0',
    'message.max.bytes': 1000000000
})


def handler(event, context):
    for record in event['Records']:
        print("test")
        payload = record["body"]
        print(str(payload))
        send_msg_async(payload)


def delivery_report(err, msg):
    if err is not None:
        print('Message delivery failed: {}'.format(err))
    else:
        print('Message delivered to {} [{}]'.format(
            msg.topic(), msg.partition()))


def send_msg_async(msg):
    print("Sending message")
    try:
        msg_json_str = str({"data": json.dumps(msg)})
        kafka_producer.produce(
            KAFKA_TOPIC,
            msg_json_str,
            callback=lambda err, original_msg=msg_json_str: delivery_report(err, original_msg
                                                                            ),
        )
        kafka_producer.flush()
    except Exception as ex:
        print("Error : ", ex)
