import React from 'react';
import ContactVoter from './ContactVoter';
import DispatchMatch from './DispatchMatch';

class ActiveRide extends React.Component {
  render() {
    const { ride, completeRide, pickupRider, cancelRide } = this.props;
    let mapLink;
    const passengers = 1 + parseInt(ride.additional_passengers, 10);

    switch (ride.status) {
      case 'waiting_acceptance':
        return <DispatchMatch ride={this.ride} {...this.props} />;
      case 'driver_assigned':
        mapLink = `https://maps.apple.com/?daddr=${ride.from_address}, ${
          ride.from_city
        }, ${ride.from_state}`;
        return (
          <div className="panel panel-full p-y-sm">
            <a
              className="directionsLink"
              target="_blank"
              rel="noopener noreferrer"
              href={mapLink}
            >
              <i className="fa fa-map-marker" />
              Directions
            </a>
            <span className="label">Picking up:</span>
            <h3>{ride.name}</h3>
            <p>
              {ride.from_address}
              <br />
              {`${ride.from_city},${ride.from_state} ${ride.from_zip}`}
            </p>
            <ContactVoter voter_phone_number={ride.voter_phone_number} />
            <div className="secondary-info">
              <p>
                Total Passengers:
                {passengers}
              </p>
              <p>
                Special requests:
                {ride.special_requests}
              </p>
            </div>
            <div className="bottom-controls secondary">
              <button
                type="button"
                className="btn btn-success btn-api"
                onClick={() => pickupRider(ride)}
              >
                Rider picked up
              </button>
              <button
                type="button"
                className="btn btn-danger btn-api"
                onClick={() => cancelRide(ride)}
              >
                Cancel Ride
              </button>
            </div>
          </div>
        );
      case 'picked_up':
        mapLink = `https://maps.apple.com/?daddr=${ride.to_address}, ${
          ride.to_city
        }, ${ride.to_state}`;
        return (
          <div className="panel panel-full p-y-sm">
            <a
              className="directionsLink"
              target="_blank"
              rel="noopener noreferrer"
              href={mapLink}
            >
              <i className="fa fa-map-marker" />
              Directions
            </a>
            <span className="label">Dropping off:</span>
            <h3>{ride.name}</h3>
            <p>
              {ride.to_address}
              <br />
              {`${ride.from_city},${ride.from_state} ${ride.from_zip}`}
            </p>
            <ContactVoter voter_phone_number={ride.voter_phone_number} />
            <div className="secondary-info">
              <p>
                Total Passengers:
                {passengers}
              </p>
              <p>
                Special requests:
                {ride.special_requests}
              </p>
            </div>
            <div className="bottom-controls secondary">
              <button
                type="button"
                className="btn btn-success btn-api"
                onClick={() => completeRide(ride)}
              >
                Complete Ride
              </button>
              <button
                type="button"
                className="btn btn-danger btn-api"
                onClick={() => cancelRide(ride)}
              >
                Cancel Ride
              </button>
            </div>
          </div>
        );
      default:
        return (
          <div className="panel panel-full p-y-sm dispatcher-match">
            <h2>Ride with an unknown Status!</h2>
          </div>
        );
    }
  }
}

export default ActiveRide;
