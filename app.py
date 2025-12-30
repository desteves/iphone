"""Flask service that stores inbound JSON directly in MongoDB."""

import os
from flask import Flask, request
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

def get_mongo_client(uri):
    """
    Return a singleton MongoDB client for the given URI.

    Args:
        uri (str): MongoDB connection string.

    Returns:
        MongoClient: Shared client instance.
    """
    if "MONGO_CLIENT" not in app.config:
        app.config["MONGO_CLIENT"] = MongoClient(uri)
    return app.config["MONGO_CLIENT"]

def main():
    """
    Entry point for running the Flask app.
    """
    app.run(host="0.0.0.0", port=3333)

@app.route("/mdb", methods=["POST"])
def handle_mdb():
    """
    Persist a JSON payload directly to MongoDB.

    Mongo connection details can be overridden with environment variables:
    - MONGODB_URI
    - MONGODB_DATABASE
    - MONGODB_COLLECTION
    """
    data = request.get_json()
    mongo_uri = os.getenv("MONGODB_URI")
    database = os.getenv("MONGODB_DATABASE", "iot")
    collection_name = os.getenv("MONGODB_COLLECTION", "iphone")
    client = get_mongo_client(mongo_uri)
    collection_ref = client[database][collection_name]
    collection_ref.insert_one(data)
    return ""

if __name__ == "__main__":
    main()
