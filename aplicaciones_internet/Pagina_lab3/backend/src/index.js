import express from "express";
import cors from "cors";
import sequelize from "./config/database.js";

const app = express();
app.use(cors());
app.use(express.json());

// test route
app.get("/", (req, res) => {
  res.send("🚀 Backend funcionando!");
});

// conectar a DB
(async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync();
    console.log("✅ DB conectada y tablas sincronizadas");
  } catch (error) {
    console.error("❌ Error al conectar DB:", error);
  }
})();

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Servidor en http://localhost:${PORT}`);
});
