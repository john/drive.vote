
const loader =
process.env.NODE_ENV === "production"
  ? "babel-loader"
  : "babel-loader?cacheDirectory=true";

module.exports = {
  test: /\.js(\.erb)?$/,
  exclude: /node_modules/,
  loader,
  options: {
    presets: [ "react", "env", "stage-0"],
  }
}