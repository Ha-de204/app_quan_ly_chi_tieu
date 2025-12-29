const Category = require('../models/Category');
const mongoose = require('mongoose');

// 1. Lấy danh mục mặc định và danh mục của user
const getCategoriesByUser = async (user_id) => {
    return await Category.find({
        $or: [
            { is_default: true },
            { user_id: new mongoose.Types.ObjectId(user_id) }
        ]
    }).sort({ is_default: -1, name: 1 });
};

// 2. Tao danh muc mac dinh
const createDefaultCategories = async (user_id) => {
    const defaultCategories = [
        { name: 'Mua sắm', iconCodePoint: 0xe59c },
        { name: 'Đồ ăn', iconCodePoint: 0xe25a },
        { name: 'Quần áo', iconCodePoint: 0xf5d1 },
        { name: 'Nhà ở', iconCodePoint: 0xe318 },
        { name: 'Sức khỏe', iconCodePoint: 0xe25b },
        { name: 'Học tập', iconCodePoint: 0xe0ef },
        { name: 'Du lịch', iconCodePoint: 0xe295 },
        { name: 'Giải trí', iconCodePoint: 0xe6a1 },
        { name: 'Sửa chữa', iconCodePoint: 0xe0af },
        { name: 'Sắc đẹp', iconCodePoint: 0xeb4c },
        { name: 'Điện thoại', iconCodePoint: 0xe4e2 },
        { name: 'Cài đặt', iconCodePoint: 0xe57f },
    ];

    const categoriesWithUser = defaultCategories.map(cat => ({
        ...cat,
        user_id: user_id,
        isDefault: true
    }));

    // Sử dụng insertMany của Mongoose để chèn nhanh
    return await CategoryModel.insertMany(categoriesWithUser);
};

// 3. Tạo danh mục mới
const createCategory = async (user_id, name, iconCodePoint) => {
    const newCategory = new Category({
        user_id: new mongoose.Types.ObjectId(user_id),
        name: name,
        icon_code_point: iconCodePoint,
        is_default: false
    });

    const result = await newCategory.save();
    return result._id;
};

// 4. Cập nhật danh mục (Chỉ cho phép sửa danh mục riêng của user)
const updateCategory = async (categoryId, user_id, name, iconCodePoint) => {
    const result = await Category.updateOne(
        {
            _id: new mongoose.Types.ObjectId(categoryId),
            user_id: new mongoose.Types.ObjectId(user_id),
            is_default: false
        },
        {
            name: name,
            icon_code_point: iconCodePoint
        }
    );

    return result.modifiedCount > 0;
};

// 5. Xóa danh mục
const deleteCategory = async (categoryId, user_id) => {
    const result = await Category.deleteOne({
        _id: new mongoose.Types.ObjectId(categoryId),
        user_id: new mongoose.Types.ObjectId(user_id),
        is_default: false
    });

    return result.deletedCount > 0;
};

module.exports = {
    getCategoriesByUser,
    createCategory,
    updateCategory,
    deleteCategory
};