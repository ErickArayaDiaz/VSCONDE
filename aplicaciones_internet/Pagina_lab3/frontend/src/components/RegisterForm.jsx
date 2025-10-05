// frontend/src/components/RegisterForm.jsx
import { useState } from "react";
import { register } from "../services/authService.js";

export default function RegisterForm({ onRegister }) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleRegister = async () => {
    if (!name || !email || !password) {
      setError("Completa todos los campos");
      return;
    }

    try {
      const data = await register(name, email, password);
      localStorage.setItem("token", data.token);
      onRegister(data.user); // actualiza estado de usuario en App.jsx
    } catch (err) {
      setError(err.message || "Error al registrar usuario");
    }
  };

  return (
    <div className="p-4 max-w-sm mx-auto border rounded shadow">
      <h2 className="text-xl font-bold mb-2">Registrar usuario</h2>
      {error && <p className="text-red-500 mb-2">{error}</p>}
      <input
        type="text"
        placeholder="Nombre"
        value={name}
        onChange={(e) => setName(e.target.value)}
        className="border p-2 mb-2 w-full"
      />
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
        onClick={handleRegister}
        className="bg-green-500 text-white px-3 py-1 rounded w-full"
      >
        Registrar
      </button>
    </div>
  );
}
