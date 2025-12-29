const express = require('express');
const router = express.Router();
const budgetController = require('./budget.controller');
//const { protect } = require('../../middlewares/authMiddleware');

// thiết lập hoặc cập nhật ngân sách (Upsert)
router.post('/upsert', budgetController.upsertBudget);

// lấy danh sách ngân sách (và tình trạng sử dụng) theo tháng
router.get('/details', budgetController.getBudgets);

// xóa ngân sách
router.delete('/:id', budgetController.deleteBudget);

module.exports = router;