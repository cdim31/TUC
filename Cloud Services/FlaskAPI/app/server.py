from flask import Flask, request, render_template, jsonify, send_from_directory
from flask_cors import CORS
from confluent_kafka.admin import AdminClient, NewTopic
import logging
import os
import socket
from pymongo import MongoClient
from bson.json_util import dumps, ObjectId
from confluent_kafka import Producer, Consumer, KafkaError
from werkzeug.utils import secure_filename
import threading
import json
import jwt # PyJWT
from jwt import PyJWKClient, ExpiredSignatureError, InvalidTokenError
from werkzeug.utils import secure_filename
from flask import send_from_directory
from functools import wraps
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# ------------------ CONFIGURATIONS ------------------
# Keycloak Config
KEYCLOAK_SERVER = "http://keycloak-w:8080"
REALM_NAME = "eshop"
KEYCLOAK_PUBLIC_KEY_URL = f"{KEYCLOAK_SERVER}/realms/{REALM_NAME}/protocol/openid-connect/certs"
AUDIENCE = "account" 

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
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            logger.warning("Authorization header is missing or invalid.")
            return jsonify({"message": "Token is missing or invalid"}), 401

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
# Configure logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# MongoDB setup
client = MongoClient("mongodb://productdb:27017/")
db = client['myDatabase']
products_collection = db['products']

# File upload configuration
UPLOAD_FOLDER = '/static/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route("/")
@token_required
def index():
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        return "Hello, World!", 200
    except Exception:
        return render_template('error.html')
# Kafka setup
def create_kafka_topic(topic_name, num_partitions=1, replication_factor=1):
    try:
        admin_client = AdminClient({'bootstrap.servers': KAFKA_BOOTSTRAP_SERVER})
        existing_topics = admin_client.list_topics(timeout=5).topics
        if topic_name in existing_topics:
            logging.info(f"Kafka topic '{topic_name}' already exists.")
        else:
            new_topic = NewTopic(topic=topic_name, num_partitions=num_partitions, replication_factor=replication_factor)
            admin_client.create_topics([new_topic])
            logging.info(f"Kafka topic '{topic_name}' created successfully.")
    except Exception as e:
        logging.error(f"Error creating Kafka topic '{topic_name}': {e}")


KAFKA_BOOTSTRAP_SERVER = 'kafka:19092'
ORDER_TOPIC = 'order-topic'
RESPONSE_TOPIC = 'order-response-topic'

kafka_consumer = Consumer({
    'bootstrap.servers': KAFKA_BOOTSTRAP_SERVER,
    'group.id': 'product-service-group',
    'auto.offset.reset': 'earliest'
})
kafka_producer = Producer({'bootstrap.servers': KAFKA_BOOTSTRAP_SERVER})

kafka_consumer.subscribe([ORDER_TOPIC])

# Helper functions
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def produce_message(topic, message):
    try:
        kafka_producer.produce(topic, value=json.dumps(message))
        kafka_producer.flush()
        logging.info(f"Produced message to topic {topic}: {message}")
    except Exception as e:
        logging.error(f"Failed to produce message to Kafka: {e}")

def consume_messages():
    while True:
        try:
            msg = kafka_consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    continue
                else:
                    logging.error(f"Kafka Consumer error: {msg.error()}")
                    continue

            # Ensure the message is properly deserialized
            try:
                order_message = json.loads(msg.value().decode('utf-8'))
                process_order(order_message)
            except json.JSONDecodeError as e:
                logging.error(f"Invalid JSON message: {msg.value().decode('utf-8')}. Error: {e}")
        except Exception as e:
            logging.error(f"Error consuming Kafka messages: {e}")
            break

        
def process_order(order_message):
    try:
        logging.info(f"Processing order: {order_message}")

        # Extract the MongoDB `_id` from the order_message
        order_id = order_message.get('_id')  # Use `_id` instead of `id`
        if not order_id:
            raise ValueError("Order does not contain '_id'")

        products = order_message.get('order_items', [])
        if not products:
            raise ValueError("Order does not contain 'order_items'")

        # Process each product in the order
        for product in products:
            product_id = product.get('product_id')
            quantity = product.get('quantity')

            if not product_id or quantity is None:
                raise ValueError(f"Product data is missing 'product_id' or 'quantity': {product}")

            # Fetch the product from the database
            product_record = products_collection.find_one({"_id": ObjectId(product_id)})
            if not product_record:
                reject_message = {"_id": order_id, "status": "Reject", "reason": f"Product {product_id} not found"}
                produce_message('order-response-topic', reject_message)
                logging.warning(f"Product ID {product_id} not found. Order {order_id} rejected.")
                return

            # Check if enough stock is available
            if product_record['quantity'] >= quantity:
                # Update product quantity
                new_quantity = product_record['quantity'] - quantity
                products_collection.update_one(
                    {"_id": ObjectId(product_id)},
                    {"$set": {"quantity": new_quantity}}
                )
                
                logging.info(f"Product ID {product_id} stock updated. New quantity: {new_quantity}.")
            else:
                # Reject order if not enough stock
                reject_message = {"_id": order_id, "status": "Reject", "reason": f"Not enough stock for {product_id}"}
                produce_message('order-response-topic', reject_message)
                logging.warning(f"Not enough stock for Product ID {product_id}. Order {_id} rejected.")
                return

        # If all products are successfully processed, accept the order
        success_message = {"_id": order_id, "status": "Success"}
        produce_message('order-response-topic', success_message)
        #logging.info(f"Order {_id} processed successfully.")
    except Exception as e:
        logging.error(f"Error processing order: {e}")


# Start Kafka consumer thread
consumer_thread = threading.Thread(target=consume_messages, daemon=True)
consumer_thread.start()

# Flask routes
@app.route("/products", methods=["GET"])
def get_product():
    try:
        data = request.args
        if "_id" in data:
            product_id = data["_id"]
            found_product = products_collection.find_one({"_id": ObjectId(product_id)})
            return dumps(found_product), 200 if found_product else ({"message": "Product not found"}, 404)
        elif "productName" in data:
            found_products = list(products_collection.find({"productName": data.get("productName")}))
            return dumps(found_products), 200
        elif "seller" in data:
            found_products = list(products_collection.find({"seller": data.get("seller")}))
            return dumps(found_products), 200
        else:
            found_products = list(products_collection.find())
            return dumps(found_products), 200
    except Exception as e:
        return str(e), 404

@app.route("/products", methods=["POST"])
@token_required
def create_product():
    try:
        if 'productImage' not in request.files:
            return {"message": "Image is required"}, 400

        file = request.files['productImage']
        if not file or not allowed_file(file.filename):
            return {"message": "Invalid image file"}, 400

        filename = secure_filename(file.filename)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        seller = request.form.get('seller') 

        data = request.form
        product_data = {
            "productName": data.get("productName"),
            "price": float(data.get("price")),
            "quantity": int(data.get("quantity")),
            "productImage": f"http://35.207.127.84:8080/static/uploads/{filename}",
            "seller" : seller
        }
        products_collection.insert_one(product_data)
        logging.info(f"Product created: {product_data}")
        return {"message": "Product created successfully"}, 201
    except Exception as e:
        logging.error(f"Error creating product: {e}")
        return {"message": "Error creating product"}, 500

@app.route("/static/uploads/<path:filename>")
def uploaded_file(filename):
    return send_from_directory(app.config["UPLOAD_FOLDER"], filename)

@app.route("/products", methods=["PUT"])
@token_required
def update_product():
    data = request.args
    up_data = request.get_json()
    product_id = data.get("_id")
    if not product_id:
        return {"message": "Product ID is missing!"}, 400
    updated_product = {
        "price": up_data.get("price"),
        "quantity": up_data.get("quantity"),
    }
    result = products_collection.update_one({"_id": ObjectId(product_id)}, {"$set": updated_product})
    if result.matched_count == 0:
        return {"message": f"Product ID: {product_id} not found!"}, 404
    return {"message": f"Product ID: {product_id} updated successfully!"}, 200

@app.route("/products", methods=["DELETE"])
@token_required
def delete_product():
    data = request.args
    product_id = data.get('_id')
    if not product_id:
        return {"message": "Product ID is missing!"}, 400
    product = products_collection.find_one({"_id": ObjectId(product_id)})
    if product:
        products_collection.delete_one({"_id": ObjectId(product_id)})
        # Remove the image file if it exists
        image_path = os.path.join(app.config['UPLOAD_FOLDER'], product['productImage'].split('/')[-1])
        if os.path.exists(image_path):
            os.remove(image_path)
        return {"message": f"Product ID: {product_id} and its image deleted successfully!"}, 200
    else:
        return {"message": f"Product ID: {product_id} not found!"}, 404


if __name__ == "__main__":
    create_kafka_topic('order-topic')          # Ensure order-topic exists
    create_kafka_topic('order-response-topic') # Ensure order-response-topic exists
    app.run(host="0.0.0.0", port=8080)


