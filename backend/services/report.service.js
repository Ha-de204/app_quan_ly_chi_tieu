const { executeQuery, sql } = require('./db.service');

//lay tong chi va tong so du trong khoang time
const getSummaryByDateRange = async (user_id, startDate, endDate) => {
    const query = `
        SELECT
            SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS TotalExpense
        FROM Transactions
        WHERE user_id = @user_id
        AND date >= @startDate
        AND date <= @endDate;
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'startDate', type: sql.DateTime, value: startDate },
        { name: 'endDate', type: sql.DateTime, value: endDate }
    ]);

    const summary = result.recordset[0];
    return { TotalExpense: summary?.TotalExpense || 0 };
};

const getCategoryBreakdown = async (user_id, startDate, endDate) => {
    const query = `
        SELECT
            C.name AS category_name,
            C.icon_code_point,
            SUM(T.amount) AS TotalAmount
        FROM Transactions T
        INNER JOIN Category C ON T.category_id = C.category_id
        WHERE T.user_id = @user_id
        AND T.type = 'expense'
        AND T.date >= @startDate
        AND T.date <= @endDate
        GROUP BY C.name, C.icon_code_point
        ORDER BY TotalAmount DESC;
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'startDate', type: sql.DateTime, value: startDate },
        { name: 'endDate', type: sql.DateTime, value: endDate }
    ]);

    return result.recordset;
};

const getMonthlyFlow = async (user_id, year) => {
    const query = `
            SELECT
                 T.month_number,
                 ISNULL(SUM(T.TotalExpense), 0) AS TotalExpense,
                 ISNULL(B.budget_amount, 0) AS BudgetAmount,
                 ISNULL(B.budget_amount, 0) - ISNULL(SUM(T.TotalExpense), 0) AS NetBalance

            FROM (
                 SELECT
                     MONTH(date) AS Month,
                     SUM(amount) AS TotalExpense
                 FROM Transactions
                 WHERE user_id = @user_id
                 AND YEAR(date) = @year
                 AND type = 'expense'
                 GROUP BY MONTH(date)
            ) AS T
            LEFT JOIN Budget B ON B.period =
                 CONCAT(@year, '-', RIGHT('0' + CAST(T.month_number AS VARCHAR(2)), 2))
                 AND B.user_id = @user_id
                 AND (B.category_id IS NULL OR B.category_id = 0)
            GROUP BY T.month_number, B.budget_amount
            ORDER BY T.month_number;
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'year', type: sql.Int, value: year }
    ]);

    return result.recordset;
};

module.exports = {
    getSummaryByDateRange,
    getCategoryBreakdown,
    getMonthlyFlow
};