import PropTypes from 'prop-types';

export const formatTime = serverTime => {
  let time;
  if (serverTime) {
    const date = new Date(serverTime * 1000);
    const THIRTY_MINUTES = 10 * 60 * 1000;
    let hours = date.getHours();
    if (new Date() - date < THIRTY_MINUTES) {
      time = 'Now';
    } else if (hours === 12) {
      time = `${hours}pm`;
    } else if (hours > 12) {
      hours -= 12;
      time = `${hours}pm`;
    } else {
      time = `${hours}am`;
    }
  } else {
    time = '';
  }

  return time;
};

export const RidePropTypes = PropTypes.shape({
  additional_passengers: PropTypes.number,
  from_address: PropTypes.string.isRequired,
  from_city: PropTypes.string.isRequired,
  from_zip: PropTypes.string.isRequired,
  name: PropTypes.string,
  pickup_at: PropTypes.number,
  special_requests: PropTypes.string,
  // TODO: Setup enum for ride.status
  status: PropTypes.oneOf([
    'driver_assigned',
    'picked_up',
    'waiting_assignment',
    'waiting_acceptance',
  ]),
  to_address: PropTypes.string.isRequired,
  to_city: PropTypes.string.isRequired,
  to_zip: PropTypes.string.isRequired,
  voter_phone_number: PropTypes.string.isRequired,
}).isRequired;
