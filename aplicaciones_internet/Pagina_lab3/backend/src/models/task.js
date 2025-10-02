import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";
import User from "./user.js";

const Task = sequelize.define("Task", {
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  title: { type: DataTypes.STRING, allowNull: false },
  description: { type: DataTypes.TEXT },
  status: { type: DataTypes.ENUM("todo", "in_progress", "done"), defaultValue: "todo" },
  priority: { type: DataTypes.ENUM("low", "medium", "high"), defaultValue: "low" },
  due_date: { type: DataTypes.DATE, allowNull: true },
}, { timestamps: true });

Task.belongsTo(User, { foreignKey: "userId" });
User.hasMany(Task, { foreignKey: "userId" });

export default Task;
