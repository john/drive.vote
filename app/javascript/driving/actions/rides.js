import { createApiRequest, fetchAndCatch } from '../utilities/fetch';

export const fetchRides = location => {
  let url = 'waiting_rides';
  if (location) {
    url += `?latitude=${location.latitude}&longitude=${location.longitude}`;
  }
  return {
    type: 'FETCH_RIDES',
    payload: createApiRequest(url, { method: 'GET' }),
  };
};

export function claimRide(ride) {
  return fetchAndCatch({
    type: 'CLAIM_RIDE',
    url: `accept_ride?ride_id=${ride.id}`,
    meta: {
      active_ride: ride,
    },
  });
}

export const archiveRide = ride => {
  const url = `cancel_ride?ride_id=${ride.id}`;

  return {
    type: 'ARCHIVE_RIDE',
    payload: createApiRequest(url),
    meta: {
      active_ride: ride,
    },
  };
};

export const cancelRide = ride => {
  const url = `unaccept_ride?ride_id=${ride.id}`;

  return {
    type: 'CANCEL_RIDE',
    payload: createApiRequest(url),
    meta: {
      active_ride: ride,
    },
  };
};

export const pickupRider = ride => {
  const url = `pickup_ride?ride_id=${ride.id}`;

  return {
    type: 'PICKUP_RIDE',
    payload: createApiRequest(url),
    meta: {
      active_ride: ride,
    },
  };
};

export const completeRide = ride => {
  const url = `complete_ride?ride_id=${ride.id}`;

  return {
    type: 'COMPLETE_RIDE',
    payload: createApiRequest(url),
    meta: {
      active_ride: ride,
    },
  };
};

// export function receveWaitingRides(rides) {
//   return {
//     type: 'RECEIVE_RIDES',
//     rides: rides.response,
//     waiting_rides_interval: rides.waiting_rides_interval,
//   ^^^^^^^^^^^
//   };
// }
