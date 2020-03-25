module.exports = function(environment){
  environment.loaders.prepend('erb', {
    test: /\.erb$/,
    enforce: 'pre',
    exclude: /node_modules/,
    use: [{
      loader: 'rails-erb-loader',
      options: {
        runner: (/^win/.test(process.platform) ? 'ruby ' : '') + 'bin/rails runner'
      }
    }]
  })
}
