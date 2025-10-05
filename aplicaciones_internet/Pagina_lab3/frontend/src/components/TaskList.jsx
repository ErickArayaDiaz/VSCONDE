// frontend/src/components/TaskList.jsx
import { useEffect, useState } from "react";
import { getTasks, createTask, updateTask, deleteTask } from "../services/taskService";

export default function TaskList() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const token = localStorage.getItem("token");

  const fetchTasks = async () => {
    try {
      const data = await getTasks(token);
      setTasks(data);
    } catch {
      alert("Error al obtener tareas");
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
    } catch {
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

  const sinIniciar = tasks.filter(t => !t.completed);
  const completadas = tasks.filter(t => t.completed);

  return (
    <div>
      <div className="mb-4">
        <input
          placeholder="Título"
          value={title}
          onChange={e => setTitle(e.target.value)}
          className="border p-2 rounded w-full mb-2"
        />
        <input
          placeholder="Descripción"
          value={description}
          onChange={e => setDescription(e.target.value)}
          className="border p-2 rounded w-full mb-2"
        />
        <button onClick={handleCreate} className="bg-blue-500 text-white px-3 py-2 rounded w-full">
          Agregar
        </button>
      </div>

      <div className="grid grid-cols-2 gap-4">
        {/* Sin iniciar */}
        <div>
          <h3 className="font-bold text-lg mb-2">Sin iniciar</h3>
          {sinIniciar.map(task => (
            <div key={task.id} className="border p-2 rounded shadow mb-2 bg-yellow-50">
              <div className="flex justify-between items-center">
                <div>
                  <h4 className="font-semibold">{task.title}</h4>
                  <p>{task.description}</p>
                </div>
                <div className="flex gap-1">
                  <input type="checkbox" checked={task.completed} onChange={() => handleToggle(task)} />
                  <button onClick={() => handleDelete(task.id)} className="bg-red-500 text-white px-2 rounded">
                    X
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Completadas */}
        <div>
          <h3 className="font-bold text-lg mb-2">Completadas</h3>
          {completadas.map(task => (
            <div key={task.id} className="border p-2 rounded shadow mb-2 bg-green-50">
              <div className="flex justify-between items-center">
                <div>
                  <h4 className="font-semibold line-through">{task.title}</h4>
                  <p className="line-through">{task.description}</p>
                </div>
                <div className="flex gap-1">
                  <input type="checkbox" checked={task.completed} onChange={() => handleToggle(task)} />
                  <button onClick={() => handleDelete(task.id)} className="bg-red-500 text-white px-2 rounded">
                    X
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
