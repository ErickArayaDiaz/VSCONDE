import { Sequelize } from "sequelize";

// Para SQLite
const sequelize = new Sequelize({
  dialect: "sqlite",
  storage: "database.sqlite",
  logging: false, // opcional, quita logs de SQL
});

export default sequelize;
