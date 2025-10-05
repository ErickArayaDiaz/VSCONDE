// frontend/src/App.jsx
import { useState, useEffect } from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import LoginForm from "./components/LoginForm.jsx";
import RegisterForm from "./components/RegisterForm.jsx";
import TaskList from "./components/TaskList.jsx";

export default function App() {
  const [user, setUser] = useState(null);

  // Mantener sesión al recargar
  useEffect(() => {
    const token = localStorage.getItem("token");
    if (token) {
      fetch("http://localhost:4000/api/auth/me", {
        headers: { Authorization: `Bearer ${token}` },
      })
        .then(res => res.json())
        .then(data => {
          if (data.user) setUser(data.user);
          else localStorage.removeItem("token");
        })
        .catch(() => localStorage.removeItem("token"));
    }
  }, []);

  const handleLogin = (userData) => setUser(userData);
  const handleRegister = (userData) => setUser(userData);

  const handleLogout = () => {
    localStorage.removeItem("token");
    setUser(null);
  };

  const PrivateRoute = ({ children }) => (user ? children : <Navigate to="/login" />);

  return (
    <div className="min-h-screen p-4 bg-gray-100">
      {/* Botón de logout visible solo si hay usuario */}
      {user && (
        <div className="flex justify-end mb-4">
          <button
            onClick={handleLogout}
            className="bg-red-500 text-white px-3 py-1 rounded"
          >
            Logout
          </button>
        </div>
      )}

      <Routes>
        {/* Ruta protegida */}
        <Route path="/" element={<PrivateRoute><TaskList /></PrivateRoute>} />

        {/* Rutas públicas */}
        {!user && <Route path="/login" element={<LoginForm onLogin={handleLogin} />} />}
        {!user && <Route path="/register" element={<RegisterForm onRegister={handleRegister} />} />}

        {/* Redirige todo lo demás a "/" */}
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </div>
  );
}
