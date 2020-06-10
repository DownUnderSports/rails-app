const path = require('path'),
      root = path.resolve(__dirname, '../../', 'app/media')

module.exports = {
  resolve: {
    alias: {
      "@": root,
      "@assets": path.resolve(root, 'assets'),
      "@channels": path.resolve(root, 'channels'),
      "@components": path.resolve(root, 'components'),
      "@constants": path.resolve(root, 'constants'),
      "@contexts": path.resolve(root, 'contexts'),
      "@forms": path.resolve(root, 'forms'),
      "@helpers": path.resolve(root, 'helpers'),
      "@packs": path.resolve(root, 'packs'),
      "@polyfills": path.resolve(root, 'polyfills'),
      "@views": path.resolve(root, 'views'),
    }
  }
}
