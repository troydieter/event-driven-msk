import json
import time
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
        payload = record["body"]
        start_time = int(time() * 1000)

        send_msg_async(str(payload))

        end_time = int(time() * 1000)
        time_taken = (end_time - start_time) / 1000
        print("Time taken to complete = %s seconds" % time_taken)


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
