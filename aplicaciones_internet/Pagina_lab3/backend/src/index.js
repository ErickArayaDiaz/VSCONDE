// src/index.js
import express from "express";
import dotenv from "dotenv";
import { sequelize } from "./models/index.js";
import taskRoutes from "./routes/tasks.js";
import authRoutes from "./routes/auth.js";

dotenv.config();

const app = express();
app.use(express.json());

// Rutas
app.use("/api/auth", authRoutes);
app.use("/api/tasks", taskRoutes);

// Conexión a base de datos
// lineas de sincronizacion de la base de datos 
//({ alter: true }) altera no cambia nada en la base de datos
//({ force: true }) fuerza a cambiar la base de datos, elimina todo y crea las tablas de nuevo
//() crea las tablas si no existen, pero no altera nada
sequelize.sync({ alter: true }) // Cambia a true solo si quieres recrear las tablas
  .then(() => {
    console.log("✅ DB SQLite conectada y tablas sincronizadas");

    // 🚀 IMPORTANTE: inicia el servidor DENTRO del .then()
    app.listen(4000, () => {
      console.log("Servidor corriendo en http://localhost:4000");
    });
  })
  .catch(err => {
    console.error("❌ Error en DB:", err);
  });
