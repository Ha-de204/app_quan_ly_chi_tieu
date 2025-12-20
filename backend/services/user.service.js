const { executeQuery, sql } = require('./db.service');

const findUserByEmail = async (email) => {
    const query = `
        SELECT user_id, password_hash, name
        FROM Users
        WHERE email = @email;
    `;
    const result = await executeQuery(query, [{ name: 'email', type: sql.NVarChar, value: email }]);
    return result.recordset[0];
};

const createUser = async (email, passwordHash, name) => {
    const query = `
        INSERT INTO Users (email, password_hash, name, created_at)
        VALUES (@email, @passwordHash, @name, GETDATE());
        SELECT SCOPE_IDENTITY() AS user_id;
    `;

    const result = await executeQuery(query, [
        { name: 'email', type: sql.NVarChar, value: email },
        { name: 'passwordHash', type: sql.NVarChar, value: passwordHash },
        { name: 'name', type: sql.NVarChar, value: name || null }
    ]);

    return result.recordset[0].user_id;
};

const getUserById = async (user_id) => {
    const query = `
        SELECT user_id, email, name, created_at
        FROM Users
        WHERE user_id = @user_id;
    `;
    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id }
    ]);
    return result.recordset[0];
};

module.exports = { findUserByEmail, createUser, getUserById };