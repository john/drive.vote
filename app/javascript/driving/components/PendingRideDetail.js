import React from 'react';
import ContactVoter from './ContactVoter';

const PendingRideDetail = ({ claimRide, declineRide, ride }) => {
  const passengers = 1 + parseInt(ride.additional_passengers, 10);
  const mapLink = `https://maps.apple.com/?daddr=${ride.from_address}, ${
    ride.from_city
  }, ${ride.from_state}`;

  return (
    <div className="panel panel-full p-y-sm">
      <div className="rideDetails">
        <a className="directionsLink" rel="noopener noreferrer" target="_blank" href={mapLink}>
          <i className="fa fa-map-marker" />
          {' '}
Directions
        </a>
        <span className="label">Accept Ride:</span>
        <h3>{ride.name}</h3>
        <p>
          {ride.from_address}
          <br />
          {ride.from_city}
,
          {ride.from_state} 
          {' '}
          {ride.from_zip}
        </p>
        <ContactVoter voter_phone_number={ride.voter_phone_number} />
        <div className="secondary-info m-t">
          <p>
            Total Passengers:
            {passengers}
          </p>
          <p>
            Special requests:
            {ride.special_requests}
          </p>
        </div>
      </div>
      <div className="bottom-controls secondary">
        <button
          type="button"
          className="btn btn-success btn-api"
          onClick={() => claimRide(ride)}
        >
          Accept
        </button>
        <button
          type="button"
          className="btn btn-secondary"
          onClick={() => declineRide()}
        >
          Back to list of Voters
        </button>
      </div>
    </div>
  );
};

export default PendingRideDetail;
