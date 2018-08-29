import React from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as actionCreators from '../actions/actionCreators';

import Header from '../components/Header';
import AppError from '../components/AppError';

const AppUnconnected = props => (
  <div className={props.changePending ? 'fetching' : ''}>
    <Header ride_zone_id={props.ride_zone_id} />
    <AppError
      errorState={props.error}
      clearError={props.clearError}
    />
    <div className="container p-a-0">
      {React.cloneElement(props.children, props)}
    </div>
  </div>
);

function mapStateToProps(state) {
  return {
    ...state.driverState
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(actionCreators, dispatch);
}

const App = connect(
  mapStateToProps,
  mapDispatchToProps
)(AppUnconnected);

export default App;
