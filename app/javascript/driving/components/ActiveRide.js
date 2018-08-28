import React from 'react';
import ContactVoter from './ContactVoter';

const renderAddress = ride => (
  <p>
    {ride.status === 'picked_up' ? ride.to_address : ride.from_address}
    <br />
    {ride.status === 'picked_up'
      ? `${ride.to_city}, ${ride.to_state}`
      : `${ride.from_city}, ${ride.from_state}`}
  </p>
);

const getRideLabel = status => {
  if (status === 'driver_assigned') {
    return 'Picking up';
  }
  return 'Dropping off';
};

const getMapLink = ride => {
  const mapPrefix = 'https://maps.apple.com/?daddr=';
  if (ride.status === 'picked_up') {
    return `${mapPrefix}${ride.to_address}, ${ride.to_city}, ${ride.to_state}`;
  }
  return `${mapPrefix}${ride.from_address}, ${ride.from_city}, ${
    ride.from_state
  }`;
};

const renderButtons = props => {
  const { ride, claimRide, cancelRide, pickupRider, completeRide } = props;

  switch (ride.status) {
    case 'waiting_acceptance':
      return (
        <React.Fragment>
          <button
            type="button"
            className="btn btn-success btn-api"
            onClick={() => claimRide(ride)}
          >
            Accept Ride
          </button>
          <button
            type="button"
            className="btn btn-danger btn-api"
            onClick={() => cancelRide(ride)}
          >
            Decline Ride
          </button>
        </React.Fragment>
      );

    case 'driver_assigned':
      return (
        <React.Fragment>
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
        </React.Fragment>
      );

    case 'picked_up':
      return (
        <React.Fragment>
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
        </React.Fragment>
      );

    default:
      return <p>{ride.status}</p>;
  }
};

const ActiveRide = props => {
  const {
    ride,
    ride: { additional_passengers, name, status, special_requests },
  } = props;
  const passengers = 1 + parseInt(additional_passengers, 10);
  return (
    <div
      className={`panel panel-full p-y-sm ${
        status === 'waiting_acceptance' ? 'dispatcher-match' : ''
      }`}
    >
      {ride.status === 'waiting_acceptance' && (
        <h2 className="m-b-0">Ride Assigned by Dispatch</h2>
      )}
      <a
        className="directionsLink"
        target="_blank"
        rel="noopener noreferrer"
        href={getMapLink(ride)}
      >
        <i className="fa fa-map-marker" /> Directions
      </a>
      <span className="label">{getRideLabel(status)}:</span>
      <h3>{name}</h3>
      {renderAddress(ride)}
      <ContactVoter voter_phone_number={ride.voter_phone_number} />
      <div className="secondary-info">
        <p>Total Passengers: {passengers}</p>
        <p>Special requests: {special_requests}</p>
      </div>
      <div className="bottom-controls secondary">
        {renderButtons(props)}
      </div>
    </div>
  );
};

export default ActiveRide;
