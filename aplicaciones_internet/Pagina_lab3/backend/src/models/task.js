module.exports = (sequelize, DataTypes) => {
  const Task = sequelize.define('Task', {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    title: { type: DataTypes.STRING, allowNull: false },
    description: { type: DataTypes.TEXT },
    status: { type: DataTypes.ENUM('todo','in_progress','done'), defaultValue: 'todo' },
    priority: { type: DataTypes.ENUM('low','medium','high'), defaultValue: 'medium' },
    due_date: { type: DataTypes.DATE, allowNull: true }
  });
  return Task;
};
