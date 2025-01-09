// import './App.css';
// import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
// import { Navbar } from "./components/navbar";
// import { Shop } from "./pages/shop/shop";
// import { Cart } from "./pages/cart/cart";
// import { MyProducts } from "./pages/myproducts/myproduct";
// import { OrderList } from './pages/orders/orderlist';
// import { ProductList } from './pages/products/productlist';
// import { ShopContextProvider } from './context/shop-context';
// import { ProductsProvider } from './context/products-context';
// import ProtectedRoute from './components/protected-route';

// function App() {
//   return (
//     <div className="App">
//       <ProductsProvider>
//         <ShopContextProvider>
//           <Router>
//             <Navbar />
//             <Routes>
//               {/* Public Route */}
//               <Route path="/" element={<Shop />} />

//               {/* Seller-Only Page */}
//               <Route
//                 path="/myproducts"
//                 element={
//                   <ProtectedRoute allowedRoles={["seller"]}>
//                     <MyProducts />
//                   </ProtectedRoute>
//                 }
//               />

//               {/* Customer-Only Pages */}
//               <Route
//                 path="/products"
//                 element={
//                   <ProtectedRoute allowedRoles={["customer", "undefined"]}>
//                     <ProductList />
//                   </ProtectedRoute>
//                 }
//               />
//               <Route
//                 path="/orders"
//                 element={
//                   <ProtectedRoute allowedRoles={["customer"]}>
//                     <OrderList />
//                   </ProtectedRoute>
//                 }
//               />
//               <Route
//                 path="/cart"
//                 element={
//                   <ProtectedRoute allowedRoles={["customer", "undefined"]}>
//                     <Cart />
//                   </ProtectedRoute>
//                 }
//               />
//             </Routes>
//           </Router>
//         </ShopContextProvider>
//       </ProductsProvider>
//     </div>
//   );
// }

// export default App;


import './App.css';
import { BrowserRouter as Router, Routes, Route, useNavigate } from 'react-router-dom';
import { useEffect } from 'react';
import { Navbar } from "./components/navbar";
import { Shop } from "./pages/shop/shop";
import { Cart } from "./pages/cart/cart";
import { MyProducts } from "./pages/myproducts/myproduct";
import { OrderList } from './pages/orders/orderlist';
import { ProductList } from './pages/products/productlist';
import { ShopContextProvider } from './context/shop-context';
import { ProductsProvider } from './context/products-context';
import ProtectedRoute from './components/protected-route';
import Cookies from 'js-cookie';

function App() {
  const CartRedirectHandler = () => {
    const navigate = useNavigate();

    useEffect(() => {
      const isLoggedIn = Boolean(localStorage.getItem("access_token"));
      const cartRedirect = Cookies.get("cart_redirect");

      if (isLoggedIn && cartRedirect) {
        Cookies.remove("cart_redirect"); // Remove the cookie after redirecting
        navigate("/cart"); // Redirect to cart page
      }
    }, [navigate]);

    return null; // This component doesn't render any UI, only handles redirection
  };

  return (
    <div className="App">
      <ProductsProvider>
        <ShopContextProvider>
          <Router>
            {/* Global Cart Redirect Handler */}
            <CartRedirectHandler />

            <Navbar />
            <Routes>
              {/* Public Route */}
              <Route path="/" element={<Shop />} />

              {/* Seller-Only Page */}
              <Route
                path="/myproducts"
                element={
                  <ProtectedRoute allowedRoles={["seller"]}>
                    <MyProducts />
                  </ProtectedRoute>
                }
              />

              {/* Customer-Only Pages */}
              <Route
                path="/products"
                element={
                  <ProtectedRoute allowedRoles={["customer","guest"]}>
                    <ProductList />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/orders"
                element={
                  <ProtectedRoute allowedRoles={["customer"]}>
                    <OrderList />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/cart"
                element={
                  <ProtectedRoute allowedRoles={["customer", "guest"]}>
                    <Cart />
                  </ProtectedRoute>
                }
              />
            </Routes>
          </Router>
        </ShopContextProvider>
      </ProductsProvider>
    </div>
  );
}

export default App;
