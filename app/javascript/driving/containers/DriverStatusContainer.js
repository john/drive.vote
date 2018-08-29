import React from 'react';
import RideContainer from './RideContainer';
import Unavailable from '../components/Unavailable';
import Loading from '../components/Loading';

class DriverStatusContainer extends React.Component {
  componentDidMount() {
    this.props.fetchStatus();
  }

  render() {
    if (this.props.initialFetch) {
      return <Loading />;
    }
    if (this.props.available) {
      return <RideContainer {...this.props} />;
    }
    return (
      <Unavailable
        ride_zone_stats={this.props.ride_zone_stats}
        fetchRideZoneStats={this.props.fetchRideZoneStats}
        submitAvailable={this.props.submitAvailable}
      />
    );
  }
}

export default DriverStatusContainer;
