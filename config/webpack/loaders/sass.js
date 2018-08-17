const ExtractTextPlugin = require('extract-text-webpack-plugin')

module.exports = {
  test: /\.(scss|sass|css)$/i,
  use: ExtractTextPlugin.extract({
    fallback: 'style-loader',
    use: [
      'css-loader',
      { 
        loader: 'postcss-loader', 
        options: {  plugins: function() { return []; }} 
      },
      'sass-loader']
  })
}
