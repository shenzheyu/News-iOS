const fetch = require('node-fetch');
const express = require('express');
const router = express.Router();

function parseGuardian(myJson) {
    const result = myJson.response.content;

    const title = result.webTitle;
    let description = ''
    if (result.blocks && result.blocks.body) {
        for (let i = 0; i < result.blocks.body.length; i++) {
            description += result.blocks.body[i].bodyHtml;
        }
    }
    const date = result.webPublicationDate;
    let image = '';
    if (result.blocks && result.blocks.main && result.blocks.main.elements && result.blocks.main.elements[0] && result.blocks.main.elements[0].assets && result.blocks.main.elements[0].assets.length > 0) {
        const index = result.blocks.main.elements[0].assets.length - 1;
        image = result.blocks.main.elements[0].assets[index].file;
    }
    const url = result.webUrl;
    const section = result.sectionId;

    const article = {
        title: title,
        description: description,
        date: date,
        image: image,
        url: url,
        section: section
    };

    return article;
}

router.get('/', (req, res, next) => {
    const id = req.query.id;

    fetch('https://content.guardianapis.com/' + id + '?api-key=e635f283-c7d0-4762-bf39-c713fa65f063&show-blocks=all')
        .then(response => {
            return response.json();
        })
        .then(myJson => {
            return parseGuardian(myJson);
        })
        .then(article => {
            res.header('Access-Control-Allow-Origin', '*');
            res.status(200).json({ 'article': article });
        });
})

module.exports = router;