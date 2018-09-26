import React from 'react';
import PropTypes from 'prop-types';
import RideContainer from './RideContainer';
import Unavailable from '../components/Unavailable';
import Loading from '../components/Loading';

const FETCH_STATUS_INTERVAL = 60000;

class DriverStatusContainer extends React.Component {
  componentDidMount() {
    this.props.fetchStatus();

    this.statusInterval = setInterval(
      () => this.props.fetchStatus(),
      FETCH_STATUS_INTERVAL
    );
  }

  componentWillUnmount() {
    clearInterval(this.statusInterval);
  }

  render() {
    if (this.props.initialFetch) {
      return <Loading />;
    }
    if (this.props.available) {
      return (
        <div className={this.props.rides.isFetching ? 'fetching' : ''}>
          <RideContainer {...this.props} />
        </div>
      );
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

DriverStatusContainer.propTypes = {
  available: PropTypes.bool.isRequired,
  fetchStatus: PropTypes.func.isRequired,
  fetchRideZoneStats: PropTypes.func.isRequired,
  initialFetch: PropTypes.bool.isRequired,
  ride_zone_stats: PropTypes.object,
  submitAvailable: PropTypes.func.isRequired,
};

export default DriverStatusContainer;
