const express = require('express');
const router = express.Router();
const reportController = require('./report.controller');
//const { protect } = require('../../middlewares/authMiddleware');

router.get('/summary', reportController.getSummary);
router.get('/category-breakdown', reportController.getCategoryBreakdown);
router.get('/monthly-flow', reportController.getMonthlyFlow);

module.exports = router;