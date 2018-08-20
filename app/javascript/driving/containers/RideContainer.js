import React from 'react';
import WaitingRidesContainer from './WaitingRidesContainer';
import ActiveRide from '../components/ActiveRide';

class RideContainer extends React.Component {
  componentDidMount() {
    const {
      fetchWaitingRides,
      submitLocation,
      state: {
        driverState: {
          location,
          update_location_interval,
          waiting_rides_interval,
        },
      },
    } = this.props;
    // Immediately send location instead of waiting for first interval to hit:
    submitLocation(location);

    this.locationInterval = setInterval(
      () => submitLocation(location),
      update_location_interval
    );
    this.ridesInterval = setInterval(
      () => fetchWaitingRides(location),
      waiting_rides_interval
    );
  }

  UNSAFE_componentWillReceiveProps({
    state: {
      driverState: {
        waiting_rides_interval: nextRidesInterval,
        update_location_interval: nextLocationInterval,
      },
    },
  }) {
    const {
      fetchWaitingRides,
      submitLocation,
      state: {
        driverState: {
          location,
          update_location_interval,
          waiting_rides_interval,
        },
      },
    } = this.props;

    if (nextRidesInterval && waiting_rides_interval !== nextRidesInterval) {
      clearInterval(this.ridesInterval);
      this.ridesInterval = setInterval(
        () => fetchWaitingRides(location),
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
    const { active_ride } = this.props.state.driverState;
    if (!active_ride) {
      return <WaitingRidesContainer {...this.props} />;
    }
    return <ActiveRide ride={active_ride} {...this.props} />;
  }
}

export default RideContainer;
