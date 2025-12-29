const mongoose = require('mongoose');

const ReminderSchema = new mongoose.Schema({
    user_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    title: { type: String, required: true },
    message: { type: String, default: null },
    due_date: { type: Date, required: true },
    frequency: { type: String, required: true },
    is_enabled: { type: Boolean, default: true }
}, { timestamps: true, collection: 'Reminder' });

module.exports = mongoose.model('Reminder', ReminderSchema);