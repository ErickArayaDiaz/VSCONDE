import express from "express";
import cors from "cors";
import sequelize from "./config/database.js";

const app = express();
app.use(cors());
app.use(express.json());

// Ruta de prueba
app.get("/", (req, res) => res.send("🚀 Backend funcionando con SQLite!"));

// Iniciar DB y servidor
(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync({ alter: true }); // crea tablas automáticamente
    console.log("✅ DB SQLite conectada y tablas sincronizadas");
  } catch (error) {
    console.error("❌ Error al conectar DB:", error);
  }
})();

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Servidor corriendo en http://localhost:${PORT}`));
