const express = require("express");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static("public"));

io.on("connection", (socket) => {
  console.log("Usuario conectado");

  socket.on("draw", (data) => socket.broadcast.emit("draw", data));
  socket.on("shape", (data) => socket.broadcast.emit("shape", data));
  socket.on("clear", () => io.emit("clear"));

  socket.on("disconnect", () => console.log("Usuario desconectado"));
});

server.listen(3000, () => console.log("http://localhost:3000"));

