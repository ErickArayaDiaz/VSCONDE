// backend/src/models/index.js
import sequelize from "../config/db.js";
import UserModel from "./user.js";
import TaskModel from "./task.js";

const User = UserModel(sequelize);
const Task = TaskModel(sequelize);

User.hasMany(Task, { foreignKey: "userId" });
Task.belongsTo(User, { foreignKey: "userId" });

export { sequelize, User, Task };
