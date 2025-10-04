import { useEffect, useState } from "react";
import { getTasks, createTask, updateTask, deleteTask } from "../services/taskService";

export default function TaskList() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");

  const fetchTasks = async () => {
    try {
      const data = await getTasks();
      setTasks(data);
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  const handleCreate = async () => {
    const newTask = await createTask(title, description);
    setTasks([...tasks, newTask]);
    setTitle(""); setDescription("");
  };

  const handleToggle = async (task) => {
    const updated = await updateTask(task.id, { completed: !task.completed });
    setTasks(tasks.map(t => t.id === task.id ? updated : t));
  };

  const handleDelete = async (id) => {
    await deleteTask(id);
    setTasks(tasks.filter(t => t.id !== id));
  };

  return (
    <div className="p-4">
      <h2>Tareas</h2>
      <input
        placeholder="Título"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        className="border p-2 mb-2 mr-2"
      />
      <input
        placeholder="Descripción"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        className="border p-2 mb-2 mr-2"
      />
      <button onClick={handleCreate} className="bg-blue-500 text-white p-2">Agregar</button>
      
      <ul className="mt-4">
        {tasks.map(task => (
          <li key={task.id} className="flex items-center justify-between border p-2 mb-2">
            <div>
              <input type="checkbox" checked={task.completed} onChange={() => handleToggle(task)} />
              <span className={`ml-2 ${task.completed ? "line-through" : ""}`}>
                {task.title}: {task.description}
              </span>
            </div>
            <button onClick={() => handleDelete(task.id)} className="bg-red-500 text-white p-1">Eliminar</button>
          </li>
        ))}
      </ul>
    </div>
  );
}
