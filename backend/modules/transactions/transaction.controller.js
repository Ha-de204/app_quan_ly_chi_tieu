const transactionService = require('../../services/transaction.service');

const createTransaction = async (req, res) => {
    const user_id = req.user_id;
    const { category_id, amount, type, date, title, note } = req.body;
    if (!category_id || !amount || !type || !date || !title) {
        return res.status(400).json({ message: 'Thiếu dữ liệu bắt buộc (categoryId, amount, type, date, title).' });
    }

    try {
        const transactionId = await transactionService.createTransaction(
            user_id,
            category_id,
            amount,
            type,
            date,
            title,
            note
        );

        res.status(201).json({
            transaction_id: transactionId,
            message: 'Tạo giao dịch thành công.'
        });

    } catch (error) {
        console.error('Lỗi tạo giao dịch:', error);
        res.status(500).json({ message: 'Lỗi máy chủ nội bộ khi tạo giao dịch.' });
    }
};

const getTransactions = async (req, res) => {
    const user_id= req.user_id;

    try {
        const transactions = await transactionService.getTransactionsByUserId(user_id);
        res.status(200).json(transactions);
    } catch (error) {
        console.error('Lỗi lấy giao dịch:', error);
        res.status(500).json({ message: 'Lỗi máy chủ nội bộ khi lấy giao dịch.' });
    }
};

// lay chi tiet 1 giao dich
const getTransactionById = async (req, res) => {
    const user_id = req.user_id;
    const transaction_id = parseInt(req.params.id);

    if (isNaN(transaction_id)) {
        return res.status(400).json({ message: 'ID giao dịch không hợp lệ.' });
    }

    try {
        const transaction = await transactionService.getTransactionById(transaction_id, user_id);

        if (!transaction) {
            return res.status(404).json({ message: 'Không tìm thấy giao dịch hoặc bạn không có quyền truy cập.' });
        }
        res.status(200).json(transaction);
    } catch (error) {
        console.error('Lỗi lấy chi tiết giao dịch:', error);
        res.status(500).json({ message: 'Lỗi máy chủ nội bộ.' });
    }
};

// update giao dich
const updateTransaction = async (req, res) => {
    const user_id = req.user_id;
    const transaction_id = parseInt(req.params.id);
    const { category_id, amount, type, date, title, note } = req.body;

    if (isNaN(transaction_id) || !category_id || !amount || !type || !date || !title) {
        return res.status(400).json({ message: 'Dữ liệu cập nhật hoặc ID giao dịch không hợp lệ.' });
    }

    try {
        const updated = await transactionService.updateTransaction(
            transaction_id,
            user_id,
            category_id,
            amount,
            type,
            date,
            title,
            note
        );

        if (!updated) {
            return res.status(404).json({ message: 'Không tìm thấy giao dịch để cập nhật hoặc không có thay đổi.' });
        }

        res.status(200).json({ message: 'Cập nhật giao dịch thành công.' });
    } catch (error) {
        console.error('Lỗi cập nhật giao dịch:', error);
        res.status(500).json({ message: 'Lỗi máy chủ nội bộ.' });
    }
};

// delete giao dich
const deleteTransaction = async (req, res) => {
    const user_id = req.user_id;
    const transaction_id = parseInt(req.params.id);

    if (isNaN(transaction_id)) {
        return res.status(400).json({ message: 'ID giao dịch không hợp lệ.' });
    }

    try {
        const success = await transactionService.deleteTransaction(transaction_id, user_id);
        if (success) {
            return res.status(200).json({ message: `Giao dịch ID ${transaction_id} đã được xóa.` });
        } else {
            return res.status(404).json({ message: 'Không tìm thấy giao dịch hoặc bạn không có quyền xóa.' });
        }
    } catch (error) {
        console.error('Lỗi khi xóa giao dịch:', error);
        return res.status(500).json({ message: 'Lỗi máy chủ nội bộ khi xóa giao dịch.' });
    }
};

module.exports = { createTransaction,
                   getTransactions,
                   getTransactionById,
                   updateTransaction,
                   deleteTransaction
                  };