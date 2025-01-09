// import React, {useEffect, useState} from 'react';
// import { Product } from './product'; // Ensure the path is correct
// import axios from 'axios';
// import { ShopContextProvider } from '../../context/shop-context';

// export const ProductList = () => {
//   const [products, setProducts] = useState([]);
  
//   useEffect(() => {
//       axios.get('http://localhost:8080/products')
//           .then(response => {
//               setProducts(response.data);
//           })
//           .catch(error => {
//               console.error('There was an error fetching the products!', error);
//           });
//   }, []);
//   return (
//     <div className="products">
      
//       {products.map((product) => (
//           <Product key={product._id.$oid} data={product} />
//       ))}
//     </div>
//   );
// };

// import React, { useEffect, useState } from 'react';
// import axios from 'axios';
// import { Product } from './product'; // Ensure the path is correct
// import "./product.css";

// export const ProductList = () => {
//     const [products, setProducts] = useState([]);
//     const [searchTerm, setSearchTerm] = useState('');

//     useEffect(() => {
//         axios.get('http://localhost:8080/products')
//             .then(response => {
//                 setProducts(response.data);
//             })
//             .catch(error => {
//                 console.error('There was an error fetching the products!', error);
//             });
//     }, []);

//     // Function to handle search input changes
//     const handleSearchChange = (event) => {
//         setSearchTerm(event.target.value);
//     };

//     // Filter products based on search term
//     const filteredProducts = products.filter(product => 
//         product.productName.toLowerCase().includes(searchTerm.toLowerCase())
//     );

//     return (
//         <div className="products">
//             <input
//                 type="text"
//                 placeholder="Search products..."
//                 value={searchTerm}
//                 onChange={handleSearchChange}
//                 className="search-bar"
//             />
//             {filteredProducts.length > 0 ? (
//                 filteredProducts.map(product => (
//                     <Product key={product._id.$oid} data={product} />
//                 ))
//             ) : (
//                 <p>No products found.</p> // Display a message if no products match the search
//             )}
//         </div>
//     );
// };

import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Product } from './product'; // Ensure the path is correct
import "./product.css";
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
export const ProductList = () => {
    const [products, setProducts] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');

    const pUrl = import.meta.env.VITE_PRODUCTS_API_URL;
    useEffect(() => {
        axios.get(`${pUrl}`)
            .then(response => {
                setProducts(response.data);
            })
            .catch(error => {
                console.error('There was an error fetching the products!', error);
            });
    }, []);

    // Function to handle search input changes
    const handleSearchChange = (event) => {
        setSearchTerm(event.target.value);
    };

    // Filter products based on search term
    const filteredProducts = products.filter(product => 
        product.productName.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="product-list-container">
            <input
                type="text"
                placeholder="Search products..."
                value={searchTerm}
                onChange={handleSearchChange}
                className="search-bar"
            />
            <div className="products">
                {filteredProducts.length > 0 ? (
                    filteredProducts.map(product => (
                        <Product key={product._id.$oid} data={product} />
                    ))
                ) : (
                    <p>No products found.</p> // Display a message if no products match the search
                )}
            </div>
        </div>
    );
};

