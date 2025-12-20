const { executeQuery, sql } = require('./db.service');
// lay danh muc mac dinh va danh muc tuy chinh cua user
const getCategoriesByUser = async (user_id) => {
    const query = `
            SELECT category_id, name, icon_code_point
            FROM Category
            WHERE [is_default] = 1 OR [user_id] = @user_id
            ORDER BY [is_default] DESC, [name] ASC
        `;

    const result = await executeQuery(query, [
            { name: 'user_id', type: sql.Int, value: user_id }
    ]);
    return result.recordset;
};

// tao danh muc moi
const createCategory = async (user_id, name, iconCodePoint) => {
    const query = `
        INSERT INTO Category (user_id, name, icon_code_point, is_default)
        VALUES (@user_id, @name, @iconCodePoint, 0);
        SELECT SCOPE_IDENTITY() AS category_id;
    `;

    const result = await executeQuery(query, [
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'name', type: sql.NVarChar, value: name },
        { name: 'iconCodePoint', type: sql.Int, value: iconCodePoint }
    ]);

    return result.recordset[0].category_id;
};

// update danh muc
const updateCategory = async (categoryId, user_id, name, iconCodePoint) => {
    const query = `
        UPDATE Category
        SET
            name = @name,
            icon_code_point = @iconCodePoint
        WHERE category_id = @categoryId AND user_id = @user_id AND is_default = 0;
    `;

    const result = await executeQuery(query, [
        { name: 'categoryId', type: sql.Int, value: categoryId },
        { name: 'user_id', type: sql.Int, value: user_id },
        { name: 'name', type: sql.NVarChar, value: name },
        { name: 'iconCodePoint', type: sql.Int, value: iconCodePoint }
    ]);

    return result.rowsAffected[0] > 0;
};

// delete danh muc
const deleteCategory = async (categoryId, user_id) => {
    const query = `
        DELETE FROM Category
        WHERE category_id = @categoryId AND user_id = @user_id AND is_default = 0;
    `;

    const result = await executeQuery(query, [
        { name: 'categoryId', type: sql.Int, value: categoryId },
        { name: 'user_id', type: sql.Int, value: user_id }
    ]);

    return result.rowsAffected[0] > 0;
};

module.exports = {
    getCategoriesByUser,
    createCategory,
    updateCategory,
    deleteCategory
};