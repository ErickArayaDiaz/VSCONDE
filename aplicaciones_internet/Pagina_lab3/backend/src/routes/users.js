// backend/src/routes/users.js
const express = require('express');
const router = express.Router();
const { getMe } = require('../controllers/usersController');
const auth = require('../middlewares/authMiddleware');

router.get('/me', auth, getMe);

module.exports = router;
