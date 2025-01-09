import React from "react";
import { Navigate } from "react-router-dom";

const ProtectedRoute = ({ children, allowedRoles }) => {
  const token = localStorage.getItem("access_token");
  const userRole = localStorage.getItem("user_role") || "guest";

  // Redirect to login if not logged in
//   if (!token) {
//     return <Navigate to="/" replace />;
//   }

  // Redirect to home if user does not have the correct role
  if (!allowedRoles.includes(userRole)) {
    return <Navigate to="/" replace />;
  }

  return children; // Render the protected page if role matches
};

export default ProtectedRoute;
