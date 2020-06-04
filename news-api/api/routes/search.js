const fetch = require('node-fetch');
const express = require('express');
const router = express.Router();

function parseGuardian(myJson) {
    let articles = [];
    const results = myJson.response.results;
    for (let result of results) {
        const title = result.webTitle;
        const date = result.webPublicationDate;
        const section = result.sectionName;
        let image = '';
        if (result.blocks && result.blocks.main && result.blocks.main.elements && result.blocks.main.elements[0] && result.blocks.main.elements[0].assets && result.blocks.main.elements[0].assets.length > 0) {
            let index = result.blocks.main.elements[0].assets.length - 1
            if (result.blocks.main.elements[0].assets[index] && result.blocks.main.elements[0].assets[index].file) {
                image = result.blocks.main.elements[0].assets[index].file;
            }
        }
        const id = result.id;
        const url = result.webUrl;

        articles.push({
            title: title,
            date: date,
            section: section,
            image: image,
            id: id,
            url: url
        });
    }
    return articles;
}

router.get('/:keyword', (req, res, next) => {
    let keyword = req.params.keyword;

    fetch('https://content.guardianapis.com/search?q=' + keyword + '&api-key=e635f283-c7d0-4762-bf39-c713fa65f063&show-blocks=all')
        .then(response => {
            return response.json();
        })
        .then(myJson => {
            return parseGuardian(myJson);
        })
        .then(articles => {
            res.header('Access-Control-Allow-Origin', '*');
            res.status(200).json({ 'articles': articles });
        });

})

module.exports = router;