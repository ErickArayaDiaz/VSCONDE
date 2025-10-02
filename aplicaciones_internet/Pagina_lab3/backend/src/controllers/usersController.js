exports.getMe = async (req, res) => {
  return res.json(req.user);
};
