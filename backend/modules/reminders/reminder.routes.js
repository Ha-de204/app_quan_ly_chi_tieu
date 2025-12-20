const express = require('express');
const router = express.Router();
const reminderController = require('./reminder.controller');
const { protect } = require('../../middlewares/authMiddleware');

router.route('/')
    .post(protect, reminderController.createReminder) // Tạo lời nhắc mới
    .get(protect, reminderController.getReminders); // Lấy danh sách lời nhắc

router.route('/:id')
    .get(protect, reminderController.getReminderById)
    .put(protect, reminderController.updateReminder)
    .delete(protect, reminderController.deleteReminder);

module.exports = router;