const { executeQuery, sql } = require('./db.service');

// update
const upsertBudget = async (user_id, category_id, amount, period) => {
    const checkQuery = `
        SELECT budget_id
        FROM Budget
        WHERE user_id = @user_id
        AND category_id = @category_id
        AND period = @period
    `;

    const existingBudget = await executeQuery(checkQuery, [
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'category_id', type: sql.Int, value: category_id },
        { name: 'period', type: sql.VarChar, value: period },
    ]);

    let budgetId;

    if (existingBudget.recordset.length > 0) {
        budgetId = existingBudget.recordset[0].budget_id;
        const updateQuery = `
            UPDATE Budget
            SET budget_amount = @amount
            WHERE budget_id = @budget_id;
        `;
        await executeQuery(updateQuery, [
            { name: 'budget_id', type: sql.Int, value: budgetId },
            { name: 'amount', type: sql.Real, value: amount }
        ]);
        return budgetId;

    } else {
        const insertQuery = `
            INSERT INTO Budget (user_id, category_id, budget_amount, period)
            VALUES (@user_id, @category_id, @amount, @period);
            SELECT SCOPE_IDENTITY() AS budget_id;
        `;
        const result = await executeQuery(insertQuery, [
            { name: 'user_id', type: sql.Int, value: user_id },
            { name: 'category_id', type: sql.Int, value: category_id },
            { name: 'amount', type: sql.Real, value: amount },
            { name: 'period', type: sql.VarChar, value: period },
        ]);
        return result.recordset[0].budget_id;
    }
};

const getBudgetsAmountPeriod = async (user_id, period) => {
    const year = period.substring(0, 4);
    const month = period.substring(5, 7);

    const yearInt = parseInt(year);
    const monthInt = parseInt(month);
    const startDate = `${year}-${month}-01`;
    const endDateObj = new Date(yearInt, monthInt, 0);
    const endDateString = `${endDateObj.getFullYear()}-${(endDateObj.getMonth() + 1).toString().padStart(2, '0')}-${endDateObj.getDate().toString().padStart(2, '0')}`;

    const query = `
        SELECT
            B.budget_id,
            B.budget_amount AS BudgetAmount,
            B.period,
            C.name AS category_name,
            C.icon_code_point,
            ISNULL(SUM(T.amount), 0) AS TotalSpent
        FROM Budget B
        INNER JOIN Category C ON B.category_id = C.category_id
        LEFT JOIN Transactions T ON B.category_id = T.category_id
                                   AND T.user_id = B.user_id
                                   AND T.type = 'expense'
                                   AND T.date >= @startDate
                                   AND T.date <= @endDate
        WHERE B.user_id = @user_id
        AND B.period = @period
        AND B.category_id IS NOT NULL
        AND B.category_id != 0
        GROUP BY B.budget_id, B.budget_amount, B.period, C.name, C.icon_code_point
        ORDER BY B.period DESC;
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'period', type: sql.VarChar, value: period },
        { name: 'startDate', type: sql.DateTime, value: startDate },
        { name: 'endDate', type: sql.DateTime, value: endDateString }
    ]);

    return result.recordset;
};

const getBudgetAmountByDateRange = async (user_id, startDate, endDate) => {
    const period = `${startDate.getFullYear()}-${(startDate.getMonth() + 1).toString().padStart(2, '0')}`;
    const query = `
        SELECT
            ISNULL(SUM(budget_amount), 0) AS BudgetAmount
        FROM
            Budget
        WHERE
            user_id = @user_id
            AND period = @period
            AND (category_id IS NULL OR category_id = 0);
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'period', type: sql.VarChar, value: period }
    ]);

    return result.recordset[0]?.BudgetAmount || 0;
};

const deleteBudget = async (budget_id, user_id) => {
    const query = `
        DELETE FROM Budget
        WHERE budget_id = @budget_id AND user_id = @user_id;
    `;

    const result = await executeQuery(query, [
        { name: 'budget_id', type: sql.Int, value: budget_id },
        { name: 'user_id', type: sql.Int, value: user_id }
    ]);

    return result.rowsAffected && result.rowsAffected.length > 0 && result.rowsAffected[0] > 0;
};

module.exports = {
    upsertBudget,
    getBudgetsAmountPeriod,
    getBudgetAmountByDateRange,
    deleteBudget
};