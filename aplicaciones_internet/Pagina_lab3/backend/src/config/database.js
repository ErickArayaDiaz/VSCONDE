import { Sequelize } from "sequelize";

// Usamos SQLite para laboratorio: crea un archivo local database.sqlite
const sequelize = new Sequelize({
  dialect: "sqlite",
  storage: "./database.sqlite",
  logging: false, // no mostrar logs SQL en consola
});

export default sequelize;
