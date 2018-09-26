import React from 'react';
import PropTypes from 'prop-types';

import WaitingRidesContainer from './WaitingRidesContainer';
import ActiveRide from '../components/ActiveRide';

class RideContainer extends React.Component {
  componentDidMount() {
    const {
      fetchRides,
      submitLocation,

      location,
      update_location_interval,
      waiting_rides_interval,
    } = this.props;
    // Immediately send location instead of waiting for first interval to hit:
    submitLocation(location);
    fetchRides(location);

    this.locationInterval = setInterval(
      () => submitLocation(location),
      update_location_interval
    );
    this.ridesInterval = setInterval(
      () => fetchRides(location),
      waiting_rides_interval
    );
  }

  /**
   * Update interval functions if API-based delays have changed
   */
  UNSAFE_componentWillReceiveProps({
    waiting_rides_interval: nextRidesInterval,
    update_location_interval: nextLocationInterval,
  }) {
    const {
      fetchRides,
      submitLocation,
      location,
      update_location_interval,
      waiting_rides_interval,
    } = this.props;

    if (nextRidesInterval && waiting_rides_interval !== nextRidesInterval) {
      clearInterval(this.ridesInterval);
      this.ridesInterval = setInterval(
        () => fetchRides(location),
        nextRidesInterval
      );
    }

    if (
      nextLocationInterval &&
      update_location_interval !== nextLocationInterval
    ) {
      clearInterval(this.locationInterval);
      this.locationInterval = setInterval(
        () => submitLocation(location),
        nextLocationInterval
      );
    }
  }

  componentWillUnmount() {
    clearInterval(this.locationInterval);
    clearInterval(this.ridesInterval);
  }

  render() {
    if (!this.props.rides.active_ride) {
      return <WaitingRidesContainer {...this.props} />;
    }
    return <ActiveRide ride={this.props.rides.active_ride} {...this.props} />;
  }
}

RideContainer.propTypes = {
  active_ride: PropTypes.object,
  fetchRides: PropTypes.func.isRequired,
  submitLocation: PropTypes.func.isRequired,
  update_location_interval: PropTypes.number.isRequired,
  waiting_rides_interval: PropTypes.number.isRequired,
};

export default RideContainer;
