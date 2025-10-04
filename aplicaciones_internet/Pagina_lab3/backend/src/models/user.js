// backend/src/models/user.js
import { DataTypes } from "sequelize";

export default (sequelize) => {
  return sequelize.define("User", {
    name: { type: DataTypes.STRING, allowNull: false },
    email: { type: DataTypes.STRING, allowNull: false, unique: true },
    password_hash: { type: DataTypes.STRING, allowNull: false },
  });
};
