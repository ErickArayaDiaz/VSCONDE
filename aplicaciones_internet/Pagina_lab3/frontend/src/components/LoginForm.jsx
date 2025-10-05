// frontend/src/components/LoginForm.jsx
import { useState } from "react";
import { login } from "../services/authService.js";

export default function LoginForm({ onLogin, onShowRegister }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleLogin = async () => {
    if (!email || !password) {
      setError("Completa todos los campos");
      return;
    }

    try {
      const data = await login(email, password);
      localStorage.setItem("token", data.token);
      onLogin(data.user); // actualiza estado de usuario en App.jsx
    } catch (err) {
      setError(err.message || "Error al iniciar sesión");
    }
  };

  return (
    <div className="p-4 max-w-sm mx-auto border rounded shadow">
      <h2 className="text-xl font-bold mb-2">Iniciar sesión</h2>
      {error && <p className="text-red-500 mb-2">{error}</p>}
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        className="border p-2 mb-2 w-full"
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        className="border p-2 mb-2 w-full"
      />
      <button
        onClick={handleLogin}
        className="bg-blue-500 text-white px-3 py-1 rounded w-full mb-2"
      >
        Iniciar sesión
      </button>
      <button
        onClick={onShowRegister}
        className="bg-gray-300 text-black px-3 py-1 rounded w-full"
      >
        Registrarse
      </button>
    </div>
  );
}
