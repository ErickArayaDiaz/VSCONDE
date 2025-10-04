// src/AppRouter.jsx
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import LoginForm from "./components/LoginForm.jsx";
import RegisterForm from "./components/RegisterForm.jsx";
import TaskList from "./components/TaskList.jsx";

export default function AppRouter() {
  const token = localStorage.getItem("token");

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginForm />} />
        <Route path="/register" element={<RegisterForm />} />
        <Route
          path="/tasks"
          element={token ? <TaskList /> : <Navigate to="/login" />}
        />
        <Route path="*" element={<Navigate to={token ? "/tasks" : "/login"} />} />
      </Routes>
    </BrowserRouter>
  );
}
