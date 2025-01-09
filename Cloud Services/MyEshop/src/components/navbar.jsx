// import React, { useState, useEffect } from 'react';
// import { Link } from 'react-router-dom';
// import { House, ShoppingCart } from 'phosphor-react';
// import './navbar.css';

// export const Navbar = () => {
//   const [isNavbarVisible, setNavbarVisible] = useState(true);
//   const [lastScrollY, setLastScrollY] = useState(0);

//   // Scroll behavior for navbar
//   useEffect(() => {
//     const handleScroll = () => {
//       if (window.scrollY > lastScrollY) {
//         // Scrolling down
//         setNavbarVisible(false);
//       } else {
//         // Scrolling up
//         setNavbarVisible(true);
//       }
//       setLastScrollY(window.scrollY);
//     };

//     window.addEventListener('scroll', handleScroll);

//     return () => {
//       window.removeEventListener('scroll', handleScroll);
//     };
//   }, [lastScrollY]);

//   return (
//     <div className={`navbar ${isNavbarVisible ? '' : 'hidden'}`}>
//       <div className="links">
//         <Link to="/">
//           <House size={32} />
//         </Link>
//         <Link to="/myproducts">My Products</Link>
//         <Link to="/products">Products</Link>
//         <Link to="/orders">Orders</Link>
//         <Link to="/cart">
//           <ShoppingCart size={32} />
//         </Link>
//       </div>
//     </div>
//   );
// };
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { House, ShoppingCart } from 'phosphor-react';
import './navbar.css';

export const Navbar = () => {
  const [isNavbarVisible, setNavbarVisible] = useState(true);
  const [lastScrollY, setLastScrollY] = useState(0);

  const role = localStorage.getItem("user_role");
  const isLoggedIn = Boolean(localStorage.getItem("access_token"));

  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > lastScrollY) {
        setNavbarVisible(false);
      } else {
        setNavbarVisible(true);
      }
      setLastScrollY(window.scrollY);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [lastScrollY]);

  return (
    <div className={`navbar ${isNavbarVisible ? '' : 'hidden'}`}>
      <div className="links">
        <Link to="/">
          <House size={32} />
        </Link>
        {isLoggedIn && role === "seller" && (
          <Link to="/myproducts">My Products</Link>
        )}
        {isLoggedIn && role === "customer" && (
          <>
            <Link to="/products">Products</Link>
            <Link to="/orders">Orders</Link>
            <Link to="/cart">
              <ShoppingCart size={32} />
            </Link>
          </>
        )}
        {!isLoggedIn && (
          <>
            <Link to="/products">Products</Link>
            <Link to="/cart">
              <ShoppingCart size={32} />
            </Link>
            </>)}
      </div>
    </div>
  );
};
