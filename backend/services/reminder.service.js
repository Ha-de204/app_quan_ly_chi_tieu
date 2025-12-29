const Reminder = require('../models/Reminder');
const mongoose = require('mongoose');

// 1. Tạo lời nhắc mới
const createReminder = async (user_id, title, message, due_date, frequency) => {
    const newReminder = new Reminder({
        user_id: new mongoose.Types.ObjectId(user_id),
        title,
        message: message || null,
        due_date: due_date,
        frequency,
        is_enabled: true
    });

    const result = await newReminder.save();
    return result._id;
};

// 2. Lấy tất cả lời nhắc của user
const getRemindersByUserId = async (user_id) => {
    return await Reminder.find({
        user_id: new mongoose.Types.ObjectId(user_id)
    }).sort({ due_date: 1 });
};

// 3. Lấy chi tiết 1 lời nhắc
const getReminderById = async (reminder_id, user_id) => {
    return await Reminder.findOne({
        _id: new mongoose.Types.ObjectId(reminder_id),
        user_id: new mongoose.Types.ObjectId(user_id)
    });
};

// 4. Cập nhật lời nhắc
const updateReminder = async (reminder_id, user_id, title, message, due_date, frequency, is_enabled) => {
   try {
    const result = await Reminder.updateOne(
            {
                _id: new mongoose.Types.ObjectId(reminder_id),
                user_id: new mongoose.Types.ObjectId(user_id)
            },
            {
                $set: {
                    title: title,
                    message: message || null,
                    due_date: due_date,
                    frequency: frequency,
                    is_enabled: is_enabled,
                }
            }
        );
        return result.modifiedCount > 0;
   } catch (error) {
      console.error("Lỗi tại Service updateReminder:", error);
      throw error;
   }
};

// 5. Xóa lời nhắc
const deleteReminder = async (reminder_id, user_id) => {
    const result = await Reminder.deleteOne({
        _id: new mongoose.Types.ObjectId(reminder_id),
        user_id: new mongoose.Types.ObjectId(user_id)
    });

    return result.deletedCount > 0;
};

module.exports = {
    createReminder,
    getRemindersByUserId,
    getReminderById,
    updateReminder,
    deleteReminder
};