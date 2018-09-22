import { createStore, compose, applyMiddleware } from 'redux';
import promiseMiddleware from 'redux-promise-middleware';
import { syncHistoryWithStore } from 'react-router-redux';
import { browserHistory } from 'react-router';

import thunk from 'redux-thunk';

import rootReducer from './reducers/rootReducer';

function getMiddleware() {
  const middleware = [thunk, promiseMiddleware()];

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
