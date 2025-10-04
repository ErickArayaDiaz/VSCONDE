// src/components/TaskList.jsx
import { useEffect, useState } from "react";
import { getTasks } from "../services/taskService.js"; // lo crearemos en el siguiente paso

export default function TaskList() {
  const [tasks, setTasks] = useState([]);
  const token = localStorage.getItem("token"); // token guardado tras login

  useEffect(() => {
    if (token) {
      getTasks(token).then(setTasks);
    }
  }, [token]);

  return (
    <div>
      <h2>Mis tareas</h2>
      <ul>
        {tasks.map((task) => (
          <li key={task.id}>
            {task.title} - {task.completed ? "✅" : "❌"}
          </li>
        ))}
      </ul>
    </div>
  );
}
