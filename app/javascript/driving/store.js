import { createStore, compose, applyMiddleware } from 'redux';
import promiseMiddleware from 'redux-promise-middleware';
import { syncHistoryWithStore } from 'react-router-redux';
import { browserHistory } from 'react-router';

import thunk from 'redux-thunk';

import rootReducer from './reducers/rootReducer';

function getMiddleware() {
  const middleware = [thunk, promiseMiddleware()];

  // if (process.env.NODE_ENV !== 'production') {
  //   const { createLogger } = require('redux-logger'); // eslint-disable-line global-require
  //   const logger = createLogger({
  //     collapsed: true,
  //   });
  //   middleware.push(logger);
  // }

  return middleware;
}

const store = createStore(
  rootReducer,
  compose(
    applyMiddleware(...getMiddleware()),
    window.devToolsExtension ? window.devToolsExtension() : f => f
  )
);
export const history = syncHistoryWithStore(browserHistory, store);

export default store;
