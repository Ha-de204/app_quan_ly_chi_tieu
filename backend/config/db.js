require('dotenv').config();
const mongoose = require('mongoose');
const config = {
    url: process.env.MONGO_URI,
};

module.exports = { config, mongoose };