const mongoose = require('mongoose');

const ReportSchema = new mongoose.Schema({
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    type: { type: String, enum: ['monthly', 'yearly', 'custom'], required: true },
    period: { type: String, required: true },
    total_expense: { type: Number, default: 0 },
    total_income: { type: Number, default: 0 },
    generated_at: { type: Date, default: Date.now }
}, { collection: 'Report' });

module.exports = mongoose.model('Report', ReportSchema);