const { environment } = require('@rails/webpacker')
const erbLoader = require('./loaders/erb')
const sassLoader = require('./loaders/sass')
// const aliases = require('./aliases')

// console.log(aliases)
//
// environment.config.merge(aliases)
// environment.splitChunks(
//   (config) =>
//     Object.assign({}, config, { optimization: { splitChunks: { chunks: 'all' } }})
// )
environment.splitChunks()
erbLoader(environment)
sassLoader(environment)
module.exports = environment
