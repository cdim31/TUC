import React, { useState, useEffect } from 'react';
import { Order } from './order';
import axios from 'axios';
import './order.css';

export const OrderList = () => {
  const [orders, setOrders] = useState([]);
  const [userName, setUserName] = useState('');
  const [error, setError] = useState(null);
  const oUrl = import.meta.env.VITE_ORDERS_API_URL;

  // Set up Axios interceptors globally
  useEffect(() => {
    if (axios.interceptors.request.handlers.length === 0) {
      axios.interceptors.request.use(
        async (config) => {
          const token = localStorage.getItem('access_token');
          if (token) {
            config.headers['Authorization'] = `Bearer ${token}`; // Attach Authorization header
            console.log('Authorization Header Attached:', config.headers['Authorization']);
          } else {
            console.warn('No token found. You may need to log in.');
          }
          return config;
        },
        (error) => Promise.reject(error)
      );

      // axios.interceptors.response.use(
      //   (response) => response, // Return the response if successful
      //   (error) => {
      //     if (error.response && error.response.status === 401) {
      //       // Token is expired or invalid
      //       alert('Your session has expired or you are not authorized. Please log in again.');
      //       localStorage.removeItem('access_token'); // Clear invalid token
      //       window.location.href = '/login'; // Redirect to login page
      //     }
      //     return Promise.reject(error);
      //   }
      // );
    }
  }, []); // Empty dependency ensures interceptor is added only once

  // Fetch username from local storage
  useEffect(() => {
    const storedUserName = localStorage.getItem('username');
    if (storedUserName) {
      setUserName(storedUserName);
    } else {
      console.warn('No username found in local storage!');
    }
  }, []);

  // Fetch orders for the specific user
  useEffect(() => {
    const fetchOrders = async () => {
      try {
       
        const response = await axios.get(oUrl, { params: { user_name: userName } });
       

        // Deduplicate orders
        const uniqueOrders = Array.from(
          new Map(response.data.map((order) => [order._id, order])).values()
        );

        setOrders(uniqueOrders);
        setError(null);
      } catch (err) {
        if (err.response && err.response.status === 401) {
          alert('Your session has expired or you are not authorized. Please log in again.');
          localStorage.removeItem('user_role');
	  localStorage.removeItem('username');
          localStorage.removeItem('refresh_token');
	  localStorage.removeItem('access_token'); // Clear invalid token
          window.location.href = '/'; // Redirect to login page
        } else {
          setError('Failed to fetch orders. Please try again.');
        }
      }
    };

    if (userName && userName.trim() !== '') {
      fetchOrders();
    }
  }, [userName, oUrl]);

  return (
    <div className="orders">
      {error && <p className="error">Error: {error}</p>}
      {orders.length > 0 ? (
        orders.map((order) => (
          <Order key={order._id} data={order} />
        ))
      ) : (
        <p>No orders found for user: {userName}</p>
      )}
    </div>
  );
};
