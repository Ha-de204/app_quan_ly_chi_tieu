const express = require('express');
const router = express.Router();
const budgetController = require('./budget.controller');
const { protect } = require('../../middlewares/authMiddleware');

// thiết lập hoặc cập nhật ngân sách (Upsert)
router.post('/upsert', protect, budgetController.upsertBudget);

// lấy danh sách ngân sách (và tình trạng sử dụng) theo tháng
router.get('/details', protect, budgetController.getBudgets);

// xóa ngân sách
router.delete('/:id', protect, budgetController.deleteBudget);

module.exports = router;