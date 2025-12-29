const express = require('express');
const router = express.Router();
const reminderController = require('./reminder.controller');
//const { protect } = require('../../middlewares/authMiddleware');

router.route('/')
    .post(reminderController.createReminder) // Tạo lời nhắc mới
    .get(reminderController.getReminders); // Lấy danh sách lời nhắc

router.route('/:id')
    .get(reminderController.getReminderById)
    .put(reminderController.updateReminder)
    .delete(reminderController.deleteReminder);

module.exports = router;