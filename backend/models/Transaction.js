const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema({
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    category_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
    amount: { type: Number, required: true },
    type: { type: String, enum: ['income', 'expense'], required: true },
    date: { type: Date, required: true },
    title: { type: String, required: true },
    note: { type: String, default: null }
}, { timestamps: true, collection: 'Transaction' });

module.exports = mongoose.model('Transaction', TransactionSchema);