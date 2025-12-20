const express = require('express');
const router = express.Router();
const reportController = require('./report.controller');
const { protect } = require('../../middlewares/authMiddleware');

// Lấy tổng quan (Tổng Chi, Số dư) theo phạm vi thời gian
router.get('/summary', protect, reportController.getSummary);

// Lấy phân tích Chi tiêu theo Danh mục (dùng cho Biểu đồ tròn/thanh)
router.get('/category-breakdown', protect, reportController.getCategoryBreakdown);

// Lấy dữ liệu dòng tiền theo tháng (dùng cho Biểu đồ đường)
router.get('/monthly-flow', protect, reportController.getMonthlyFlow);

module.exports = router;