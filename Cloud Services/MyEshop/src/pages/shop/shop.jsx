// import React, { useState, useEffect } from 'react';

// // Decode JWT Token Function
// function decodeJwt(jwtToken) {
//   try {
//     const base64Url = jwtToken.split('.')[1]; // Get the payload part of the JWT
//     const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/'); // Replace Base64 URL encoding characters
//     const jsonPayload = decodeURIComponent(
//       atob(base64)
//         .split('')
//         .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
//         .join('')
//     ); // Decode Base64 and handle URI component encoding

//     return JSON.parse(jsonPayload);
//   } catch (error) {
//     console.error('Failed to decode JWT token:', error);
//     return null;
//   }
// }

// async function Register(e) {
//   e.preventDefault(); // Prevent page reload on form submission

//   const getUsername = document.getElementById("register-username").value;
//   const getEmail = document.getElementById("register-email").value;
//   const getPassword = document.getElementById("register-password").value;
//   const getRole = document.getElementById("select-role").value;

//   try {
//     // Prepare registration payload
//     const userPayload = {
//       username: getUsername,
//       email: getEmail,
//       enabled: true,
//       credentials: [
//         {
//           type: "password",
//           value: getPassword,
//           temporary: false,
//         },
//       ],
//       attributes: {
//         role: getRole, // Optional, to store role as an attribute
//       },
//     };

//     // Call Keycloak Admin REST API to register the user
//     const response = await fetch(
//       "http://localhost:8182/auth/admin/realms/eshop/users",
//       {
//         method: "POST",
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: JSON.stringify(userPayload),
//       }
//     );

//     if (response.ok) {
//       alert("User registered successfully!");
//     } else {
//       const error = await response.json();
//       console.error("Registration failed:", error);
//       alert(`Registration failed: ${error.error_description}`);
//     }
//   } catch (error) {
//     console.error("Error during registration:", error);
//     alert("An error occurred during registration.");
//   }
// }



// async function login(e) {
//   e.preventDefault(); // Prevent page reload

//   const getUsernameLogin = document.getElementById("username").value;
//   const getPasswordLogin = document.getElementById("password").value;

//   try {
//     const myHeaders = new Headers();
//     myHeaders.append("Content-Type", "application/x-www-form-urlencoded");

//     const urlencoded = new URLSearchParams();
//     urlencoded.append("username", getUsernameLogin);
//     urlencoded.append("password", getPasswordLogin);
//     urlencoded.append("client_id", "frontend-client");
//     urlencoded.append("client_secret", "nqgBB0VQsfbyVrTP6lZlCzIquDrL3EZK");
//     urlencoded.append("grant_type", "password");

//     const response = await fetch(
//       "http://localhost:8182/realms/eshop/protocol/openid-connect/token",
//       {
//         method: "POST",
//         headers: myHeaders,
//         body: urlencoded,
//         redirect: "follow",
//       }
//     );
    
//     if (response.ok) {
//       const tokens = await response.json();
//       console.log("Access Token:", tokens.access_token);

//       // Decode the access token to get user information
//       const decodedToken = decodeJwt(tokens.access_token);

//       if (decodedToken) {
//         // Store user information in localStorage
//         localStorage.setItem("access_token", tokens.access_token);
//         localStorage.setItem("username", decodedToken.preferred_username);
//         alert("Login successful!");
//       }
//     } else {
//       const error = await response.json();
//       console.error("Login failed:", error);
//       alert("Failed to login. Please check your username and password.");
//     }
//   } catch (error) {
//     console.error("Error during login:", error);
//     alert("An error occurred. Please try again.");
//   }
// }

// // // Shop Component
// // export const Shop = () => {
// //   const [isLoginVisible, setIsLoginVisible] = useState(true);

// //   useEffect(() => {
// //     // Handle redirect and extract authorization code
// //     const urlParams = new URLSearchParams(window.location.search);
// //     const code = urlParams.get("code");

// //     if (code) {
// //       exchangeCodeForToken(code);
// //     }
// //   }, []);

// //   return (
// //     <div className="shop">
// //       <h1>Bouzouki Place</h1>

// //       {/* Toggle Login and Register */}
// //       <div>
// //         <button
// //           onClick={() => setIsLoginVisible(true)}
// //           style={{ fontWeight: isLoginVisible ? "bold" : "normal" }}
// //         >
// //           Login
// //         </button>
// //         <button
// //           onClick={() => setIsLoginVisible(false)}
// //           style={{ fontWeight: !isLoginVisible ? "bold" : "normal" }}
// //         >
// //           Register
// //         </button>
// //       </div>

// //       {/* Conditional Rendering */}
// //       {isLoginVisible ? (
// //         <form onSubmit={(e) => { e.preventDefault(); redirectToLogin(); }}>
// //           <h2>Login</h2>
// //           <label>Username:</label>
// //           <input id="username" type="text" required />
// //           <label>Password:</label>
// //           <input id="password" type="password" required />
// //           <button type="submit">Login</button>
// //         </form>
// //       ) : (
// //         <form onSubmit={Register}>
// //           <h2>Register</h2>
// //           <label>Username:</label>
// //           <input id="register-username" type="text" required />
// //           <label>Email:</label>
// //           <input id="register-email" type="email" required />
// //           <label>Password:</label>
// //           <input id="register-password" type="password" required />
// //           <label>Role:</label>
// //           <select id="select-role" required>
// //             <option value="customer">Customer</option>
// //             <option value="seller">Seller</option>
// //           </select>
// //           <button type="submit">Register</button>
// //         </form>
// //       )}
// //     </div>
// //   );
// // };
// export const Shop = () => {
//   const [isLoginVisible, setIsLoginVisible] = useState(true);

//   return (
//     <div className="shop">
//       <h1>Bouzouki Place</h1>

//       {/* Toggle Login and Register */}
//       <div>
//         <button
//           onClick={() => setIsLoginVisible(true)}
//           style={{ fontWeight: isLoginVisible ? "bold" : "normal" }}
//         >
//           Login
//         </button>
//         <button
//           onClick={() => setIsLoginVisible(false)}
//           style={{ fontWeight: !isLoginVisible ? "bold" : "normal" }}
//         >
//           Register
//         </button>
//       </div>

//       {/* Conditional Rendering */}
//       {isLoginVisible ? (
//         <form onSubmit={login}>
//           <h2>Login</h2>
//           <label>Username:</label>
//           <input id="username" type="text" required />
//           <label>Password:</label>
//           <input id="password" type="password" required />
//           <button type="submit">Login</button>
//         </form>
//       ) : (
//         <form onSubmit={Register}>
//           <h2>Register</h2>
//           <label>Username:</label>
//           <input id="register-username" type="text" required />
//           <label>Email:</label>
//           <input id="register-email" type="email" required />
//           <label>Password:</label>
//           <input id="register-password" type="password" required />
//           <label>Role:</label>
//           <select id="select-role" required>
//             <option value="customer">Customer</option>
//             <option value="seller">Seller</option>
//           </select>
//           <button type="submit">Register</button>
//         </form>
//       )}
//     </div>
//   );
// };


import React, { useState, useEffect } from 'react';

const kUrl = import.meta.env.VITE_KEYCLOAK_URL;
function decodeJwt(jwtToken) {
  const base64Url = jwtToken.split(".")[1]; // Get the payload part of the JWT
  const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/"); // Replace Base64 URL encoding characters
  const jsonPayload = decodeURIComponent(
    atob(base64)
      .split("")
      .map(function (c) {
        return "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2);
      })
      .join("")
  ); // Decode Base64 and handle URI component encoding
  return JSON.parse(jsonPayload);
}


// Helper function to clear form fields
function clearFields(fields) {
  fields.forEach((field) => {
    document.getElementById(field).value = "";
  });
}

// Login Function
async function login(e) {
  e.preventDefault();

  const getUsernameLogin = document.getElementById("username").value;
  const getPasswordLogin = document.getElementById("password").value;

  try {
    const myHeaders = new Headers();
    myHeaders.append("Content-Type", "application/x-www-form-urlencoded");

    const urlencoded = new URLSearchParams();
    urlencoded.append("username", getUsernameLogin);
    urlencoded.append("password", getPasswordLogin);
    urlencoded.append("client_id", "frontend-client");
    urlencoded.append("client_secret", "C251cBVLQgyRfjch6Rt5e4JE97vWtTvv");
    urlencoded.append("grant_type", "password");

    const response = await fetch(
      `${kUrl}/realms/eshop/protocol/openid-connect/token`,
      {
        method: "POST",
        headers: myHeaders,
        body: urlencoded,
        redirect: "follow",
      }
    );

    if (response.ok) {
      const tokens = await response.json();
      const tok = response.data;

      
      // Decode the access token to get user information
      const decodedToken = decodeJwt(tokens.access_token);
      console.log(decodedToken);      
      if (decodedToken) {
        const role = decodedToken.user_role;
	console.log(role);
        // Store user information in localStorage
        localStorage.setItem("access_token", tokens.access_token);
        localStorage.setItem("refresh_token", tokens.refresh_token); 
        localStorage.setItem("user_role", role);
        localStorage.setItem("username", decodedToken.preferred_username);
        clearFields(["username", "password"]); // Clear fields after login
        
        // Refresh the page
        window.location.reload();
      }
    } else {
      const error = await response.json();
      console.error("Login failed:", error);
      alert("Failed to login. Please check your username and password.");
    }
  } catch (error) {
    console.error("Error during login:", error);
    alert("An error occurred. Please try again.");
  }
}


async function Register(e) {
  e.preventDefault();

  const getUsername = document.getElementById("register-username").value;
  const getPassword = document.getElementById("register-password").value;
  const getConfirmPassword = document.getElementById("register-password-confirmation").value;
  const getEmail = document.getElementById("register-email").value;
  const getFirstName = document.getElementById("register-firstname").value;
  const getLastName = document.getElementById("register-lastname").value;
  const getRole = document.getElementById("select-role").value;

  if (getPassword !== getConfirmPassword) {
    alert("Passwords do not match!");
    return;
  }

  try {
    const adminTokenResponse = await fetch(
      `${kUrl}/realms/master/protocol/openid-connect/token`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
          grant_type: "client_credentials",
          client_id: "admin-cli",
          client_secret: "SwwxH1L5ZZd1JUe77UnDpyYuFOyWEIp3",
        }),
      }
    );

    const tokenData = await adminTokenResponse.json();
    if (!adminTokenResponse.ok) {
      throw new Error(tokenData.error_description || "Failed to fetch admin token");
    }

    const adminToken = tokenData.access_token;

    await fetch(`${kUrl}/admin/realms/eshop/users`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${adminToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        username: getUsername,
        email: getEmail,
        enabled: true,
        firstName: getFirstName,
        lastName: getLastName,
        credentials: [
          {
            type: "password",
            value: getPassword,
            temporary: false,
          },
        ],
        attributes: {
          user_role: getRole,
        },
      }),
    });

    console.log("User registered successfully!");

    // Log in the user after registration role
    try {
      const myHeaders = new Headers();
      myHeaders.append("Content-Type", "application/x-www-form-urlencoded");

      const urlencoded = new URLSearchParams();
      urlencoded.append("username", getUsername);
      urlencoded.append("password", getPassword);
      urlencoded.append("client_id", "frontend-client");
      urlencoded.append("client_secret", "C251cBVLQgyRfjch6Rt5e4JE97vWtTvv");
      urlencoded.append("grant_type", "password");

      const loginResponse = await fetch(
        `${kUrl}/realms/eshop/protocol/openid-connect/token`,
        {
          method: "POST",
          headers: myHeaders,
          body: urlencoded,
          redirect: "follow",
        }
      );

      if (loginResponse.ok) {
        const tokens = await loginResponse.json();

        const decodedToken = decodeJwt(tokens.access_token);
	console.log(decodedToken);
        if (decodedToken) {

          const role = decodedToken.user_role;
      	  console.log(role);

          localStorage.setItem("access_token", tokens.access_token);
          localStorage.setItem("username", decodedToken.preferred_username);
          localStorage.setItem("refresh_token", tokens.refresh_token); 
          localStorage.setItem("user_role", role);
          

          clearFields([
            "register-username",
            "register-password",
            "register-password-confirmation",
            "register-email",
            "register-firstname",
            "register-lastname",
            "select-role",
          ]);

          // Refresh the page after login
          window.location.reload();
        }
      } else {
        const error = await loginResponse.json();
        console.error("Login failed:", error);
      }
    } catch (loginError) {
      console.error("Error during fallback login attempt:", loginError);
    }
  } catch (error) {
    console.error("Error during registration:", error);

    // Log the error for debugging but continue executing
    if (error.message && error.message.includes("CORS")) {
      console.warn("CORS error occurred. Continuing with the next steps.");
    }

    // Attempt fallback login even after error
    try {
      const myHeaders = new Headers();
      myHeaders.append("Content-Type", "application/x-www-form-urlencoded");

      const urlencoded = new URLSearchParams();
      urlencoded.append("username", getUsername);
      urlencoded.append("password", getPassword);
      urlencoded.append("client_id", "frontend-client");
      urlencoded.append("client_secret", "C251cBVLQgyRfjch6Rt5e4JE97vWtTvv");
      urlencoded.append("grant_type", "password");

      const loginResponse = await fetch(
        `${kUrl}/realms/eshop/protocol/openid-connect/token`,
        {
          method: "POST",
          headers: myHeaders,
          body: urlencoded,
          redirect: "follow",
        }
      );

      if (loginResponse.ok) {
        const tokens = await loginResponse.json();
        console.log("Access Token:", tokens.access_token);

        const decodedToken = decodeJwt(tokens.access_token);

        if (decodedToken) {
          const role = decodedToken.user_role;
          localStorage.setItem("access_token", tokens.access_token);
          localStorage.setItem("username", decodedToken.preferred_username);
          localStorage.setItem("user_role", role);

          clearFields([
            "register-username",
            "register-password",
            "register-password-confirmation",
            "register-email",
            "register-firstname",
            "register-lastname",
            "select-role",
          ]);

          // Refresh the page after login
          window.location.reload();
        }
      } else {
        const error = await loginResponse.json();
        console.error("Login failed after fallback:", error);
      }
    } catch (fallbackError) {
      console.error("Error during fallback login attempt:", fallbackError);
    }
  }
}




// Logout Function
async function logout() {
  try {
    // Get the refresh token from localStorage
    const refreshToken = localStorage.getItem("refresh_token");

    if (!refreshToken) {
      console.warn("No refresh token found. Clearing local data.");
      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      localStorage.removeItem("username");
      localStorage.removeItem("user_role");
      window.location.reload();
      return;
    }

    // Send the logout request
    const response = await fetch(
      `${kUrl}/realms/eshop/protocol/openid-connect/logout`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
          client_id: "frontend-client", // Replace with your client ID
          client_secret: "C251cBVLQgyRfjch6Rt5e4JE97vWtTvv", // Replace with your client secret
          refresh_token: refreshToken, // Use the refresh token for logout
        }),
      }
    );

    if (response.ok) {
      console.log("Logout successful.");
    } else {
      const error = await response.json();
      console.error("Failed to log out:", error);
    }
  } catch (error) {
    console.error("Error during logout:", error);
  } finally {
    // Clear local storage
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("username");
    localStorage.removeItem("user_role");
    alert("You have been logged out.");
    window.location.reload();
  }
}




// Shop Component
export const Shop = () => {
  const [isLoginVisible, setIsLoginVisible] = useState(true);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [username, setUsername] = useState("");

  useEffect(() => {
    // Check if the user is logged in
    const storedUsername = localStorage.getItem("username");
    if (storedUsername) {
      setIsLoggedIn(true);
      setUsername(storedUsername);
    }
  }, []);

  return (
    <div className="shop">
      <h1>Bouzouki Place</h1>

      {isLoggedIn ? (
        <>
          <h2>Welcome, {username}!</h2>
          <button onClick={logout}>Logout</button>
        </>
      ) : (
        <>
          {/* Toggle Login and Register */}
          <div>
            <button
              onClick={() => setIsLoginVisible(true)}
              style={{ fontWeight: isLoginVisible ? "bold" : "normal" }}
            >
              Login
            </button>
            <button
              onClick={() => setIsLoginVisible(false)}
              style={{ fontWeight: !isLoginVisible ? "bold" : "normal" }}
            >
              Register
            </button>
          </div>

          {/* Conditional Rendering */}
          {isLoginVisible ? (
            <form onSubmit={login}>
              <h2>Login</h2>
              <label>Username:</label>
              <input id="username" type="text" required />
              <label>Password:</label>
              <input id="password" type="password" required />
              <button type="submit">Login</button>
            </form>
          ) : (
            <form onSubmit={Register}>
              <h2>Register</h2>
              
              <label htmlFor="register-username">Username:</label>
              <input id="register-username" type="text" placeholder="Enter your username" required />

              <label htmlFor="register-password">Password:</label>
              <input id="register-password" type="password" placeholder="Enter your password" required />

              <label htmlFor="register-password-confirmation">Confirm Password:</label>
              <input id="register-password-confirmation" type="password" placeholder="Confirm your password" required />

              <label htmlFor="register-email">Email:</label>
              <input id="register-email" type="email" placeholder="Enter your email" required />

              <label htmlFor="register-firstname">First Name:</label>
              <input id="register-firstname" type="text" placeholder="Enter your first name" required />

              <label htmlFor="register-lastname">Last Name:</label>
              <input id="register-lastname" type="text" placeholder="Enter your last name" required />

              <label htmlFor="select-role">Role:</label>
              <select id="select-role" required>
                <option value="">Select your role</option>
                <option value="customer">Customer</option>
                <option value="seller">Seller</option>
              </select>

              <button type="submit">Register</button>
            </form>



          )}
        </>
      )}
    </div>
  );
};

