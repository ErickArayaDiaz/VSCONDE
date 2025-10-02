import { useState } from "react";
import API from "../services/api";

export default function TaskForm({ refresh }) {
  const [title, setTitle] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await API.post("/tasks", { title });
      setTitle("");
      refresh();
    } catch (error) {
      console.error("Error al crear tarea", error);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input 
        type="text" 
        placeholder="Nueva tarea" 
        value={title} 
        onChange={(e) => setTitle(e.target.value)} 
      />
      <button type="submit">Agregar</button>
    </form>
  );
}
