const mediumToMarkdown = require('medium-to-markdown');

// Enter url here
mediumToMarkdown.convertFromUrl(process.argv[2]).then(function (markdown) {
    console.log(markdown); //=> Markdown content of medium post
});

