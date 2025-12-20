const { executeQuery, sql } = require('./db.service');

// tao giao dich moi
const createTransaction = async (user_id, category_id, amount, type, date, title, note) => {
    const query = `
        INSERT INTO Transactions (user_id, category_id, amount, type, date, title, note)
        VALUES (@user_id, @category_id, @amount, @type, @date, @title, @note);
        SELECT SCOPE_IDENTITY() AS transaction_id;
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'category_id', type: sql.Int, value: category_id },
        { name: 'amount', type: sql.Real, value: amount },
        { name: 'type', type: sql.VarChar, value: type },
        { name: 'date', type: sql.DateTime, value: date },
        { name: 'title', type: sql.NVarChar, value: title },
        { name: 'note', type: sql.NVarChar, value: note || null }
    ]);

    return result.recordset[0].transaction_id;
};

// lay tat ca giao dich cua nguoi dung
const getTransactionsByUserId = async (user_id) => {
    const query = `
        SELECT
            T.transaction_id, T.amount, T.type, T.date, T.title, T.note,
            C.category_id, C.name AS category_name, C.icon_code_point
        FROM Transactions T
        INNER JOIN Category C ON T.category_id = C.category_id
        WHERE T.user_id = @user_id
        ORDER BY T.date DESC;
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id }
    ]);

    return result.recordset;
};

// lay chi tiet 1 giao dich
const getTransactionById = async (transaction_id, user_id) => {
    const query = `
        SELECT
            T.transaction_id, T.amount, T.type, T.date, T.title, T.note,
            C.category_id, C.name AS category_name, C.icon_code_point
        FROM Transactions T
        INNER JOIN Category C ON T.category_id = C.category_id
        WHERE T.transaction_id = @transaction_id AND T.user_id = @user_id;
    `;

    const result = await executeQuery(query, [
        { name: 'transaction_id', type: sql.Int, value: transaction_id },
        { name: 'user_id', type: sql.Int, value: user_id }
    ]);

    return result.recordset[0];
};

// update giao dich
const updateTransaction = async (transaction_id, user_id, category_id, amount, type, date, title, note) => {
    const query = `
        UPDATE Transactions
        SET
            category_id = @category_id,
            amount = @amount,
            type = @type,
            date = @date,
            title = @title,
            note = @note
        WHERE transaction_id = @transaction_id AND user_id = @user_id;
    `;

    // so luong hang bi anh huong
    const result = await executeQuery(query, [
        { name: 'transaction_id', type: sql.Int, value: transaction_id },
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'category_id', type: sql.Int, value: category_id },
        { name: 'amount', type: sql.Real, value: amount },
        { name: 'type', type: sql.VarChar, value: type },
        { name: 'date', type: sql.DateTime, value: date },
        { name: 'title', type: sql.NVarChar, value: title },
        { name: 'note', type: sql.NVarChar, value: note || null }
    ]);

    // tra ve true neu co hang update
    return result.rowsAffected[0] > 0;
};

// delete giao dich
const deleteTransaction = async (transaction_id, user_id) => {
    const query = `
        DELETE FROM Transactions
        WHERE transaction_id = @transaction_id AND user_id = @user_id;
    `;

    const result = await executeQuery(query, [
        { name: 'transaction_id', type: sql.Int, value: transaction_id },
        { name: 'user_id', type: sql.Int, value: user_id }
    ]);
    return result.rowsAffected && result.rowsAffected.length > 0 && result.rowsAffected[0] > 0;
};

module.exports = { createTransaction,
                   getTransactionsByUserId,
                   getTransactionById,
                   updateTransaction,
                   deleteTransaction
                  };