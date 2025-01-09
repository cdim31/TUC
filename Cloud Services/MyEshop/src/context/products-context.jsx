// products-context.js
import React, { createContext, useEffect, useState } from 'react';
import axios from 'axios';
axios.interceptors.request.use(
 		async (config) => { 
 			let token = localStorage.getItem("access_token");
 
 			if (!token) {
 				console.warn("No token found. You may need to log in.");
 				return config;
 			}
			// Set the Authorization header
			config.headers["Authorization"] = `Bearer ${token}`;
			return config;
		},
		(error) => {
 			return Promise.reject(error);
 		}
	);
export const ProductsContext = createContext();

const pUrl = import.meta.env.VITE_PRODUCTS_API_URL;
export const ProductsProvider = ({ children }) => {
    const [products, setProducts] = useState([]);

    useEffect(() => {
        const fetchProducts = async () => {
            try {
                const response = await axios.get(`${pUrl}`);
                setProducts(response.data);
            } catch (error) {
                console.error('There was an error fetching the products!', error);
            }
        };
        
        fetchProducts();
    }, []);

    return (
        <ProductsContext.Provider value={products}>
            {children}
        </ProductsContext.Provider>
    );
};
