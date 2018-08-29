import React from 'react';
import PropTypes from 'prop-types';
import Loading from './Loading';
import AvailableButton from './AvailableButton';

class Unavilable extends React.Component {
  componentDidMount() {
    // TODO: Refresh this on an interval
    this.props.fetchRideZoneStats();
  }

  buildRideZoneCallout() {
    const {
      ride_zone_stats: { available_drivers, scheduled_rides },
    } = this.props;

    if (scheduled_rides) {
      return `There are ${scheduled_rides} people with scheduled rides, start driving to find a voter near you.`;
    }

    return `There are ${
      stats.available_drivers
    } other drivers near you, start driving to find a voter near you.`;
  }

  render() {
    if (!this.props.ride_zone_stats) {
      return <Loading />;
    }
    return (
      <div className="searching-container">
        <div className="jumbotron text-center">
          <h1>
            <i className="fa fa-map text-info" />
          </h1>
          <p className="display-2">{this.buildRideZoneCallout()}</p>
        </div>
        <AvailableButton submitAvailable={this.props.submitAvailable} />
      </div>
    );
  }
}

Unavilable.propTypes = {
  submitAvailable: PropTypes.func.isRequired,
  fetchRideZoneStats: PropTypes.func.isRequired,
};

export default Unavilable;
