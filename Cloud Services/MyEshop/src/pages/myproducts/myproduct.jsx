// import React, { useState, useEffect, useRef } from 'react';
// import axios from 'axios';
// import './myproducts.css';

// export const MyProducts = () => {
//   const [productList, setProductList] = useState([]);
//   const [newPrice, setNewPrice] = useState({});
//   const [newQuantity, setNewQuantity] = useState({});
//   const [productName, setProductName] = useState('');
//   const [price, setPrice] = useState('');
//   const [quantity, setQuantity] = useState('');
//   const [productImage, setProductImage] = useState(null);
//   const fileInputRef = useRef();

//   // Fetch products from the server
//   const fetchProducts = async () => {
//     try {
//       const response = await axios.get('http://localhost:8080/products');
//       setProductList(response.data);
//     } catch (error) {
//       console.error('Error fetching products:', error);
//     }
//   };

//   const handleAddProduct = async () => {
//     const formData = new FormData();
//     formData.append('productName', productName);
//     formData.append('price', Number(price));
//     formData.append('quantity', Number(quantity));
//     formData.append('productImage', productImage);

//     try {
//       await axios.post('http://localhost:8080/products', formData, {
//         headers: { 'Content-Type': 'multipart/form-data' },
//       });
//       fetchProducts();
//       setProductName('');
//       setPrice('');
//       setQuantity('');
//       setProductImage(null);
//       fileInputRef.current.value = "";
//     } catch (error) {
//       console.error('Error adding the product:', error);
//       alert('There was an error adding your product. Please try again.');
//     }
//   };

//   const handleUpdateProduct = async (id, price, quantity) => {
//     try {
//       const updatedProduct = {
//         price: newPrice[id] ? Number(newPrice[id]) : price,
//         quantity: newQuantity[id] ? Number(newQuantity[id]) : quantity,
//       };
//       await axios.put(`http://localhost:8080/products?_id=${id}`, updatedProduct);
//       fetchProducts();
//     } catch (error) {
//       console.error('Error updating product:', error);
//       alert('There was an error updating the product. Please try again.');
//     }
//   };

//   const handleDeleteProduct = async (id) => {
//     try {
//       await axios.delete(`http://localhost:8080/products?_id=${id}`);
//       fetchProducts();
//     } catch (error) {
//       console.error('Error deleting product:', error);
//       alert('There was an error deleting the product. Please try again.');
//     }
//   };

//   // Fetch products when the component mounts
//   useEffect(() => {
//     fetchProducts();
//   }, []);

//   return (
//     <div className="product-management">
//       <h2>Product Management</h2>
//       <div className="add-product">
//         <h3>Add a New Product</h3>
//         <input
//           type="text"
//           placeholder="Product Name"
//           value={productName}
//           onChange={(e) => setProductName(e.target.value)}
//         />
//         <input
//           type="number"
//           placeholder="Price"
//           value={price}
//           onChange={(e) => setPrice(e.target.value)}
//         />
//         <input
//           type="number"
//           placeholder="Quantity"
//           value={quantity}
//           onChange={(e) => setQuantity(e.target.value)}
//         />
//         <input
//           type="file"
//           ref={fileInputRef}
//           onChange={(e) => setProductImage(e.target.files[0])}
//         />
//         <button onClick={handleAddProduct}>Add Product</button>
//       </div>

//       <h3>Product List</h3>
//       <div className="product-list">
//         {productList.map((product) => (
//           <div className="product-item" key={product._id.$oid}>
//             <img src={product.productImage} alt={product.productName} className="product-image" />
//             <h4>{product.productName}</h4>
//             <p>€{product.price.toFixed(2)} (Quantity: {product.quantity})</p>

//             <input
//               type="number"
//               placeholder="New Price"
//               value={newPrice[product._id.$oid] || ''}
//               onChange={(e) => setNewPrice({ ...newPrice, [product._id.$oid]: e.target.value })}
//             />
//             <input
//               type="number"
//               placeholder="New Quantity"
//               value={newQuantity[product._id.$oid] || ''}
//               onChange={(e) => setNewQuantity({ ...newQuantity, [product._id.$oid]: e.target.value })}
//             />

//             <button onClick={() => handleUpdateProduct(product._id.$oid, product.price, product.quantity)}>
//               Update Product
//             </button>
//             <button className="delete-button" onClick={() => handleDeleteProduct(product._id.$oid)}>
//               Delete Product
//             </button>
//           </div>
//         ))}
//       </div>
//     </div>
//   );
// };

import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import './myproducts.css';
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
export const MyProducts = () => {
  const [productList, setProductList] = useState([]);
  const [newPrice, setNewPrice] = useState({});
  const [newQuantity, setNewQuantity] = useState({});
  const [productName, setProductName] = useState('');
  const [price, setPrice] = useState('');
  const [quantity, setQuantity] = useState('');
  const [productImage, setProductImage] = useState(null);
  const fileInputRef = useRef();

  const pUrl = import.meta.env.VITE_PRODUCTS_API_URL;
  // Fetch products from the server
  const fetchProducts = async () => {
    try {
      const seller = localStorage.getItem("username"); // Assuming the seller's username is stored in localStorage

      if (!seller) {
        alert("Seller information is missing. Please log in.");
        return;
    }
      //const response = await axios.get('http://localhost:8080/products');
      const response = await axios.get(`${pUrl}`, {
        params: { seller }, // Send seller as query parameter
      });
      setProductList(response.data);
    } catch (error) {
      console.error('Error fetching products:', error);
    }
  };

  const handleAddProduct = async () => {
    const seller = localStorage.getItem("username"); // Assuming the seller's username is stored in localStorage

    if (!seller) {
      alert("Seller information is missing. Please log in.");
      return;
    }

    const formData = new FormData();
    formData.append('productName', productName);
    formData.append('price', Number(price));
    formData.append('quantity', Number(quantity));
    formData.append('productImage', productImage);
    formData.append('seller', seller); // Add the seller to the payload

    try {
      await axios.post(`${pUrl}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      fetchProducts(); // Refresh the product list
      setProductName('');
      setPrice('');
      setQuantity('');
      setProductImage(null);
      fileInputRef.current.value = ''; // Clear the file input
    } catch (error) {
      console.error('Error adding the product:', error);
      alert('There was an error adding your product. Please try again.');
    }
  };

  const handleUpdateProduct = async (id, price, quantity) => {
    try {
      const updatedProduct = {
        price: newPrice[id] ? Number(newPrice[id]) : price,
        quantity: newQuantity[id] ? Number(newQuantity[id]) : quantity,
      };
      await axios.put(`${pUrl}?_id=${id}`, updatedProduct);
      fetchProducts();
    } catch (error) {
      console.error('Error updating product:', error);
      alert('There was an error updating the product. Please try again.');
    }
  };

  const handleDeleteProduct = async (id) => {
    try {
      await axios.delete(`${pUrl}?_id=${id}`);
      fetchProducts();
    } catch (error) {
      console.error('Error deleting product:', error);
      alert('There was an error deleting the product. Please try again.');
    }
  };

  // Fetch products when the component mounts
  useEffect(() => {
    fetchProducts();
  }, []);

  return (
    <div className="product-management">
      <h2>Product Management</h2>
      <div className="add-product">
        <h3>Add a New Product</h3>
        <input
          type="text"
          placeholder="Product Name"
          value={productName}
          onChange={(e) => setProductName(e.target.value)}
        />
        <input
          type="number"
          placeholder="Price"
          value={price}
          onChange={(e) => setPrice(e.target.value)}
        />
        <input
          type="number"
          placeholder="Quantity"
          value={quantity}
          onChange={(e) => setQuantity(e.target.value)}
        />
        <input
          type="file"
          ref={fileInputRef}
          onChange={(e) => setProductImage(e.target.files[0])}
        />
        <button onClick={handleAddProduct}>Add Product</button>
      </div>

      <h3>Product List</h3>
      <div className="product-list">
        {productList.map((product) => (
          <div className="product-item" key={product._id.$oid}>
            <img src={product.productImage} alt={product.productName} className="product-image" />
            <h4>{product.productName}</h4>
            <p>€{product.price.toFixed(2)} (Quantity: {product.quantity})</p>

            <input
              type="number"
              placeholder="New Price"
              value={newPrice[product._id.$oid] || ''}
              onChange={(e) => setNewPrice({ ...newPrice, [product._id.$oid]: e.target.value })}
            />
            <input
              type="number"
              placeholder="New Quantity"
              value={newQuantity[product._id.$oid] || ''}
              onChange={(e) => setNewQuantity({ ...newQuantity, [product._id.$oid]: e.target.value })}
            />

            <button onClick={() => handleUpdateProduct(product._id.$oid, product.price, product.quantity)}>
              Update Product
            </button>
            <button className="delete-button" onClick={() => handleDeleteProduct(product._id.$oid)}>
              Delete Product
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};
