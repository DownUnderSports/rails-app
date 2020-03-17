const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const aliases = require('./aliases')

console.log(aliases)

environment.config.merge(aliases)

environment.loaders.prepend('erb', erb)
module.exports = environment
