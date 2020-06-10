const { environment } = require('@rails/webpacker')
const erbLoader = require('./loaders/erb')
const sassLoader = require('./loaders/sass')
// const aliases = require('./aliases')

// console.log(aliases)
//
// environment.config.merge(aliases)
erbLoader(environment)
sassLoader(environment)
module.exports = environment
