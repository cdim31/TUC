import React from 'react';
import './order.css';

export const Order = ({ data }) => {
    const formatTimestamp = (id) => {
        try {
            const timestamp = parseInt(id.substring(0, 8), 16) * 1000; // Convert ObjectID to timestamp
            return new Date(timestamp).toLocaleString(); // Format as local time
        } catch {
            return 'Invalid Timestamp';
        }
    };

    return (
        <div className="order">
            <h3>Order's ID: <b>{data._id}</b></h3>
            <p className="timestamp">Timestamp: {formatTimestamp(data._id)}</p>
            <h4>Products:</h4>
            <ul>
                {data.items.map((item, index) => (
                    <li key={index}>
                        <p><b>Product ID:</b> {item.product_id}</p>
                        <p><b>Name:</b> {item.title}</p>
                        <p><b>Quantity:</b> {item.quantity}</p>
                        <p><b>Price:</b> {item.price}€</p>
                    </li>
                ))}
            </ul>
            <p>Total Price: <b>{data.total}€</b></p>
            <p>Status: <b className="status">{data.status}</b></p>
        </div>
    );
};
