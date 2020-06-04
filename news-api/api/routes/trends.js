const googleTrends = require('google-trends-api');
const express = require('express');
const router = express.Router();

router.get('/:keyword', (req, res, next) => {
    let keyword = req.params.keyword;

    googleTrends.interestOverTime({ keyword: keyword, startTime: new Date('2019-06-01') })
        .then(results => {
            let json = JSON.parse(results)
            var values = []
            for (let data of json.default.timelineData) {
                values.push(data.value[0])
            }
            res.header('Access-Control-Allow-Origin', '*');
            res.status(200).json({"values": values});
        })
        .catch(function (err) {
            console.error('Oh no there was an error', err);
        });
})

module.exports = router;