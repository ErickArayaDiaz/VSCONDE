import { useState, useEffect } from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import LoginForm from "./components/LoginForm.jsx";
import RegisterForm from "./components/RegisterForm.jsx";
import TaskList from "./components/TaskList.jsx";

export default function App() {
  const [user, setUser] = useState(null);
  const [loadingUser, setLoadingUser] = useState(true);

  // Mantener sesión al recargar
  useEffect(() => {
    const token = localStorage.getItem("token");
    if (!token) {
      setLoadingUser(false);
      return;
    }

    fetch("http://localhost:4000/api/auth/me", {
      headers: { Authorization: `Bearer ${token}` },
    })
      .then(res => res.json())
      .then(data => {
        if (data.user) setUser(data.user);
        else localStorage.removeItem("token");
      })
      .catch(() => localStorage.removeItem("token"))
      .finally(() => setLoadingUser(false));
  }, []);

  const handleLogin = (userData) => setUser(userData);
  const handleLogout = () => {
    setUser(null);
    localStorage.removeItem("token");
  };

  const PrivateRoute = ({ children }) => {
    if (loadingUser) return <p>Cargando...</p>;
    return user ? children : <Navigate to="/login" />;
  };

  return (
    <div className="min-h-screen bg-gray-100 p-4">
      <header className="max-w-md mx-auto flex justify-between items-center mb-4">
        <h1 className="text-2xl font-bold">Mi App de Tareas</h1>
        {user && (
          <button
            onClick={handleLogout}
            className="bg-red-500 text-white px-3 py-1 rounded"
          >
            Logout
          </button>
        )}
      </header>

      <Routes>
        <Route
          path="/"
          element={
            <PrivateRoute>
              <TaskList />
            </PrivateRoute>
          }
        />

        {!user && (
          <>
            <Route path="/login" element={<LoginForm onLogin={handleLogin} />} />
            <Route path="/register" element={<RegisterForm onRegister={handleLogin} />} />
          </>
        )}

        <Route path="*" element={<Navigate to={user ? "/" : "/login"} />} />
      </Routes>
    </div>
  );
}
