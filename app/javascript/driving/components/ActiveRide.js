import React from 'react';
import PropTypes from 'prop-types';
import { RidePropTypes } from '../utilities/helpers';

import ContactVoter from './ContactVoter';

const renderAddress = ride => (
  <p>
    {ride.status === 'picked_up' ? ride.to_address : ride.from_address}
    <br />
    {ride.status === 'picked_up'
      ? `${ride.to_city}, ${ride.to_state} ${ride.to_zip}`
      : `${ride.from_city}, ${ride.from_state} ${ride.from_zip}`}
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
  const {
    archiveRide,
    cancelRide,
    claimRide,
    completeRide,
    pickupRide,
    ride,
  } = props;

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

    // TODO: Double confirm for archvie ride
    case 'driver_assigned':
      return (
        <React.Fragment>
          <button
            type="button"
            className="btn btn-success btn-api"
            onClick={() => pickupRide(ride)}
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
          <p className="text-center">
            Cancelling a ride will make it available to other drivers
          </p>
          <button
            className="btn btn-outline btn-api m-t-md"
            onClick={() => archiveRide(ride)}
          >
            Archive Ride
          </button>
          <p className="text-center">
            Archive a ride when a rider has already voted.
          </p>
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
      <div className="bottom-controls secondary">{renderButtons(props)}</div>
    </div>
  );
};

ActiveRide.propTypes = {
  ride: RidePropTypes,
  archiveRide: PropTypes.func.isRequired,
  claimRide: PropTypes.func.isRequired,
  cancelRide: PropTypes.func.isRequired,
  pickupRide: PropTypes.func.isRequired,
  completeRide: PropTypes.func.isRequired,
};

export default ActiveRide;
