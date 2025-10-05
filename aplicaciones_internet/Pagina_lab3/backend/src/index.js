// backend/src/index.js
import express from "express";
import dotenv from "dotenv";
import taskRoutes from "./routes/tasks.js";
import authRoutes from "./routes/auth.js";
import cors from "cors";
import sequelize from "./config/db.js"; // ✅ corregido: ruta correcta y única

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// ✅ Rutas principales
app.use("/api/auth", authRoutes);
app.use("/api/tasks", taskRoutes);

// ✅ Conexión y sincronización con la base de datos
sequelize.sync({ alter: true })
  .then(() => {
    console.log("✅ DB local PostgreSQL conectada y tablas sincronizadas");
    app.listen(4000, () => {
      console.log("Servidor corriendo en http://localhost:4000");
    });
  })
  .catch(err => {
    console.error("❌ Error en DB:", err);
  });
