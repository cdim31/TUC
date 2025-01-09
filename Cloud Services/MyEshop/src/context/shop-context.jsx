import {createContext, useEffect, useState } from 'react'
import axios from 'axios';
import Cookies from 'js-cookie';
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

export const ShopContext = createContext(null);

const pUrl = import.meta.env.VITE_PRODUCTS_API_URL;
export const ShopContextProvider = (props) => {

    const [cartItems, setCartItems] = useState(() => {
        const savedCart = Cookies.get('cart');
        return savedCart ? JSON.parse(savedCart) : {};
    });

    useEffect(() => {
        Cookies.set('cart', JSON.stringify(cartItems), { expires: 7 });
    }, [cartItems]);

    const [products, setProducts] = useState([]);

    useEffect(() => {
        axios.get(`${pUrl}`)
            .then(response => {
                setProducts(response.data);
            })
            .catch(error => {
                console.error('There was an error fetching the products!', error);
            });
    }, []);


    const getTotalCartAmount = () => {
        let totalAmount = 0;
        for(const item in cartItems){
            if (cartItems[item] > 0) {
                // let itemInfo = products.find((product) => product.id == Number(item));
                let itemInfo = products.find((product) => product._id.$oid === item);
                if (itemInfo) {
                    totalAmount += cartItems[item] * itemInfo.price;
                } else {
                    console.warn(`Product with ID ${item} not found in the products list.`);
                }
              }
            
        }

        return totalAmount;
    }

    const addToCart = (itemId) => {
        axios.get(`${pUrl}`)
            .then(response => {
                setProducts(response.data);
            })
            .catch(error => {
                console.error('There was an error fetching the products!', error);
            });
        setCartItems((prev) => ({ ...prev, [itemId]: (prev[itemId] || 0) + 1 }));
    }

    const removeFromCart = (itemId) => {
        setCartItems((prev) => ({ ...prev, [itemId]: prev[itemId] > 1 ? prev[itemId] - 1 : 0 }));
    }

    const updateCartItemCount = (newAmount, itemId) => {
        setCartItems((prev) => ({ ...prev, [itemId]: newAmount }));
    }

    const clearCart = () => {
        setCartItems([]);  // Reset the cart to an empty array
    };

    const contextValue = {cartItems, addToCart, removeFromCart, updateCartItemCount, getTotalCartAmount, clearCart};

    return <ShopContext.Provider value={contextValue}>{props.children}</ShopContext.Provider>;
}
