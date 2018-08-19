// Instead of rolling our own ruleset, extend React & Airbnb configs and override when necessary
module.exports = {
  root: true,

  parser: 'babel-eslint',

  // import plugin is termporarily disabled, scroll below to see why
  // plugins: [/*'import'*/],

  env: {
    browser: true,
    commonjs: true,
    es6: true,
    node: true
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
    "camelcase": 0,
    "react/destructuring-assignment":  0,
    "react/jsx-filename-extension": [1, { "extensions": [".js", ".jsx"] }]
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
    }
  },
};
