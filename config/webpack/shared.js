// Note: You must restart bin/webpack-watcher for changes to take effect

const webpack = require('webpack')
const path = require('path')
const process = require('process')
const glob = require('glob')
const extname = require('path-complete-extname')

let distDir = process.env.WEBPACK_DIST_DIR

if (distDir === undefined) {
  distDir = 'packs'
}

const extensions = ['.js', '.coffee']
const extensionGlob = `*{${extensions.join(',')}}*`
const packPaths = glob.sync(path.join('app', 'javascript', 'packs', extensionGlob))

const config = {
  entry: packPaths.reduce(
    (map, entry) => {
      const basename = path.basename(entry, extname(entry))
      const localMap = map
      localMap[basename] = path.resolve(entry)
      return localMap
    }, {}
  ),

  output: { filename: '[name].js', path: path.resolve('public', distDir) },

  module: {
    rules: [
      { test: /\.coffee(\.erb)?$/, loader: 'coffee-loader' },


      {
        test: /\.jsx?(\.erb)?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          presets: [
            'react',
            ['env', { modules: false }]
          ],
          plugins: [
            'babel-plugin-transform-decorators-legacy'
          ]
        }
      },

      // module.exports = {
      //     babelrc: false,
      //     cacheDirectory: true,
      //     presets: [
      //         'babel-preset-es2015',
      //         'babel-preset-es2016',
      //         'babel-preset-react',
      //         'babel-preset-stage-0'
      //     ].map(require.resolve),
      //     plugins: [
      //         'babel-plugin-syntax-trailing-function-commas',
      //         'babel-plugin-transform-class-properties',
      //         'babel-plugin-transform-object-rest-spread',
      //         'babel-plugin-transform-decorators-legacy'
      //     ].map(require.resolve).concat([
      //         [require.resolve('babel-plugin-transform-runtime'), {
      //             helpers: false,
      //             polyfill: false,
      //             regenerator: true
      //         }]
      //     ])
      // };

      // loaders: [{
      //     test: /\.js$/,
      //     include: appSrc,
      //     loader: 'babel',
      //     // TODO(awong): Understand the dev/prod divergence in babel and either unify or conditional this.
      //     query: require('./babel.dev'),
      //
      //     // Speed up compilation.
      //     cacheDirectory: true
      // },

      {
        test: /\.erb$/,
        enforce: 'pre',
        exclude: /node_modules/,
        loader: 'rails-erb-loader',
        options: {
          runner: 'DISABLE_SPRING=1 bin/rails runner'
        }
      }
    ]
  },

  plugins: [
    new webpack.EnvironmentPlugin(Object.keys(process.env))
  ],

  resolve: {
    extensions,
    modules: [
      path.resolve('app/javascript'),
      path.resolve('node_modules')
    ]
  },

  resolveLoader: {
    modules: [path.resolve('node_modules')]
  }
}

module.exports = {
  distDir,
  config
}
