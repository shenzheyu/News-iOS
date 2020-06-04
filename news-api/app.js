const express = require('express');
const app = express();
const morgan = require('morgan');

const productRoutes = require('./api/routes/products');
const orderRoutes = require('./api/routes/orders');
const articlesRoutes = require('./api/routes/articles');
const detailRoutes = require('./api/routes/detail');
const searchRoutes = require('./api/routes/search');
const trendsRoutes = require('./api/routes/trends');

app.use(morgan('dev'));

// Routes which should handle requests
app.use('/products', productRoutes);
app.use('/orders', orderRoutes);
app.use('/articles', articlesRoutes);
app.use('/detail', detailRoutes);
app.use('/search', searchRoutes);
app.use('/trends', trendsRoutes);

module.exports = app;