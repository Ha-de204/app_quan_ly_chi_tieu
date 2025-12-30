const User = require('../models/User');
const mongoose = require('mongoose');

// 1. Tìm người dùng bằng Email (Dùng khi Đăng nhập)
const findUserByEmail = async (email) => {
    return await User.findOne({ email: email });
};

// 2. Tạo người dùng mới (Dùng khi Đăng ký)
const createUser = async (email, passwordHash, name) => {
    const newUser = new User({
        email: email,
        password_hash: passwordHash,
        name: name || null
    });

    const result = await newUser.save();
    return result._id;
};

// 3. Lấy thông tin user bằng ID
const getUserById = async (user_id) => {
    try {
        return await User.findById(user_id).select('-password_hash');
    } catch (err) {
        return null;
    }
};

module.exports = { findUserByEmail, createUser, getUserById };