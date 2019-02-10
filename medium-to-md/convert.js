const mediumToMarkdown = require('medium-to-markdown');

// Example
// $ node convert.js https://medium.com/consensys-diligence/how-to-exploit-ethereum-in-a-virtual-environment-cffd0be6223c
mediumToMarkdown.convertFromUrl(process.argv[2]).then(function (markdown) {
    console.log(markdown); //=> Markdown content of medium post
});

