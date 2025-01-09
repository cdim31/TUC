// import React, {useContext} from 'react';
// import { ShopContext } from "../../context/shop-context";


// export const Product = (props) => {

//     const {_id, productName, price, productImage, quantity} = props.data   //changed id
//     const productId = _id.$oid; // Use _id.$oid to get the string ID

//     const{ addToCart, cartItems } = useContext(ShopContext);
//     const cartItemAmount = (cartItems[productId] || 0); // Default to 0 if the item isn't in the cart yet

//     return( 
//         <div className="product"> 
//             <img src={productImage}/>
//             <div className="description">
//                 <p>
//                     <b>{productName}</b>
//                 </p>
//                 <p>
//                     {price} €
//                 </p>
//             </div>
//             <button
//                 className="addToCartBttn"
//                 onClick={() => addToCart(productId)}
//                 disabled={quantity === 0}
//             >      
//                 {quantity === 0 
//                 ? "Out of Stock"
//                 : <>Add To Cart {cartItemAmount > 0 && cartItemAmount <= quantity && <> ({cartItemAmount}) </>}</>
//                 }
//             </button>
//         </div>
//     );
// };
// import React, { useContext, useState } from "react";
// import { ShopContext } from "../../context/shop-context";
// import "./product.css";

// export const Product = (props) => {
//   const { _id, productName, price, productImage, quantity } = props.data; // Product details including availability
//   const { addToCart, cartItems } = useContext(ShopContext);
//   const [errorMessage, setErrorMessage] = useState("");
//   const productId = _id.$oid;

//   // Get current quantity in the cart for this product
//   const cartItemCount = (cartItems[productId] || 0);
//   console.log(productImage)
//   // Function to handle adding the item to the cart
//   const handleAddToCart = () => {
//     if (cartItemCount < quantity) {
//       // Only add to cart if it doesn't exceed available stock
//       addToCart(productId);
//       setErrorMessage(""); // Clear any error message
//     } else {
//       setErrorMessage("Cannot add more than available stock"); // Show error if exceeding stock
//     }
//   };

//   return (
//     <div className="product">
      
//       <img src={productImage} alt={productName} />

//       <div className="description">
//         <p><b>{productName}</b></p>
//         <p>€{price.toFixed(2)}</p>
//         <p className="availability">
//           Availability: {quantity > 0 ? `${quantity} in stock` : "Out of stock"}
//         </p>
//       </div>
//       <button
//             className="addToCartBttn"
//             onClick={handleAddToCart}
//             disabled={cartItemCount >= quantity || quantity === 0} 
//       >      
//             {quantity === 0 
//             ? "Out of Stock"
//             : <>Add To Cart {cartItemCount > 0 && cartItemCount <= quantity && <> ({cartItemCount}) </>}</>
//             }
//       </button>
//       {/* <button 
//         className="addToCartBttn" 
//         onClick={handleAddToCart} 
//         disabled={cartItemCount >= quantity || quantity === 0}  // Disable when cart has reached the available stock
//       >
//         Add To Cart {cartItemCount > 0 && <>({cartItemCount})</>}
//       </button> */}

//       {/* Show an error message if trying to add more than available stock */}
//       {errorMessage && <p className="error">{errorMessage}</p>}
//     </div>
//   );
// };

import React, { useContext, useState } from "react";
import { ShopContext } from "../../context/shop-context";
import "./product.css";

export const Product = (props) => {
  const { _id, productName, price, productImage, quantity, seller } = props.data;
  const { addToCart, cartItems } = useContext(ShopContext);
  const [errorMessage, setErrorMessage] = useState("");
  const productId = _id.$oid;

  const cartItemCount = cartItems[productId] || 0;

  const handleAddToCart = () => {
    if (cartItemCount < quantity) {
      addToCart(productId);
      setErrorMessage("");
    } else {
      setErrorMessage("Cannot add more than available stock");
    }
  };

  return (
    <div className="product">
      <img src={productImage} alt={productName} className="product-image" />
      <div className="description">
        <p><b>{productName}</b></p>
        <p className="seller">Provided by: {seller}</p>
        <p>€{price.toFixed(2)}</p>
        <p className="availability">
          Availability: {quantity > 0 ? `${quantity} in stock` : "Out of stock"}
        </p>
      </div>
      
      <button
        className="addToCartBttn"
        onClick={handleAddToCart}
        disabled={cartItemCount >= quantity || quantity === 0}
      >
        {quantity === 0 
          ? "Out of Stock"
          : <>Add To Cart {cartItemCount > 0 && cartItemCount <= quantity && <> ({cartItemCount}) </>}</>
        }
      </button>

      {errorMessage && <p className="error">{errorMessage}</p>}
    </div>
  );
};
