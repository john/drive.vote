import React from 'react';
import PropTypes from 'prop-types';
import Loading from './Loading';
import AvailableButton from './AvailableButton';

const buildRideZoneCallout = ({ available_drivers, scheduled_rides }) => {
  if (scheduled_rides) {
    return `There are ${scheduled_rides} people with scheduled rides, start driving to find a voter near you.`;
  }
  return `There are ${available_drivers} other drivers near you, start driving to find a voter near you.`;
};

class Unavilable extends React.Component {
  componentDidMount() {
    // TODO: Refresh this on an interval
    this.props.fetchRideZoneStats();
  }

  render() {
    const { ride_zone_stats, submitAvailable } = this.props;
    if (!ride_zone_stats) {
      return <Loading />;
    }
    return (
      <div className="searching-container">
        <div className="jumbotron text-center">
          <h1>
            <i className="fa fa-map text-info" />
          </h1>
          <p className="display-2">{buildRideZoneCallout(ride_zone_stats)}</p>
        </div>
        <AvailableButton submitAvailable={submitAvailable} />
      </div>
    );
  }
}

Unavilable.propTypes = {
  submitAvailable: PropTypes.func.isRequired,
  fetchRideZoneStats: PropTypes.func.isRequired,
  ride_zone_stats: PropTypes.shape({
    available_drivers: PropTypes.number.isRequired,
    scheduled_rides: PropTypes.number.isRequired,
  }),
};

export default Unavilable;
