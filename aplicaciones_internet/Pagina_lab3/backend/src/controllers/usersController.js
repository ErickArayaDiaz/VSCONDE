// backend/src/controllers/usersController.js
exports.getMe = async (req, res) => {
  return res.json(req.user);
};
