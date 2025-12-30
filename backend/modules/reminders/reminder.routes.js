const express = require('express');
const router = express.Router();
const reminderController = require('./reminder.controller');
//const { protect } = require('../../middlewares/authMiddleware');

router.route('/')
    .post(reminderController.createReminder)
    .get(reminderController.getReminders);

router.route('/:id')
    .get(reminderController.getReminderById)
    .put(reminderController.updateReminder)
    .delete(reminderController.deleteReminder);

module.exports = router;