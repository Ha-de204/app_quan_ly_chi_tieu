const budgetService = require('../../services/budget.service');

const upsertBudget = async (req, res) => {
    const user_id = req.user_id;
    const { category_id, budget_amount, period } = req.body;

    if (!category_id || !budget_amount || !period) {
        return res.status(400).json({ message: 'Thiếu dữ liệu bắt buộc (category_id, budget_amount, period).' });
    }

    if (!/^\d{4}-\d{2}$/.test(period)) {
        return res.status(400).json({ message: 'Period phải ở định dạng YYYY-MM (Ví dụ: 2025-12).' });
    }

    try {
        const budgetId = await budgetService.upsertBudget(
            user_id,
            category_id,
            budget_amount,
            period
        );

        res.status(201).json({
            budget_id: budgetId,
            message: 'Thiết lập/Cập nhật ngân sách thành công.'
        });

    } catch (error) {
        console.error('Lỗi thiết lập ngân sách:', error);
        res.status(500).json({ message: 'Lỗi máy chủ nội bộ khi thiết lập ngân sách.' });
    }
};

const getBudgets = async (req, res) => {
    const user_id = req.user_id;
    const period = req.query.period;

    const defaultPeriod = period || new Date().toISOString().substring(0, 7);

    try {
        const budgets = await budgetService.getBudgetsAmountPeriod(user_id, defaultPeriod);
        res.status(200).json(budgets);
    } catch (error) {
        console.error('Lỗi lấy danh sách ngân sách:', error);
        res.status(500).json({ message: 'Lỗi máy chủ nội bộ khi lấy danh sách ngân sách.' });
    }
};

const deleteBudget = async (req, res) => {
    const user_id = req.user_id;
    const budgetId = parseInt(req.params.id);

    if (isNaN(budgetId)) {
        return res.status(400).json({ message: 'ID ngân sách không hợp lệ.' });
    }

    try {
        const deleted = await budgetService.deleteBudget(budgetId, user_id);

        if (!deleted) {
            return res.status(404).json({ message: 'Không tìm thấy ngân sách để xóa hoặc bạn không có quyền.' });
        }

        res.status(200).json({ message: 'Xóa ngân sách thành công.' });
    } catch (error) {
        console.error('Lỗi xóa ngân sách:', error);
        res.status(500).json({ message: 'Lỗi máy chủ nội bộ.' });
    }
};

module.exports = { upsertBudget, getBudgets, deleteBudget };