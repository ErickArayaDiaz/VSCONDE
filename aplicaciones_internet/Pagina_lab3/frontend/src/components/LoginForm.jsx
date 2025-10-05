// frontend/src/components/LoginForm.jsx
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { login } from "../services/authService.js";

export default function LoginForm({ onLogin }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const navigate = useNavigate();

  const handleLogin = async () => {
    try {
      const data = await login(email, password);
      localStorage.setItem("token", data.token);
      onLogin(data.user);
      navigate("/"); // redirige al TaskBoard
    } catch (err) {
      alert(err.message || "Error al iniciar sesión");
    }
  };

  return (
    <div className="p-4">
      <h2 className="text-xl font-bold mb-4 text-center">Iniciar sesión</h2>
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={e => setEmail(e.target.value)}
        className="border p-2 mb-2 w-full rounded"
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={e => setPassword(e.target.value)}
        className="border p-2 mb-2 w-full rounded"
      />
      <button
        onClick={handleLogin}
        className="bg-blue-500 text-white px-3 py-2 rounded w-full mb-2"
      >
        Iniciar sesión
      </button>
      <button
        onClick={() => navigate("/register")}
        className="bg-green-500 text-white px-3 py-2 rounded w-full"
      >
        Registrarse
      </button>
    </div>
  );
}
