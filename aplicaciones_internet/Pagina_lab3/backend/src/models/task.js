import { DataTypes } from "sequelize";

export default (sequelize) => {
  const Task = sequelize.define("Task", {
    title: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    completed: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
  });

  return Task;
};
