// src/services/taskService.js
import { API_URL } from "../api.js"; // definiremos api.js

export const getTasks = async (token) => {
  const res = await fetch(`${API_URL}/tasks`, {
    headers: {
      "Authorization": `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  });
  return res.json();
};
