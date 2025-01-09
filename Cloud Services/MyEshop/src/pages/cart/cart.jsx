// import React, { useContext, useState, useEffect } from "react";
// import { ShopContext } from "../../context/shop-context";
// import { CartItem } from "./cart-item";
// import "./cart.css";
// import axios from "axios";
// import { useNavigate } from "react-router-dom";

// export const Cart = () => {
//     const { cartItems, clearCart } = useContext(ShopContext);
//     const [products, setProducts] = useState([]);
//     const [totalAmount, setTotalAmount] = useState(0);
//     const navigate = useNavigate();

//     // Function to calculate total amount
//     const calculateTotal = () => {
//         return products.reduce((total, product) => {
//             const quantity = cartItems[product._id.$oid] || 0;
//             return total + quantity * product.price;
//         }, 0);
//     };

//     // Check if stock is available
//     const isStockAvailable = () => {
//         return Object.keys(cartItems).every((itemId) => {
//             const itemQuantity = cartItems[itemId];
//             const product = products.find(
//                 (product) => product._id.$oid === itemId
//             );
//             return product && itemQuantity <= product.quantity;
//         });
//     };

//     // Handle Checkout
//     const handleCheckout = async () => {
//         const isLoggedIn = Boolean(localStorage.getItem("access_token")); // Check login status

//         if (!isLoggedIn) {
//             alert("You must log in to proceed with your order.");
//             navigate("/"); // Redirect to home-login page
//             return;
//         }

//         try {
//             const order = {
//                 products: Object.keys(cartItems)
//                     .filter((productId) => cartItems[productId] > 0)
//                     .map((productId) => {
//                         const product = products.find(
//                             (product) => product._id.$oid === productId
//                         );
//                         return {
//                             productId: productId,
//                             amount: cartItems[productId],
//                             title: product ? product.productName : "Unknown Product",
//                         };
//                     }),
//                 totalAmount: totalAmount,
//                 status: "Pending",
//             };

//             console.log(order);

//             // Send the order to the backend via POST request
//             const request = await axios.post(
//                 "http://localhost:8081/orders",
//                 order
//             );

//             if (request.status === 400) {
//                 alert("Order not placed, due to insufficient stock");
//                 return;
//             }

//             // Process cart items and update product quantities
//             const orderProducts = [];
//             const checkoutPromises = [];
//             const failedItems = [];
//             const productLookup = products.reduce((acc, product) => {
//                 acc[product._id.$oid] = product;
//                 return acc;
//             }, {});

//             for (const itemId in cartItems) {
//                 if (cartItems[itemId] > 0) {
//                     const product = productLookup[itemId];

//                     if (product) {
//                         const updatedQuantity = product.quantity - cartItems[itemId];

//                         if (updatedQuantity >= 0) {
//                             orderProducts.push({
//                                 title: product.productName,
//                                 amount: cartItems[itemId],
//                                 product_id: product._id.$oid,
//                             });

//                             const updatedProduct = {
//                                 price: product.price,
//                                 quantity: updatedQuantity,
//                             };

//                             const requestPromise = axios
//                                 .put(
//                                     `http://localhost:8080/products?_id=${product._id.$oid}`,
//                                     updatedProduct
//                                 )
//                                 .catch((error) => {
//                                     console.error(
//                                         `Error updating ${product.productName}:`,
//                                         error
//                                     );
//                                     failedItems.push(product.productName);
//                                 });

//                             checkoutPromises.push(requestPromise);
//                         } else {
//                             console.warn(
//                                 `Insufficient stock for ${product.productName}`
//                             );
//                             failedItems.push(product.productName);
//                         }
//                     }
//                 }
//             }

//             await Promise.all(checkoutPromises);
//             clearCart();
//         } catch (error) {
//             console.error("Error placing the order:", error);
//             alert("There was an error placing your order. Please try again.");
//         }
//     };

//     useEffect(() => {
//         axios
//             .get("http://localhost:8080/products")
//             .then((response) => {
//                 setProducts(response.data);
//                 setTotalAmount(calculateTotal()); // Set total amount when products are fetched
//             })
//             .catch((error) => {
//                 console.error("There was an error fetching the products!", error);
//             });
//     }, [cartItems]);

//     useEffect(() => {
//         const updateTotal = calculateTotal();
//         setTotalAmount(updateTotal); // Update total amount whenever products or cartItems change
//     }, [products, cartItems]);

//     return (
//         <div className="cart">
//             <div>
//                 <h1>Your Cart Items</h1>
//             </div>
//             <div className="cart-items">
//                 {products
//                     .filter((product) => cartItems[product._id.$oid] > 0)
//                     .map((product) => (
//                         <CartItem key={product._id.$oid} data={product} />
//                     ))}
//             </div>
//             <div className="Amount">Total Amount: ${totalAmount.toFixed(2)}</div>
//             <div className="checkout">
//                 <button
//                     onClick={handleCheckout}
//                     disabled={
//                         Object.keys(cartItems).length === 0 || !isStockAvailable()
//                     }
//                     className={
//                         Object.keys(cartItems).length === 0 || !isStockAvailable()
//                             ? "disabled"
//                             : ""
//                     }
//                 >
//                     Checkout
//                 </button>
//                 <button onClick={clearCart}>Clear Cart</button>
//             </div>
//         </div>
//     );
// };
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// import React, { useContext, useState, useEffect } from "react";
// import { ShopContext } from "../../context/shop-context";
// import { CartItem } from "./cart-item";
// import "./cart.css";
// import axios from "axios";
// import { useNavigate } from "react-router-dom";
// import Cookies from "js-cookie";

// export const Cart = () => {
//     const { cartItems, clearCart, updateCart } = useContext(ShopContext); // Added updateCart for restoring cart
//     const [products, setProducts] = useState([]);
//     const [totalAmount, setTotalAmount] = useState(0);
//     const navigate = useNavigate();

//     // Function to calculate total amount
//     const calculateTotal = () => {
//         return products.reduce((total, product) => {
//             const quantity = cartItems[product._id.$oid] || 0;
//             return total + quantity * product.price;
//         }, 0);
//     };

//     // Check if stock is available
//     const isStockAvailable = () => {
//         return Object.keys(cartItems).every((itemId) => {
//             const itemQuantity = cartItems[itemId];
//             const product = products.find(
//                 (product) => product._id.$oid === itemId
//             );
//             return product && itemQuantity <= product.quantity;
//         });
//     };

//     // Handle Checkout
//     const handleCheckout = async () => {
//         const isLoggedIn = Boolean(localStorage.getItem("access_token")); // Check login status

//         if (!isLoggedIn) {
//             // Save cart items to a cookie before redirecting
//             Cookies.set("cart_redirect", JSON.stringify(cartItems), { expires: 1 }); // Expires in 1 day
//             alert("You must log in to proceed with your order.");
//             navigate("/"); // Redirect to home page
//             return;
//         }

//         try {
//             const order = {
//                 products: Object.keys(cartItems)
//                     .filter((productId) => cartItems[productId] > 0)
//                     .map((productId) => {
//                         const product = products.find(
//                             (product) => product._id.$oid === productId
//                         );
//                         return {
//                             productId: productId,
//                             amount: cartItems[productId],
//                             title: product ? product.productName : "Unknown Product",
//                         };
//                     }),
//                 totalAmount: totalAmount,
//                 status: "Pending",
//             };

//             console.log(order);

//             // Send the order to the backend via POST request
//             const request = await axios.post(
//                 "http://localhost:8081/orders",
//                 order
//             );

//             if (request.status === 400) {
//                 alert("Order not placed, due to insufficient stock");
//                 return;
//             }

//             // Process cart items and update product quantities
//             const orderProducts = [];
//             const checkoutPromises = [];
//             const failedItems = [];
//             const productLookup = products.reduce((acc, product) => {
//                 acc[product._id.$oid] = product;
//                 return acc;
//             }, {});

//             for (const itemId in cartItems) {
//                 if (cartItems[itemId] > 0) {
//                     const product = productLookup[itemId];

//                     if (product) {
//                         const updatedQuantity = product.quantity - cartItems[itemId];

//                         if (updatedQuantity >= 0) {
//                             orderProducts.push({
//                                 title: product.productName,
//                                 amount: cartItems[itemId],
//                                 product_id: product._id.$oid,
//                             });

//                             const updatedProduct = {
//                                 price: product.price,
//                                 quantity: updatedQuantity,
//                             };

//                             const requestPromise = axios
//                                 .put(
//                                     `http://localhost:8080/products?_id=${product._id.$oid}`,
//                                     updatedProduct
//                                 )
//                                 .catch((error) => {
//                                     console.error(
//                                         `Error updating ${product.productName}:`,
//                                         error
//                                     );
//                                     failedItems.push(product.productName);
//                                 });

//                             checkoutPromises.push(requestPromise);
//                         } else {
//                             console.warn(
//                                 `Insufficient stock for ${product.productName}`
//                             );
//                             failedItems.push(product.productName);
//                         }
//                     }
//                 }
//             }

//             await Promise.all(checkoutPromises);
//             clearCart();
//         } catch (error) {
//             console.error("Error placing the order:", error);
//             alert("There was an error placing your order. Please try again.");
//         }
//     };

//     // Restore cart from cookie if present
//     useEffect(() => {
//         const cartRedirect = Cookies.get("cart_redirect");
//         if (cartRedirect) {
//             const savedCart = JSON.parse(cartRedirect);
//             Object.keys(savedCart).forEach((itemId) => {
//                 updateCart(itemId, savedCart[itemId]); // Update the cart context
//             });
//             Cookies.remove("cart_redirect"); // Clear the cookie after restoring the cart
//         }
//     }, [updateCart]);

//     useEffect(() => {
//         axios
//             .get("http://localhost:8080/products")
//             .then((response) => {
//                 setProducts(response.data);
//                 setTotalAmount(calculateTotal()); // Set total amount when products are fetched
//             })
//             .catch((error) => {
//                 console.error("There was an error fetching the products!", error);
//             });
//     }, [cartItems]);

//     useEffect(() => {
//         const updateTotal = calculateTotal();
//         setTotalAmount(updateTotal); // Update total amount whenever products or cartItems change
//     }, [products, cartItems]);

//     return (
//         <div className="cart">
//             <div>
//                 <h1>Your Cart Items</h1>
//             </div>
//             <div className="cart-items">
//                 {products
//                     .filter((product) => cartItems[product._id.$oid] > 0)
//                     .map((product) => (
//                         <CartItem key={product._id.$oid} data={product} />
//                     ))}
//             </div>
//             <div className="Amount">Total Amount: ${totalAmount.toFixed(2)}</div>
//             <div className="checkout">
//                 <button
//                     onClick={handleCheckout}
//                     disabled={
//                         Object.keys(cartItems).length === 0 || !isStockAvailable()
//                     }
//                     className={
//                         Object.keys(cartItems).length === 0 || !isStockAvailable()
//                             ? "disabled"
//                             : ""
//                     }
//                 >
//                     Checkout
//                 </button>
//                 <button onClick={clearCart}>Clear Cart</button>
//             </div>
//         </div>
//     );
// };

import React, { useContext, useState, useEffect } from "react";
import { ShopContext } from "../../context/shop-context";
import { CartItem } from "./cart-item";
import "./cart.css";
import axios from "axios";
import { useNavigate } from "react-router-dom";
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
const pUrl = import.meta.env.VITE_PRODUCTS_API_URL;
const oUrl = import.meta.env.VITE_ORDERS_API_URL;

export const Cart = () => {
    const { cartItems, clearCart } = useContext(ShopContext);
    const [products, setProducts] = useState([]);
    const [totalAmount, setTotalAmount] = useState(0);
    const navigate = useNavigate();

    // Function to calculate total amount
    const calculateTotal = () => {
        return products.reduce((total, product) => {
            const quantity = cartItems[product._id.$oid] || 0;
            return total + quantity * product.price;
        }, 0);
    };

    // Check if stock is available
    const isStockAvailable = () => {
        return Object.keys(cartItems).every((itemId) => {
            const itemQuantity = cartItems[itemId];
            const product = products.find(
                (product) => product._id.$oid === itemId
            );
            return product && itemQuantity <= product.quantity;
        });
    };

    // Handle Checkout
    const handleCheckout = async () => {
        const isLoggedIn = Boolean(localStorage.getItem("access_token")); // Check login status
        const username = localStorage.getItem("username"); // Fetch username

        if (!isLoggedIn || !username) {
            alert("You must log in to proceed with your order.");
            navigate("/"); // Redirect to login page
            return;
        }

        try {
            const order = {
                user_name: username, // Include username in the payload
                items: Object.keys(cartItems)
                    .filter((productId) => cartItems[productId] > 0)
                    .map((productId) => {
                        const product = products.find(
                            (product) => product._id.$oid === productId
                        );
                        return {
                            product_id: productId,
                            title: product ? product.productName : "Unknown Product",
                            quantity: cartItems[productId],
                            price: product ? product.price : 0,
                        };
                    }),
                total: totalAmount,
            };

            // Send the order to the backend via POST request
            const response = await axios.post(
                `${oUrl}`, // Use the correct endpoint
                order
            );

            if (response.status === 201) {
                alert("Order placed successfully!");
                clearCart(); // Clear the cart after successful order
                navigate("/orders"); // Redirect to orders page
            } else {
                alert("Failed to place the order. Please try again.");
            }
        } catch (error) {
            console.error("Error placing the order:", error);
            alert("There was an error placing your order. Please try again.");
        }
    };

    useEffect(() => {
        axios
            .get(`${pUrl}`)
            .then((response) => {
                setProducts(response.data);
                setTotalAmount(calculateTotal()); // Set total amount when products are fetched
            })
            .catch((error) => {
                console.error("There was an error fetching the products!", error);
            });
    }, [cartItems]);

    useEffect(() => {
        const updateTotal = calculateTotal();
        setTotalAmount(updateTotal); // Update total amount whenever products or cartItems change
    }, [products, cartItems]);

    return (
        <div className="cart">
            <div>
                <h1>Your Cart Items</h1>
            </div>
            <div className="cart-items">
                {products
                    .filter((product) => cartItems[product._id.$oid] > 0)
                    .map((product) => (
                        <CartItem key={product._id.$oid} data={product} />
                    ))}
            </div>
            <div className="Amount">Total Amount: ${totalAmount.toFixed(2)}</div>
            <div className="checkout">
                <button
                    onClick={handleCheckout}
                    disabled={
                        Object.keys(cartItems).length === 0 || !isStockAvailable()
                    }
                    className={
                        Object.keys(cartItems).length === 0 || !isStockAvailable()
                            ? "disabled"
                            : ""
                    }
                >
                    Checkout
                </button>
                <button onClick={clearCart}>Clear Cart</button>
            </div>
        </div>
    );
};

