// frontend/src/pages/TaskPage.jsx
import TaskList from "../components/TaskList.jsx";

export default function TaskPage({ user }) {
  return (
    <div>
      <h1 className="text-center text-2xl font-bold my-4">Bienvenido, {user.name}</h1>
      <TaskList />
    </div>
  );
}
