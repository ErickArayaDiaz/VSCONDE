// frontend/src/components/TaskBoard.jsx
import { useEffect, useState } from "react";
import { getTasks, createTask, updateTask, deleteTask } from "../services/taskService.js";

export default function TaskBoard({ user, onLogout }) {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [loading, setLoading] = useState(false);

  const token = localStorage.getItem("token");

  // Obtener tareas al cargar
  const fetchTasks = async () => {
    if (!token) return;
    setLoading(true);
    try {
      const data = await getTasks(token);
      setTasks(data);
    } catch (err) {
      console.error(err);
      alert("Error al obtener tareas");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTasks();
  }, [token]);

  const handleCreate = async () => {
    if (!title) return alert("Ingrese un título");
    try {
      const newTask = await createTask(token, { title, description });
      setTasks([...tasks, newTask]);
      setTitle("");
      setDescription("");
    } catch (err) {
      console.error(err);
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

  const countTasks = (completed) => tasks.filter(t => t.completed === completed).length;

  if (loading) return <p>Cargando tareas...</p>;

  return (
    <div className="max-w-3xl mx-auto p-4 bg-white rounded shadow">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold">Dashboard de Tareas</h2>
        <button onClick={onLogout} className="bg-red-500 text-white px-3 py-1 rounded">
          Logout
        </button>
      </div>

      {/* Crear tarea */}
      <div className="flex gap-2 mb-4">
        <input
          placeholder="Título"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="border p-2 w-full rounded"
        />
        <input
          placeholder="Descripción"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="border p-2 w-full rounded"
        />
        <button onClick={handleCreate} className="bg-blue-500 text-white px-3 py-1 rounded">
          Agregar
        </button>
      </div>

      {/* Contadores */}
      <div className="flex gap-4 mb-4">
        <div className="bg-gray-200 p-2 rounded w-1/3 text-center">Sin iniciar: {countTasks(false)}</div>
        <div className="bg-yellow-200 p-2 rounded w-1/3 text-center">Completadas: {countTasks(true)}</div>
      </div>

      {/* Lista de tareas */}
      <ul>
        {tasks.map(task => (
          <li key={task.id} className="flex items-center justify-between border p-2 mb-2 rounded">
            <div>
              <input type="checkbox" checked={task.completed} onChange={() => handleToggle(task)} />
              <span className={`ml-2 ${task.completed ? "line-through text-gray-400" : ""}`}>
                {task.title} {task.description && `- ${task.description}`}
              </span>
            </div>
            <button onClick={() => handleDelete(task.id)} className="bg-red-500 text-white px-2 py-1 rounded">
              Eliminar
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
