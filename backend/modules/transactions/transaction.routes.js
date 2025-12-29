const express = require('express');
const router = express.Router();
const transactionController = require('./transaction.controller');
//const { protect } = require('../../middlewares/authMiddleware');

router.post('/create', transactionController.createTransaction);
router.get('/list', transactionController.getTransactions);

router.route('/:id')
    .get(transactionController.getTransactionById)
    .put(transactionController.updateTransaction)
    .delete(transactionController.deleteTransaction);

module.exports = router;