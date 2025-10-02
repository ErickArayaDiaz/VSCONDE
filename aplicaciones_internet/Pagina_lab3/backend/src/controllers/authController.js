import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { User } from "../models/index.js"; 
import dotenv from "dotenv";


dotenv.config();

export const register = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const exists = await User.findOne({ where: { email } });
    if (exists) return res.status(400).json({ message: "Email already registered" });

    const hash = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, password_hash: hash });

    return res.status(201).json({ id: user.id, name: user.name, email: user.email });
  } catch (err) {
    return res.status(500).json({ message: "Server error" });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(401).json({ message: "Invalid credentials" });

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return res.status(401).json({ message: "Invalid credentials" });

    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    return res.json({
      token,
      user: { id: user.id, name: user.name, email: user.email }
    });
  } catch (err) {
    return res.status(500).json({ message: "Server error" });
  }
};
