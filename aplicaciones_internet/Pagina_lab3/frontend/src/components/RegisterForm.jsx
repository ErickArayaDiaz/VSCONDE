// frontend/src/components/RegisterForm.jsx
import { useState } from "react";
import { register } from "../services/authService.js";

export default function RegisterForm({ onRegister }) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleRegister = async () => {
    if (!name || !email || !password) return alert("Completa todos los campos");

    try {
      const data = await register(name, email, password);
      localStorage.setItem("token", data.token);
      onRegister(data.user);
    } catch (err) {
      alert(err.message || "Error al registrar usuario");
    }
  };

  return (
    <div className="p-4 max-w-sm mx-auto border rounded shadow">
      <h2 className="text-xl font-bold mb-2">Registrar usuario</h2>
      <input type="text" placeholder="Nombre" value={name} onChange={e => setName(e.target.value)} className="border p-1 mb-2 w-full" />
      <input type="email" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} className="border p-1 mb-2 w-full" />
      <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} className="border p-1 mb-2 w-full" />
      <button onClick={handleRegister} className="bg-green-500 text-white px-3 py-1 rounded w-full">Registrar</button>
    </div>
  );
}
