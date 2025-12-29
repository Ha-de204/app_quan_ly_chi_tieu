const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password_hash: { type: String, required: true },
    name: { type: String, default: null },
    created_at: { type: Date, default: Date.now }
}, { collection: 'User' });

module.exports = mongoose.model('User', UserSchema);