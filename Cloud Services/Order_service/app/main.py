
from flask import Flask, render_template, request, jsonify
import socket
import json
import logging
from flask_cors import CORS
from pymongo import MongoClient
from bson.json_util import dumps, ObjectId
from confluent_kafka import Consumer, Producer, KafkaException, KafkaError
from confluent_kafka.admin import AdminClient, NewTopic
import threading
import logging
import jwt # PyJWT
from jwt import PyJWKClient, ExpiredSignatureError, InvalidTokenError
from werkzeug.utils import secure_filename
from flask import send_from_directory
from functools import wraps
# ------------------ CONFIGURATIONS ------------------
# Keycloak Config
KEYCLOAK_SERVER = "http://keycloak-w:8080"
REALM_NAME = "eshop"
KEYCLOAK_PUBLIC_KEY_URL = f"{KEYCLOAK_SERVER}/realms/{REALM_NAME}/protocol/openid-connect/certs"
AUDIENCE = "account" 

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)
# ---------------- TOKEN VALIDATION ----------------
def validate_token(token):
    """Validate a JWT token using Keycloak JWKS URL."""
    try:
        logger.debug("Starting token validation.")
        # Fetch the public key
        logger.debug(f"Fetching signing key from JWKS URL: {KEYCLOAK_PUBLIC_KEY_URL}")
        jwks_client = PyJWKClient(KEYCLOAK_PUBLIC_KEY_URL)
        signing_key = jwks_client.get_signing_key_from_jwt(token).key
        # Decode the token
        logger.debug("Decoding token...")
        decoded_token = jwt.decode(
            token,
            signing_key,
            algorithms=["RS256"],
	    audience=AUDIENCE,
            options={"verify_exp": True}  # Ensure expiration is verified
        )
        logger.info("Token successfully validated.")
        logger.debug(f"Decoded Token: {decoded_token}")
        return decoded_token

    except ExpiredSignatureError:
        logger.warning("Token has expired.")
        return None
    except InvalidTokenError as e:
        logger.error(f"Invalid token: {e}")
        return None
    except Exception as e:
        logger.exception(f"Token validation error: {e}")
        return None


def token_required(f):
    """Decorator to enforce token authentication on routes."""
    @wraps(f)
    def decorated(*args, **kwargs):
        logger.debug("Checking Authorization header...")
        logger.debug(f"Request headers: {request.headers}")
        auth_header = request.headers.get("Authorization")
        if not auth_header: 
            logger.warning("Authorization header is missing")
            return jsonify({"message": "Token is missing or invalid"}), 401

        if not auth_header.startswith("Bearer "):
            logger.warning("Invalid Authorization header format.")
            return jsonify({"message": "Invalid token format"}), 402

        token = auth_header.split(" ")[1]
        logger.debug(f"Received Token: {token}")

        # Validate the token
        decoded_token = validate_token(token)
        if not decoded_token:
            logger.warning("Token validation failed.")
            return jsonify({"message": "Invalid or expired token"}), 401

        logger.info("Token validation passed. Attaching user to request.")
        request.user = decoded_token  # Attach decoded token data to the request
        return f(*args, **kwargs)
    return decorated

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": ["http://35.207.127.84:5173", "http://127.0.0.1:5173"]}}, supports_credentials=True, expose_headers=["Authorization"])

KAFKA_BOOTSTRAP_SERVERS = 'kafka:19092'
TOPIC_NAME = 'order-topic'

# Kafka producer
kafka_producer = Producer({'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS})

# MongoDB connection setup
client = MongoClient("mongodb://ordersdb:27017/")  # Update the URI if necessary
db = client['myDatabase']  # Use your database name
orders_collection = db['orders']  # Use your collection name
#client.drop_database("myDatabase")

# Kafka Consumer configuration
KAFKA_CONSUMER_CONFIG = {
    'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS,
    'group.id': 'order-service-group',
    'auto.offset.reset': 'earliest'
}

CONSUMER_TOPIC_NAME = 'order-response-topic'
consumer = Consumer(KAFKA_CONSUMER_CONFIG)
consumer.subscribe([CONSUMER_TOPIC_NAME])
logging.info(f"Consumer subscribed to topic: {CONSUMER_TOPIC_NAME}")

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def delivery_report(err, msg):
    if err:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}]")


def consume_order_responses():
    try:
        while True:
            msg = consumer.poll(1.0)  # Poll messages with a 1-second timeout

            if msg is None:
                continue

            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    continue  # End of partition, continue polling
                else:
                    logging.error(f"Kafka 9000error: {msg.error()}")
                    continue

            # Parse the Kafka message
            try:
                logging.info(f"Received message: {msg.value().decode('utf-8')}")
                message_value = json.loads(msg.value().decode('utf-8'))
                order_id = message_value.get('_id')
                status = message_value.get('status')

                if not order_id or not status:
                    logging.warning(f"Invalid message format: {message_value}")
                    continue

                # Update order status in MongoDB
                result = orders_collection.update_one(
                    {'_id': ObjectId(order_id)},  # Use ObjectId to match MongoDB format
                    {'$set': {'status': status}}
                )

                if result.matched_count > 0:
                    logging.info(f"Order {order_id} status updated to '{status}'")
                else:
                    logging.warning(f"No order found with ID {order_id}")

            except Exception as e:
                logging.error(f"Error processing message: {str(e)}")

    finally:
        consumer.close()
        logging.info("Kafka consumer closed.")


# Start the Kafka consumer in a background thread
consumer_thread = threading.Thread(target=consume_order_responses, daemon=True)
consumer_thread.start()
# Kafka configuration

@app.route("/")
@token_required
def index():
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return "Hello, World!", 200
    except Exception:
        return render_template('error.html')


@app.before_request
def handle_preflight():
    """Handle CORS preflight (OPTIONS) requests."""
    if request.method == 'OPTIONS':
        # Respond to the preflight request
        response = app.make_response("")
        response.headers["Access-Control-Allow-Origin"] = "http://35.207.127.84:5173"
        response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type"
        response.headers["Access-Control-Allow-Credentials"] = "true"
        return response  # Respond to OPTIONS without further processing



@app.route("/orders", methods=["GET"])
@token_required
def get_order():
    try:
        user_name = request.user.get("preferred_username")
        logger.debug(f"Fetching orders for user: {user_name}")
        if user_name:
            found_orders = list(orders_collection.find({"user_name": user_name}))
            logger.debug(f"Raw orders fetched from MongoDB: {found_orders}")
            for order in found_orders:
                order["_id"] = str(order["_id"])
            logger.debug(f"Orders after processing: {found_orders}")
            return jsonify(found_orders), 200
        else:
            return jsonify({"message": "User name not found in token"}), 400
    except Exception as e:
        logger.error(f"Error fetching orders: {e}")
        return str(e), 500
# Kafka setup
def create_kafka_topic(topic_name, num_partitions=1, replication_factor=1):
    try:
        admin_client = AdminClient({'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS})
        existing_topics = admin_client.list_topics(timeout=5).topics
        if topic_name in existing_topics:
            logging.info(f"Kafka topic '{topic_name}' already exists.")
        else:
            new_topic = NewTopic(topic=topic_name, num_partitions=num_partitions, replication_factor=replication_factor)
            admin_client.create_topics([new_topic])
            logging.info(f"Kafka topic '{topic_name}' created successfully.")
    except Exception as e:
        logging.error(f"Error creating Kafka topic '{topic_name}': {e}")

# @app.route("/orders", methods=["POST"])
# def create_order():
#     try:
#         data = request.get_json()
#         user_name = data.get("user_name")
#         cart_items = data.get("items", [])

#         # Validate input
#         if not user_name:
#             return jsonify({"message": "User name is required for checkout"}), 400
#         if not cart_items:
#             return jsonify({"message": "Cart is empty!"}), 400

#         total = 0
#         order_items = []

#         # Process cart items
#         for item in cart_items:
#             product_id = item.get("product_id")
#             title = item.get("title")
#             quantity = item.get("quantity")
#             price = item.get("price")

#             if not product_id or not title or quantity is None or price is None:
#                 return jsonify({"message": f"Missing data for item: {item}"}), 400

#             if quantity <= 0:
#                 return jsonify({"message": f"Invalid quantity for {title}"}), 400

#             total += price * quantity
#             order_items.append({
#                 "product_id": product_id,
#                 "title": title,
#                 "quantity": quantity,
#                 "price": price
#             })

#         # Create the order object
#         order = {
#             "user_name": user_name,
#             "items": order_items,
#             "total": total,
#             "status": "Pending"
#         }

#         # Insert order into the database
#         orders_collection.insert_one(order)

#         # Send order details to Kafka
#         kafka_message = {
#             "user_name": user_name,
#             "order_items": order_items,
#             "total": total
#         }

#         # Serialize Kafka message as JSON
#         kafka_producer.produce(
#             "order-topic",
#             value=json.dumps(kafka_message),  # Serialize as JSON
#             callback=delivery_report
#         )
#         kafka_producer.flush()

#         # Log success
#         print(f"Order created and sent to Kafka: {kafka_message}")
#         return jsonify({"message": "Order placed successfully!", "order_total": total}), 201

#     except Exception as e:
#         print(f"Error occurred: {str(e)}")
#         return jsonify({"message": "An error occurred while placing the order"}), 500

@app.route("/orders", methods=["POST"])
@token_required
def create_order():
    try:
        data = request.get_json()
        user_name = data.get("user_name")
        cart_items = data.get("items", [])

        # Validate input
        if not user_name:
            return jsonify({"message": "User name is required for checkout"}), 400
        if not cart_items:
            return jsonify({"message": "Cart is empty!"}), 400

        total = 0
        order_items = []

        # Process cart items
        for item in cart_items:
            product_id = item.get("product_id")
            title = item.get("title")
            quantity = item.get("quantity")
            price = item.get("price")

            if not product_id or not title or quantity is None or price is None:
                return jsonify({"message": f"Missing data for item: {item}"}), 400

            if quantity <= 0:
                return jsonify({"message": f"Invalid quantity for {title}"}), 400

            total += price * quantity
            order_items.append({
                "product_id": product_id,
                "title": title,
                "quantity": quantity,
                "price": price
            })

        # Create the order object
        order = {
            "user_name": user_name,
            "items": order_items,
            "total": total,
            "status": "Pending"
        }

        # Insert order into MongoDB and retrieve the generated _id
        result = orders_collection.insert_one(order)
        order["_id"] = str(result.inserted_id)  # Add MongoDB's _id to the order object

        # Send order details to Kafka
        kafka_message = {
            "_id": order["_id"],  # Include _id in the Kafka message
            "user_name": user_name,
            "order_items": order_items,
            "total": total,
        }

        kafka_producer.produce(
            "order-topic",
            value=json.dumps(kafka_message),  # Serialize as JSON
            callback=delivery_report
        )
        kafka_producer.flush()

        logging.info(f"Order created and sent to Kafka: {kafka_message}")
        return jsonify({"message": "Order placed successfully!", "order_total": total, "order_id": order["_id"]}), 201

    except Exception as e:
        logging.error(f"Error occurred while placing the order: {str(e)}")
        return jsonify({"message": "An error occurred while placing the order"}), 500


# @app.route("/orders", methods=["POST"])
# def create_order():
#     try:
#         data = request.get_json()
#         user_name = data.get('user_name')
#         cart_items = data.get('items', [])

#         if not user_name:
#             return jsonify({"message": "User name is required for checkout"}), 400

#         if not cart_items:
#             return jsonify({"message": "Cart is empty!"}), 400

#         total = 0
#         order_items = []

#         for item in cart_items:
#             product_id = item['product_id']
#             title = item['title']
#             quantity = item['quantity']
#             price = item['price']

#             if quantity <= 0:
#                 return jsonify({"message": f"Invalid quantity for {title}"}), 400
            
#             total += price * quantity
#             order_items.append({
#                 "product_id": product_id,
#                 "title": title,
#                 "quantity": quantity,
#                 "price": price
#             })

#         order = {
#             "user_name": user_name,
#             "items": order_items,
#             "total": total,
#             "status": "Pending"
#         }

#         orders_collection.insert_one(order)
#         return jsonify({"message": "Order placed successfully!", "order_total": total}), 201

#     except Exception as e:
#         print(f"Error occurred: {str(e)}")
#         return jsonify({"message": "An error occurred while placing the order"}), 500


@app.route("/orders", methods=["DELETE"])
@token_required
def delete_orders():
    try:
        # Get the new product data from the request
        order = request.get_json()

        # if not product.get("products") or product.get("price") is None:
        #     return {"message": "Product name and price are required"}, 400

        # Insert the new product into the MongoDB collection
        orders_collection.delete_many(order)

        return "Order saved successfully!", 201
    except Exception as e:
        return str(e), 500

if __name__ == "__main__":
    #create_topic('order-topic')
    try:
        create_kafka_topic(CONSUMER_TOPIC_NAME)
    except Exception as e:
        logging.error("Error creating topic")
    app.run(host='0.0.0.0', port=8081)
