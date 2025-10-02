const { Task } = require('../models');

exports.getTasks = async (req, res) => {
  const { status } = req.query;
  const where = { userId: req.user.id };
  if (status) where.status = status;
  const tasks = await Task.findAll({ where });
  res.json(tasks);
};

exports.createTask = async (req, res) => {
  const { title, description, due_date, priority } = req.body;
  if (!title) return res.status(400).json({ message: 'Title required' });
  const task = await Task.create({ title, description, due_date, priority, userId: req.user.id });
  res.status(201).json(task);
};

exports.updateTask = async (req, res) => {
  const { id } = req.params;
  const task = await Task.findOne({ where: { id, userId: req.user.id } });
  if (!task) return res.status(404).json({ message: 'Not found' });
  await task.update(req.body);
  res.json(task);
};

exports.deleteTask = async (req, res) => {
  const { id } = req.params;
  const task = await Task.findOne({ where: { id, userId: req.user.id } });
  if (!task) return res.status(404).json({ message: 'Not found' });
  await task.destroy();
  res.json({ message: 'Deleted' });
};
