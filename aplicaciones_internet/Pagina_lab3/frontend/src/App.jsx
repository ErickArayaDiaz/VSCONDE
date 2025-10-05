// frontend/src/App.jsx
import { useState } from "react";
import { Routes, Route, useNavigate } from "react-router-dom";
import LoginForm from "./components/LoginForm";
import RegisterForm from "./components/RegisterForm";
import TaskList from "./components/TaskList";

function App() {
  const [token, setToken] = useState(null);
  const navigate = useNavigate();

  const handleLogin = (token) => {
    setToken(token);
    navigate("/tasks"); // redirige a la lista de tareas tras login
  };

  return (
    <Routes>
      <Route path="/" element={<LoginForm onLogin={handleLogin} />} />
      <Route path="/register" element={<RegisterForm />} />
      <Route path="/tasks" element={<TaskList token={token} />} />
    </Routes>
  );
}

export default App;
