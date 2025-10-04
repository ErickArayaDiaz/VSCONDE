// src/components/TaskList.jsx
import { useEffect, useState } from "react";
import { getTasks, createTask, updateTask, deleteTask } from "../services/taskService";

export default function TaskList() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [loading, setLoading] = useState(false);

  const token = localStorage.getItem("token");

  const fetchTasks = async () => {
    setLoading(true);
    try {
      const data = await getTasks(token);
      setTasks(data);
    } catch (err) {
      alert("Error al obtener tareas");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (token) fetchTasks();
  }, [token]);

  const handleCreate = async () => {
    if (!title) return alert("Ingrese un título");
    try {
      const newTask = await createTask(token, { title, description });
      setTasks([...tasks, newTask]);
      setTitle("");
      setDescription("");
    } catch (err) {
      alert("Error al crear tarea");
    }
  };

  const handleToggle = async (task) => {
    try {
      const updated = await updateTask(token, task.id, { completed: !task.completed });
      setTasks(tasks.map(t => t.id === task.id ? updated : t));
    } catch {
      alert("Error al actualizar tarea");
    }
  };

  const handleDelete = async (id) => {
    try {
      await deleteTask(token, id);
      setTasks(tasks.filter(t => t.id !== id));
    } catch {
      alert("Error al eliminar tarea");
    }
  };

  if (loading) return <p>Cargando tareas...</p>;

  return (
    <div className="p-4 max-w-md mx-auto">
      <h2 className="text-xl font-bold mb-2">Tareas</h2>
      <input
        placeholder="Título"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        className="border p-2 mb-2 mr-2 w-full"
      />
      <input
        placeholder="Descripción"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        className="border p-2 mb-2 mr-2 w-full"
      />
      <button onClick={handleCreate} className="bg-blue-500 text-white p-2 mb-4 w-full">
        Agregar
      </button>

      <ul>
        {tasks.map(task => (
          <li key={task.id} className="flex items-center justify-between border p-2 mb-2">
            <div>
              <input type="checkbox" checked={task.completed} onChange={() => handleToggle(task)} />
              <span className={`ml-2 ${task.completed ? "line-through" : ""}`}>
                {task.title}: {task.description}
              </span>
            </div>
            <button onClick={() => handleDelete(task.id)} className="bg-red-500 text-white p-1">
              Eliminar
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
