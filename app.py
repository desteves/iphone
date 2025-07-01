"""
Flask application that receives JSON data and sends it to a Kafka topic
using the Confluent Kafka client.
"""

import json
from flask import Flask, request, jsonify
from confluent_kafka import Producer

app = Flask(__name__)

def read_config():
    """
    Reads the Kafka client configuration from the `client.properties` file
    and returns it as a dictionary.

    Returns:
        dict: Configuration key-value pairs
    """
    config = {}
    try:
        with open("client.properties", encoding="utf-8") as file:
            for line in file:
                line = line.strip()
                if line and not line.startswith("#"):
                    parameter, value = line.split("=", 1)
                    config[parameter.strip()] = value.strip()
    except FileNotFoundError:
        raise Exception("client.properties file not found.")
    return config

def produce_message(topic, config, value):
    """
    Produces a message to the given Kafka topic.

    Args:
        topic (str): Kafka topic name
        config (dict): Kafka producer configuration
        value (str): Message value to send
    """
    try:
        producer = Producer(config)
        producer.produce(topic, value=value)
        print(f"Produced message to topic '{topic}': value = {value}")
        producer.flush()  # Ensure all messages are sent
    except Exception as err:
        print(f"Failed to produce message: {err}")
        raise

@app.route('/data', methods=['POST'])
def handle_data():
    """
    Flask endpoint that receives JSON data and sends it to a Kafka topic.

    Returns:
        Response: JSON response indicating success or failure
    """
    try:
        # Parse JSON data from the request
        data = request.get_json()

        if not data:
            return jsonify({"error": "Request does not contain valid JSON"}), 400

        # Serialize JSON payload to a string for Kafka message
        value = json.dumps(data)

        # Kafka topic configuration
        topic = "topic_iphone"  # Replace with your desired topic name
        config = read_config()

        # Produce the payload to Kafka
        produce_message(topic, config, value)

        # Return success response to the client
        return jsonify({"message": "Data sent to Kafka successfully", "topic": topic, "value": data}), 200

    except Exception as err:
        print(f"Error processing request: {err}")
        return jsonify({"error": str(err)}), 500

def main():
    """
    Entry point for running the Flask app.
    """
    print("Starting Flask app...")
    app.run(debug=True, host="0.0.0.0", port=3333)

if __name__ == "__main__":
    main()
