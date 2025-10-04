// backend/src/models/task.js
import { DataTypes } from "sequelize";

export default (sequelize) => {
  return sequelize.define("Task", {
    title: { type: DataTypes.STRING, allowNull: false },
    description: { type: DataTypes.STRING, allowNull: true },
    completed: { type: DataTypes.BOOLEAN, defaultValue: false },
    userId: { type: DataTypes.INTEGER, allowNull: false },
  });
};
