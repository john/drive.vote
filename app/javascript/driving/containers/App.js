import React from 'react';
import PropTypes from 'prop-types';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as actionCreators from '../actions/actionCreators';
import * as rideActions from '../actions/rides';

import Header from '../components/Header';
import AppError from '../components/AppError';

const AppUnconnected = props => (
  <div className={props.isFetching ? 'fetching' : ''}>
    <Header
      phone_number={props.ride_zone_stats.phone_number}
      ride_zone_id={props.ride_zone_id}
    />
    <AppError error={props.error} clearError={props.clearError} />
    <div className="container p-a-0">
      {React.cloneElement(props.children, props)}
    </div>
  </div>
);

function mapStateToProps(state) {
  return {
    ...state.appState,
    rides: state.rides,
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ ...actionCreators, ...rideActions }, dispatch);
}

const App = connect(
  mapStateToProps,
  mapDispatchToProps
)(AppUnconnected);

AppUnconnected.defaultProps = {
  ride_zone_stats: {},
};

AppUnconnected.propTypes = {
  isFetching: PropTypes.bool.isRequired,
  children: PropTypes.node,
  clearError: PropTypes.func.isRequired,
  error: PropTypes.string,
  ride_zone_id: PropTypes.number,
  ride_zone_stats: PropTypes.object,
};

export default App;
