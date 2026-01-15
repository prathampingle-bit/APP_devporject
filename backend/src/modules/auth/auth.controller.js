const authService = require('./auth.service');
const { getProfile } = authService;

const login = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }
  try {
    const result = await authService.login(email, password);
    if (!result) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    return res.json(result);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

const me = async (req, res) => {
  try {
    const profile = await getProfile(req.user.sub);
    if (!profile) return res.status(404).json({ message: 'User not found' });
    return res.json({ user: profile });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { login, me };
