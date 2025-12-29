const mongoose = require('mongoose');

const BudgetSchema = new mongoose.Schema({
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    category_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
    budget_amount: { type: Number, default: 0 },
    period: { type: String, required: true }
}, { timestamps: true, collection: 'Budget' });

module.exports = mongoose.model('Budget', BudgetSchema);