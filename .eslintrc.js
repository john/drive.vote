module.exports = {
  root: true,

  parser: 'babel-eslint',

  // import plugin is termporarily disabled, scroll below to see why
  // plugins: [/*'import'*/],

  env: {
    browser: true,
    commonjs: true,
    es6: true,
    node: true,
    jest: true,
  },
  extends: ['plugin:react/recommended', 'airbnb-base', 'prettier'],
  parserOptions: {
    ecmaVersion: 6,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
      generators: true,
      experimentalObjectRestSpread: true
    }
  },

  rules: {
    "camelcase": 0, // API data is returned as snake_case
    "react/destructuring-assignment":  0, // This doesn’t make sense for one-liners, which pop up a lot.
    "react/jsx-filename-extension": [1, { "extensions": [".js", ".jsx"] }]  // Allow .js for React components, default is .jsx only
  },

  settings: {
    'import/ignore': [
      'node_modules',
      '\\.(json|css|jpg|png|gif|eot|svg|ttf|woff|woff2|mp4|webm)$',
    ],
    'import/extensions': ['.js'],
    'import/resolver': {
      node: {
        extensions: ['.js', '.json']
      }
    },
    "react": {
      "version": "16.4.2",
    },
  },
};
