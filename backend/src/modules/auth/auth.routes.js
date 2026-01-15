const router = require('express').Router();
const { login, me } = require('./auth.controller');
const { verifyToken } = require('../../middleware/auth');

router.post('/login', login);
router.get('/me', verifyToken, me);

module.exports = router;
