import express from "express";
import dotenv from "dotenv";
import { sequelize } from "./models/index.js";  // importa sequelize ya configurado

dotenv.config();

const app = express();
app.use(express.json());

// importa rutas
import authRoutes from "./routes/auth.js";
app.use("/api/auth", authRoutes);

// Sincronizar DB
sequelize.sync({ force: true }) // ⚠️ recrea tablas
  .then(() => {
    console.log("✅ DB SQLite conectada y tablas sincronizadas");
  })
  .catch(err => {
    console.error("❌ Error en DB:", err);
  });

app.listen(4000, () => {
  console.log("Servidor corriendo en http://localhost:4000");
});
