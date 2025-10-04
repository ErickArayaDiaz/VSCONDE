// src/controllers/taskController.js
import { Task } from "../models/index.js";

export const getTasks = async (req, res) => {
  try {
    const tasks = await Task.findAll({ where: { userId: req.user.id } });
    res.json(tasks);
} catch (err) {
  console.error("❌ Error en getTasks:", err);
  res.status(500).json({ message: "Error fetching tasks" });
}

};

export const createTask = async (req, res) => {
  try {
    const { title, description } = req.body;
    const task = await Task.create({
      title,
      description,
      userId: req.user.id,
    });
    res.status(201).json(task);
} catch (err) {
  console.error("❌ Error en getTasks:", err);
  res.status(500).json({ message: "Error fetching tasks" });
}

};

export const updateTask = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, completed } = req.body;

    const task = await Task.findOne({ where: { id, userId: req.user.id } });
    if (!task) return res.status(404).json({ message: "Task not found" });

    task.title = title ?? task.title;
    task.description = description ?? task.description;
    task.completed = completed ?? task.completed;
    await task.save();

    res.json(task);
} catch (err) {
  console.error("❌ Error en getTasks:", err);
  res.status(500).json({ message: "Error fetching tasks" });
}

};

export const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;

    const task = await Task.findOne({ where: { id, userId: req.user.id } });
    if (!task) return res.status(404).json({ message: "Task not found" });

    await task.destroy();
    res.json({ message: "Task deleted" });
} catch (err) {
  console.error("❌ Error en getTasks:", err);
  res.status(500).json({ message: "Error fetching tasks" });
}

};
