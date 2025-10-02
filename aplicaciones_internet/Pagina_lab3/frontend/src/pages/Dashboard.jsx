import TaskList from "../components/TaskList";
import TaskForm from "../components/TaskForm";
import { useEffect, useState } from "react";
import API from "../services/api";

export default function Dashboard() {
  const [reload, setReload] = useState(false);

  const refresh = () => setReload(!reload);

  useEffect(() => {}, [reload]);

  return (
    <div>
      <h2>Panel de tareas</h2>
      <TaskForm refresh={refresh} />
      <TaskList key={reload} />
    </div>
  );
}
