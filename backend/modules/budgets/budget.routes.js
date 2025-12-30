const express = require('express');
const router = express.Router();
const budgetController = require('./budget.controller');
//const { protect } = require('../../middlewares/authMiddleware');

router.post('/upsert', budgetController.upsertBudget);
router.get('/details', budgetController.getBudgets);
router.delete('/:id', budgetController.deleteBudget);

module.exports = router;