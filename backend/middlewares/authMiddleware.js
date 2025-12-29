const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'fallback_secret_key';

const protect = (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1];
            const decoded = jwt.verify(token, JWT_SECRET);
            req.user_id = decoded.id;
            req.id = decoded.id;
            return next();
        } catch (error) {
            console.error(error);
            return res.status(401).json({ message: 'Không được phép, token không hợp lệ hoặc đã hết hạn.' });
        }
    }

    if (!token) {
        return res.status(401).json({ message: 'Không được phép, không có token.' });
    }
};

module.exports = { protect };