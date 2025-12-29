const User = require('../models/User');
const mongoose = require('mongoose');

// 1. Tìm người dùng bằng Email (Dùng khi Đăng nhập)
const findUserByEmail = async (email) => {
    // MongoDB tìm kiếm rất nhanh bằng findOne
    return await User.findOne({ email: email });
};

// 2. Tạo người dùng mới (Dùng khi Đăng ký)
const createUser = async (email, passwordHash, name) => {
    const newUser = new User({
        email: email,
        password_hash: passwordHash,
        name: name || null
        // created_at đã có default là Date.now trong Model
    });

    const result = await newUser.save();
    return result._id; // Trả về ObjectId của user mới
};

// 3. Lấy thông tin user bằng ID
const getUserById = async (user_id) => {
    try {
        return await User.findById(user_id).select('-password_hash');
        // .select('-password_hash') để bảo mật, không trả về mật khẩu
    } catch (err) {
        return null;
    }
};

module.exports = { findUserByEmail, createUser, getUserById };