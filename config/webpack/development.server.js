// Note: You must restart bin/webpack-dev-server for changes to take effect

const { resolve } = require('path')
const merge = require('webpack-merge')
const devConfig = require('./development.js')
const { devServer, publicPath, paths } = require('./configuration.js')

module.exports = merge(devConfig, {
  devServer: {
    host: devServer.host,
    port: devServer.port,
    compress: true,
    // TODO: Figure out if there are security implications for this in even in local dev
    disableHostCheck: true,
    historyApiFallback: true,
    contentBase: resolve(paths.output, paths.entry),
    publicPath
  }
})
