// backend/src/index.js
import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import { sequelize } from "./models/index.js";
import authRoutes from "./routes/auth.js";
import taskRoutes from "./routes/tasks.js";

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);
app.use("/api/tasks", taskRoutes);

sequelize.sync({ force: true }).then(() => {
  console.log("✅ DB SQLite conectada y tablas sincronizadas");
  app.listen(4000, () => console.log("Servidor corriendo en http://localhost:4000"));
});
