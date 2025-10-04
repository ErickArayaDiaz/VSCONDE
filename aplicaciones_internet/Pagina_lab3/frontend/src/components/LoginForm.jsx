// frontend/src/components/LoginForm.jsx
import { useState } from "react";
import { login } from "../services/authService.js";

export default function LoginForm({ onLogin }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = async () => {
    try {
      const data = await login(email, password);
      localStorage.setItem("token", data.token);
      onLogin(data.user);
    } catch (err) {
      alert(err.message || "Error al iniciar sesión");
    }
  };

  return (
    <div className="p-4 max-w-sm mx-auto border rounded shadow">
      <h2 className="text-xl font-bold mb-2">Iniciar sesión</h2>
      <input type="email" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} className="border p-1 mb-2 w-full" />
      <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} className="border p-1 mb-2 w-full" />
      <button onClick={handleLogin} className="bg-blue-500 text-white px-3 py-1 rounded w-full">Iniciar sesión</button>
    </div>
  );
}
