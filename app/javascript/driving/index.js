import React from 'react';
import { render } from 'react-dom';
import { Router, Route, IndexRoute } from 'react-router';
import { Provider } from 'react-redux';
import store, { history } from './store';
import App from './containers/App';
import LocationManager from './containers/LocationManager';

require('./styles/drive-vote.css');

const router = (
  <Provider store={store}>
    <Router history={history}>
      <Route path="/driving"  component={App}>
        <IndexRoute component={LocationManager}></IndexRoute>
      </Route>
    </Router>
  </Provider>
)

render(router, document.getElementById('root'));
