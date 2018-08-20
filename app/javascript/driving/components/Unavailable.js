import React from 'react';
import Loading from './Loading';
import AvailableButton from './AvailableButton';

class Unavilable extends React.Component {
  componentDidMount() {
    this.props.fetchRideZoneStats();
  }

  render() {
    const stats = this.props.state.driverState.ride_zone_stats;
    let sentence = ``;
    if (stats) {
      if (stats.scheduled_rides > 0) {
        sentence = `There are ${
          stats.scheduled_rides
        } people with scheduled rides, start driving to find a voter near you.`;
      } else {
        sentence = `There are ${
          stats.available_drivers
        } other drivers near you, start driving to find a voter near you.`;
      }
      return (
        <div className="searching-container">
          <div className="jumbotron text-center">
            <h1>
              <i className="fa fa-map text-info" />
            </h1>
            <p className="display-2">{sentence}</p>
          </div>
          <AvailableButton submitAvailable={this.props.submitAvailable} />
        </div>
      );
    }
    return <Loading />;
  }
}

export default Unavilable;
