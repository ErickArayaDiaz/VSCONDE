// src/services/taskService.js
const API_URL = "http://localhost:4000/api/tasks";

export const getTasks = async (token) => {
  const res = await fetch(API_URL, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error("Error fetching tasks");
  return res.json();
};

export const createTask = async (token, task) => {
  const res = await fetch(API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(task),
  });
  if (!res.ok) throw new Error("Error creating task");
  return res.json();
};

export const updateTask = async (token, id, updates) => {
  const res = await fetch(`${API_URL}/${id}`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(updates),
  });
  if (!res.ok) throw new Error("Error updating task");
  return res.json();
};

export const deleteTask = async (token, id) => {
  const res = await fetch(`${API_URL}/${id}`, {
    method: "DELETE",
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error("Error deleting task");
  return res.json();
};
