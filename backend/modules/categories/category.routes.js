const express = require('express');
const router = express.Router();
const categoryController = require('./category.controller');
const { protect } = require('../../middlewares/authMiddleware');

// Lấy danh sách tất cả danh mục (mặc định + thêm mới)
router.get('/list', protect, categoryController.getCategories);

// Thêm danh mục mới
router.post('/create', protect, categoryController.createCategory);

// update & delete
router.route('/:id')
    .put(protect, categoryController.updateCategory)
    .delete(protect, categoryController.deleteCategory);

module.exports = router;