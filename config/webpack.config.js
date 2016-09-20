// Example webpack configuration with asset fingerprinting in production.
'use strict';

var autoprefixer = require('autoprefixer');
var path = require('path');
var webpack = require('webpack');
var StatsPlugin = require('stats-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

// must match config.webpack.dev_server.port
var devServerPort = 3808;

// set TARGET=production on the environment to add asset fingerprints
var production = process.env.TARGET === 'production';

var appSrc = path.join(__dirname, '../webpack');
var nodeModulesSrc = path.join(__dirname, '../node_modules');

var config = {
  entry: {
    'application': './webpack/application.js',
    'driving': './webpack/driver/index.js'
  },

  output: {
    // Build assets directly in to public/webpack/, let webpack know
    // that all webpacked assets start with webpack/

    // must match config.webpack.output_dir
    path: path.join(__dirname, '..', 'public', 'webpack'),
    publicPath: '/webpack/',

    filename: production ? '[name]-[chunkhash].js' : '[name].js'
  },

  resolve: {
    root: path.join(__dirname, '..', 'webpack')
  },

  module: {
// TODO(awong): Fix eslint.
//      preLoaders: [{
//          test: /\.js$/,
//          loader: 'eslint',
//          include: appSrc,
//      }],
      loaders: [{
          test: /\.js$/,
          include: appSrc,
          loader: 'babel',
          // TODO(awong): Understand the dev/prod divergence in babel and either unify or conditional this.
          query: require('./babel.dev'),

          // Speed up compilation.
          cacheDirectory: true
      }, {
          test: /\.css$/,
          include: [appSrc, nodeModulesSrc],
          loader: 'style!css!postcss'
      }, {
          test: /\.json$/,
          include: [appSrc, nodeModulesSrc],
          loader: 'json'
      }, {
          test: /\.(jpg|png|gif|eot|svg|ttf|woff|woff2)(\?.*)?$/,
          include: [appSrc, nodeModulesSrc],
          loader: 'file',
          query: {
              name: 'static/media/[name].[ext]'
          }
      }, {
          test: /\.(mp4|webm)(\?.*)?$/,
          include: [appSrc, nodeModulesSrc],
          loader: 'url',
          query: {
              limit: 10000,
              name: 'static/media/[name].[ext]'
          }
      }]
  },
  plugins: [
    // must match config.webpack.manifest_filename
    new webpack.DefinePlugin({ 'process.env.NODE_ENV': '"production"' }),
    new StatsPlugin('manifest.json', {
      // We only need assetsByChunkName
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true
    }),
    // TODO(awong): Ensure we extract the css correctly.
    new ExtractTextPlugin('[name].css')
  ],
  postcss: function() {
    return [autoprefixer];
  },
};

if (production) {
  // TODO(awong): Finish merging driver-app-migrate/config/webpack.config.prod.js
  config.plugins.push(
    new webpack.NoErrorsPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        screw_ie8: true,
        warnings: false
      },
      mangle: {
        screw_ie8: true
      },
      output: {
        comments: false,
        screw_ie8: true
      }
    }),
    // TODO(awong): Ensure react is configured for prod mode correctly.
    new webpack.DefinePlugin({
      'process.env': { NODE_ENV: JSON.stringify('production') }
    }),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin()
  );
} else {
  config.devServer = {
    port: devServerPort,
    headers: { 'Access-Control-Allow-Origin': '*' }
  };
  config.output.publicPath = '//localhost:' + devServerPort + '/';
  // TODO(awong): Ensure prod uses full source maps, not eval.
  // Source maps
  config.devtool = '#cheap-module-eval-source-map';
}

module.exports = config;
