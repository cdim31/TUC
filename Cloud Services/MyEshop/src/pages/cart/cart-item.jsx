import React, { useContext } from 'react';
import { ShopContext } from "../../context/shop-context";
//import "./cart.css";
import "./cart-item.css"

export const CartItem = (props) => {
    const { _id, productName, price, productImage, quantity } = props.data;
    const productId = _id.$oid; // Use _id.$oid to get the string ID

    const { cartItems, addToCart, removeFromCart, updateCartItemCount } = useContext(ShopContext);

    // Get the current quantity of the item in the cart, default to 0 if not in cart yet
    const cartItemCount = cartItems[productId] || 0;



    return (
        <div className="cartItem">
            <img src={productImage} alt={`${productName}`} />
            <div className="description">
                <p>
                    <b>{productName}</b>
                </p>
                <p>
                    {price} €
                </p>
                <div className="countHandler">
                    <button onClick={() => removeFromCart(productId)}> - </button>
                    <input 
                        value={cartItemCount} 
                        onChange={(e) => updateCartItemCount(Number(e.target.value), productId)} 
                    />
                    <button 
                        onClick={() => addToCart(productId)} 
                        // disabled={cartItemCount >= quantity}
                    > 
                        + 
                    </button>
                </div>
                {cartItemCount > quantity && (
                    <p className="stockWarning">The selected amount is not available in stock</p>
                )}
            </div>
        </div>
    );
};

// import React, {useContext} from 'react'
// import { ShopContext } from "../../context/shop-context";
// import "./cart.css";

// export const CartItem = (props) => {

//     const {_id, productName, price, productImage, quantity} = props.data
//     const productId = _id.$oid; // Use _id.$oid to get the string ID

//     const{ cartItems, addToCart, removeFromCart,updateCartItemCount } = useContext(ShopContext);


//     return (
//         <div className="cartItem">
//             <img src={productImage}/>
//             <div className="description">
//                 <p>
//                     <b>{productName}</b>
//                 </p>
//                 <p>
//                     {price} €
//                 </p>
//                 <div className="countHandler">
//                     <button onClick={() => removeFromCart(productId)}> - </button>
//                     <input value={cartItems[productId]} onChange={(e) => updateCartItemCount(Number(e.target.value), productId) } />
//                     <button onClick={() => addToCart(productId)}> + </button>
//                 </div>
//             </div>
//         </div>
//     )
// }