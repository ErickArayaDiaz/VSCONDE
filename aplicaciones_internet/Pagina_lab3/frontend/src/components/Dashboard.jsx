import { useEffect, useState } from "react";
import { getTasks, updateTask, deleteTask, createTask } from "../services/taskService.js";

export default function Dashboard({ user, onLogout }) {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [loading, setLoading] = useState(false);

  const token = localStorage.getItem("token");

  // Traer tareas
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

  // Crear tarea
  const handleCreate = async () => {
    if (!title) return alert("Ingrese un título");
    try {
      const newTask = await createTask(token, { title, description });
      setTasks([...tasks, newTask]);
      setTitle("");
      setDescription("");
    } catch {
      alert("Error al crear tarea");
    }
  };

  // Cambiar estado
  const handleToggle = async (task, newStatus) => {
    try {
      const updated = await updateTask(token, task.id, { completed: newStatus === "done" });
      setTasks(tasks.map(t => t.id === task.id ? updated : t));
    } catch {
      alert("Error al actualizar tarea");
    }
  };

  // Eliminar
  const handleDelete = async (id) => {
    try {
      await deleteTask(token, id);
      setTasks(tasks.filter(t => t.id !== id));
    } catch {
      alert("Error al eliminar tarea");
    }
  };

  // Filtrar tareas por estado
  const todoTasks = tasks.filter(t => !t.completed);
  const doneTasks = tasks.filter(t => t.completed);

  return (
    <div className="p-4">
      {/* Header con Logout */}
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-2xl font-bold">Hola, {user.name}</h1>
        <button
          onClick={onLogout}
          className="bg-red-500 text-white px-3 py-1 rounded"
        >
          Logout
        </button>
      </div>

      {/* Formulario de creación */}
      <div className="mb-4 p-4 border rounded shadow max-w-md">
        <h2 className="font-bold mb-2">Crear Tarea</h2>
        <input
          placeholder="Título"
          value={title}
          onChange={e => setTitle(e.target.value)}
          className="border p-2 mb-2 w-full"
        />
        <input
          placeholder="Descripción"
          value={description}
          onChange={e => setDescription(e.target.value)}
          className="border p-2 mb-2 w-full"
        />
        <button onClick={handleCreate} className="bg-blue-500 text-white p-2 rounded w-full">
          Agregar Tarea
        </button>
      </div>

      {/* Dashboard de tareas */}
      {loading ? <p>Cargando tareas...</p> :
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Sin iniciar */}
          <div className="border p-2 rounded shadow">
            <h3 className="font-bold mb-2">Sin iniciar ({todoTasks.length})</h3>
            <ul>
              {todoTasks.map(task => (
                <li key={task.id} className="flex justify-between items-center mb-2">
                  <span>{task.title}: {task.description}</span>
                  <div className="flex gap-1">
                    <button
                      onClick={() => handleToggle(task, "done")}
                      className="bg-green-500 text-white px-2 rounded"
                    >
                      Completar
                    </button>
                    <button
                      onClick={() => handleDelete(task.id)}
                      className="bg-red-500 text-white px-2 rounded"
                    >
                      Eliminar
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          </div>

          {/* En progreso (opcional) */}
          <div className="border p-2 rounded shadow">
            <h3 className="font-bold mb-2">En progreso (0)</h3>
            <p className="text-gray-500">Opcional: implementar status in_progress</p>
          </div>

          {/* Completadas */}
          <div className="border p-2 rounded shadow">
            <h3 className="font-bold mb-2">Completadas ({doneTasks.length})</h3>
            <ul>
              {doneTasks.map(task => (
                <li key={task.id} className="flex justify-between items-center mb-2">
                  <span className="line-through">{task.title}: {task.description}</span>
                  <button
                    onClick={() => handleDelete(task.id)}
                    className="bg-red-500 text-white px-2 rounded"
                  >
                    Eliminar
                  </button>
                </li>
              ))}
            </ul>
          </div>
        </div>
      }
    </div>
  );
}
