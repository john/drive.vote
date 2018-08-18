import React from 'react';
import WaitingRidesContainer from './WaitingRidesContainer';
import ActiveRide from '../components/ActiveRide';

class RideContainer extends React.Component {
  componentDidMount() {
    this.locationInterval = setInterval(
      () => this.props.submitLocation(this.props.state.driverState.location),
      this.props.state.driverState.update_location_interval
    );
    this.ridesInterval = setInterval(
      () => this.props.fetchWaitingRides(this.props.state.driverState.location),
      this.props.state.driverState.waiting_rides_interval
    );
  }

  componentWillReceiveProps(nextProps) {
    const currentRidesInterval = this.props.state.driverState
      .waiting_rides_interval;
    const nextRidesInterval =
      nextProps.state.driverState.waiting_rides_interval;
    const currentLoactionInterval = this.props.state.driverState
      .update_location_interval;
    const nextLocationInterval =
      nextProps.state.driverState.update_location_interval;
    if (nextRidesInterval && currentRidesInterval !== nextRidesInterval) {
      clearInterval(this.ridesInterval);
      this.ridesInterval = setInterval(
        () =>
          this.props.fetchWaitingRides(this.props.state.driverState.location),
        nextRidesInterval
      );
    }
    if (
      nextLocationInterval &&
      currentLoactionInterval !== nextLocationInterval
    ) {
      clearInterval(this.locationInterval);
      this.locationInterval = setInterval(
        () => this.props.submitLocation(this.props.state.driverState.location),
        nextLocationInterval
      );
    }
  }

  componentWillUnmount() {
    clearInterval(this.locationInterval);
    clearInterval(this.ridesInterval);
  }

  render() {
    if (this.props.state.driverState.active_ride) {
      return (
        <ActiveRide
          {...this.props}
          ride={this.props.state.driverState.active_ride}
        />
      );
    }
    return <WaitingRidesContainer {...this.props} />;
  }
}

export default RideContainer;
