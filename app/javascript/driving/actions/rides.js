import { createApiRequest, fetchAndCatch } from '../utilities/fetch';

export function fetchRides(location) {
  let url = 'waiting_rides';
  if (location) {
    url += `?latitude=${location.latitude}&longitude=${location.longitude}`;
  }
  return fetchAndCatch({
    type: 'FETCH_RIDES',
    url,
    options: {
      method: 'GET',
    },
  });
}

export function claimRide(ride) {
  return fetchAndCatch({
    type: 'CLAIM_RIDE',
    url: `accept_ride?ride_id=${ride.id}`,
    meta: {
      active_ride: ride,
    },
  });
}

export function archiveRide(ride) {
  return fetchAndCatch({
    type: 'ARCHIVE_RIDE',
    url: `cancel_ride?ride_id=${ride.id}`,
    meta: {
      active_ride: ride,
    },
  });
}

export function cancelRide(ride) {
  return fetchAndCatch({
    type: 'CANCEL_RIDE',
    url: `unaccept_ride?ride_id=${ride.id}`,
    meta: {
      active_ride: ride,
    },
  });
}

export function pickupRide(ride) {
  const url = `pickup_ride?ride_id=${ride.id}`;

  return {
    type: 'PICKUP_RIDE',
    payload: createApiRequest(url),
    meta: {
      active_ride: ride,
    },
  };
}

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
