const express = require('express');
const router = express.Router();

router.get('/', (req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.status(200).json({
        message: 'orders were fetched'
    });
})

router.get('/:orderId', (req, res, next) => {
    res.status(200).json({
        message: 'order details',
        orderId: req.params.orderId
    });
})

module.exports = router;