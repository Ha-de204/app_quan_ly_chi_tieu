const Transaction = require('../models/Transaction');
const Budget = require('../models/Budget');
const mongoose = require('mongoose');

// 1. Lấy tổng chi tiêu trong khoảng thời gian
const getSummaryByDateRange = async (user_id, startDate, endDate) => {
    const result = await Transaction.aggregate([
        {
            $match: {
                user_id: new mongoose.Types.ObjectId(user_id),
                type: 'expense',
                date: {
                    $gte: new Date(startDate),
                    $lte: new Date(endDate)
                }
            }
        },
        {
            $group: {
                _id: null,
                TotalExpense: { $sum: '$amount' }
            }
        }
    ]);

    return { TotalExpense: result[0]?.TotalExpense || 0 };
};

// 2. Thống kê chi tiết theo danh mục (Category Breakdown)
const getCategoryBreakdown = async (user_id, startDate, endDate) => {
    const result = await Transaction.aggregate([
        {
            $match: {
                user_id: new mongoose.Types.ObjectId(user_id),
                type: 'expense',
                date: {
                    $gte: new Date(startDate),
                    $lte: new Date(endDate)
                }
            }
        },
        {
            $lookup: {
                from: 'Category',
                localField: 'category_id',
                foreignField: '_id',
                as: 'category_info'
            }
        },
        { $unwind: '$category_info' },
        {
            $group: {
                _id: '$category_id',
                category_name: { $first: '$category_info.name' },
                icon_code_point: { $first: '$category_info.icon_code_point' },
                TotalAmount: { $sum: '$amount' }
            }
        },
        { $sort: { TotalAmount: -1 } }
    ]);

    return result;
};

// 3. Dòng tiền hàng tháng (Monthly Flow)
const getMonthlyFlow = async (user_id, year) => {
    const startOfYear = new Date(`${year}-01-01`);
    const endOfYear = new Date(`${year}-12-31T23:59:59`);

    const monthlyExpenses = await Transaction.aggregate([
        {
            $match: {
                user_id: new mongoose.Types.ObjectId(user_id),
                type: 'expense',
                date: { $gte: startOfYear, $lte: endOfYear }
            }
        },
        {
            $group: {
                _id: { $month: '$date' },
                TotalExpense: { $sum: '$amount' }
            }
        }
    ]);

    const budgets = await Budget.find({
        user_id: new mongoose.Types.ObjectId(user_id),
        period: { $regex: `^${year}-` },
        $or: [{ category_id: null }, { category_id: { $exists: false } }]
    });

    const finalFlow = [];
    for (let month = 1; month <= 12; month++) {
        const periodStr = `${year}-${month.toString().padStart(2, '0')}`;

        const expenseData = monthlyExpenses.find(e => e._id === month);
        const budgetData = budgets.find(b => b.period === periodStr);

        const totalExpense = expenseData ? expenseData.TotalExpense : 0;
        const budgetAmount = budgetData ? budgetData.budget_amount : 0;

        finalFlow.push({
            month_number: month,
            TotalExpense: totalExpense,
            BudgetAmount: budgetAmount,
            NetBalance: budgetAmount - totalExpense
        });
    }

    return finalFlow;
};

module.exports = {
    getSummaryByDateRange,
    getCategoryBreakdown,
    getMonthlyFlow
};