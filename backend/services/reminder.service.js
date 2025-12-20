const { executeQuery, sql } = require('./db.service');

// tao loi nhac moi
const createReminder = async (user_id, title, message, dueDate, frequency) => {
    const query = `
        INSERT INTO Reminder (user_id, title, message, due_date, frequency, is_enabled)
        VALUES (@user_id, @title, @message, @dueDate, @frequency, 1);
        SELECT SCOPE_IDENTITY() AS reminder_id;
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'title', type: sql.NVarChar, value: title },
        { name: 'message', type: sql.NVarChar, value: message || null },
        { name: 'dueDate', type: sql.DateTime, value: dueDate },
        { name: 'frequency', type: sql.VarChar, value: frequency }
    ]);

    return result.recordset[0].reminder_id;
};

// lay tat ca loi nhac
const getRemindersByUserId = async (user_id) => {
    const query = `
        SELECT reminder_id, title, message, due_date, frequency, is_enabled
        FROM Reminder
        WHERE user_id = @user_id
        ORDER BY due_date ASC;
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id }
    ]);

    return result.recordset;
};

// lay chi tiet 1 loi nhac
const getReminderById = async (reminder_id, user_id) => {
    const query = `
        SELECT reminder_id, title, message, due_date, frequency, is_enabled
        FROM Reminder
        WHERE reminder_id = @reminder_id AND user_id = @user_id;
    `;

    const result = await executeQuery(query, [
        { name: 'reminder_id', type: sql.Int, value: reminder_id },
        { name: 'user_id', type: sql.Int, value: user_id }
    ]);

    return result.recordset[0];
};

// update loi nhac
const updateReminder = async (reminder_id, user_id, title, message, dueDate, frequency, isEnabled) => {
    const query = `
        UPDATE  Reminder
        SET
            title = @title,
            message = @message,
            due_date = @dueDate,
            frequency = @frequency,
            is_enabled = @isEnabled
        WHERE reminder_id = @reminder_id AND user_id = @user_id;
    `;

    const result = await executeQuery(query, [
        { name: 'reminder_id', type: sql.Int, value: reminder_id },
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'title', type: sql.NVarChar, value: title },
        { name: 'message', type: sql.NVarChar, value: message || null },
        { name: 'dueDate', type: sql.DateTime, value: dueDate },
        { name: 'frequency', type: sql.VarChar, value: frequency },
        { name: 'isEnabled', type: sql.Bit, value: isEnabled }
    ]);

    return result.rowsAffected[0] > 0;
};

// delete loi nhac
const deleteReminder = async (reminder_id, user_id) => {
    const query = `
        DELETE FROM Reminder
        WHERE reminder_id = @reminder_id AND user_id = @user_id;
    `;

    const result = await executeQuery(query, [
        { name: 'reminder_id', type: sql.Int, value: reminder_id },
        { name: 'user_id', type: sql.Int, value: user_id }
    ]);

    return result.rowsAffected[0] > 0;
};

module.exports = {
    createReminder,
    getRemindersByUserId,
    getReminderById,
    updateReminder,
    deleteReminder
};