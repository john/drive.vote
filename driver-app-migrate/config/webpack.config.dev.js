var path = require('path');
var autoprefixer = require('autoprefixer');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin');
var paths = require('./paths');

module.exports = {
    devtool: 'eval',

    // Quickfix to get this working in Rails
    // TODO: Fix this
    // entry: [
    //   require.resolve('webpack-dev-server/client') + '?/http://localhost:3001',
    //   require.resolve('webpack/hot/dev-server'),
    //   require.resolve('./polyfills'),
    //   path.join(paths.appSrc, 'index')
    // ],

    entry: [
        './src/index.js'
    ],
    output: {
        // Next line is not used in dev but WebpackDevServer crashes without it:
        path: paths.appBuild,
        pathinfo: true,
        filename: 'static/js/bundle.js',
        publicPath: '/'
    },
    resolve: {
        extensions: ['', '.js', '.json'],
        alias: {
            'babel-runtime/regenerator': require.resolve('babel-runtime/regenerator')
        }
    },
    resolveLoader: {
        root: paths.ownNodeModules,
        moduleTemplates: ['*-loader']
    },
    module: {
        preLoaders: [{
            test: /\.js$/,
            loader: 'eslint',
            include: paths.appSrc,
        }],
        loaders: [{
            test: /\.js$/,
            include: paths.appSrc,
            loader: 'babel',
            query: require('./babel.dev')
        }, {
            test: /\.css$/,
            include: [paths.appSrc, paths.appNodeModules],
            loader: 'style!css!postcss'
        }, {
            test: /\.json$/,
            include: [paths.appSrc, paths.appNodeModules],
            loader: 'json'
        }, {
            test: /\.(jpg|png|gif|eot|svg|ttf|woff|woff2)(\?.*)?$/,
            include: [paths.appSrc, paths.appNodeModules],
            loader: 'file',
            query: {
                name: 'static/media/[name].[ext]'
            }
        }, {
            test: /\.(mp4|webm)(\?.*)?$/,
            include: [paths.appSrc, paths.appNodeModules],
            loader: 'url',
            query: {
                limit: 10000,
                name: 'static/media/[name].[ext]'
            }
        }]
    },
    eslint: {
        configFile: path.join(__dirname, 'eslint.js'),
        useEslintrc: false
    },
    postcss: function() {
        return [autoprefixer];
    },
    plugins: [
        new HtmlWebpackPlugin({
            inject: true,
            template: paths.appHtml,
            favicon: paths.appFavicon,
        }),
        new webpack.DefinePlugin({ 'process.env.NODE_ENV': '"development"' }),
        // Note: only CSS is currently hot reloaded
        // new webpack.HotModuleReplacementPlugin(),
        new CaseSensitivePathsPlugin()
    ]
};
