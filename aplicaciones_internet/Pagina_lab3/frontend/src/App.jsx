// src/App.jsx
import { useState } from "react";
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import RegisterForm from "./components/RegisterForm.jsx";
import LoginForm from "./components/LoginForm.jsx";
import TaskList from "./components/TaskList.jsx";

export default function App() {
  const [user, setUser] = useState(null);

  // Guardar usuario tras login/registro
  const handleLogin = (userData) => setUser(userData);
  const handleLogout = () => {
    setUser(null);
    localStorage.removeItem("token");
  };

  // Componente para rutas privadas
  const PrivateRoute = ({ children }) => {
    return user ? children : <Navigate to="/login" />;
  };

  return (
    <Router>
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

          <Route
            path="/login"
            element={<LoginForm onLogin={handleLogin} />}
          />

          <Route
            path="/register"
            element={<RegisterForm onRegister={handleLogin} />}
          />

          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </div>
    </Router>
  );
}
