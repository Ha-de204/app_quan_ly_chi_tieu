const { config, sql } = require('../config/db');

const pool = new sql.ConnectionPool(config);
let isConnected = false;

const connectDB = async () => {
    try {
        if (!isConnected) {
            await pool.connect();
            isConnected = true;
            console.log('✅ Kết nối SQL Server thành công!');
        }
        return pool;
    } catch (err) {
        isConnected = false;
        console.error('❌ Lỗi kết nối SQL Server:', err);
    }
};

const executeQuery = async (query, params = []) => {
    await connectDB();
    try {
        const request = pool.request();
        params.forEach(param => {
            request.input(param.name, param.type, param.value);
        });

        const result = await request.query(query);
        return result;

    } catch (err) {
        console.error('Lỗi thực thi truy vấn:', err.message);
        throw err;
    }
};

module.exports = { executeQuery, connectDB, sql };