// import fetch from 'isomorphic-fetch';

// // Expect API to be served off the same origin.
// const api = '/driving';

// function parseJSON(response) {
//   if (response.ok) {
//     return response.json();
//   }
//   return response.json().then(parsedResponse => {
//     throw new Error(parsedResponse.error);
//   });
// }

// export function apiError(message) {
//   // The Fetch API leaves you in a lurch for detecting generic network errors,
//   // Not sure if there's any way to catch this besides a RegExp
//   const pattern = new RegExp(`TypeError: Failed to fetch`);
//   if (pattern.test(message)) {
//     return {
//       type: 'CONNECTION_ERROR',
//       message,
//     };
//   }
//   return {
//     type: 'API_ERROR',
//     message,
//   };
// }

// export function clearError() {
//   return {
//     type: 'API_ERROR_CLEAR',
//   };
// }
// export function requestStatus() {
//   return {
//     type: 'REQUEST_STATUS',
//   };
// }

// export function receiveStatus(status) {
//   return {
//     type: 'RECEIVE_STATUS',
//     available: status.available,
//     waiting_rides_interval: status.waiting_rides_interval,
//     update_location_interval: status.update_location_interval,
//     ride_zone_id: status.ride_zone_id,
//     active_ride: status.active_ride,
//   };
// }

// export function receiveRideZoneStats(rideZoneStats) {
//   return {
//     type: 'RECEIVE_RIDE_ZONE_STATS',
//     total_drivers: rideZoneStats.total_drivers,
//     available_drivers: rideZoneStats.available_drivers,
//     completed_rides: rideZoneStats.completed_rides,
//     active_rides: rideZoneStats.active_rides,
//     scheduled_rides: rideZoneStats.scheduled_rides,
//   };
// }
// export function requestToggle() {
//   return {
//     type: 'REQUEST_TOGGLE',
//   };
// }
// export function driverUnavailable() {
//   return {
//     type: 'DRIVER_UNAVAILABLE',
//   };
// }

// export function driverAvailable() {
//   return {
//     type: 'DRIVER_AVAILABLE',
//   };
// }

// export function requestRides() {
//   return {
//     type: 'REQUEST_RIDES',
//   };
// }

// export function receveWaitingRides(rides) {
//   return {
//     type: 'RECEIVE_RIDES',
//     rides: rides.response,
//     waiting_rides_interval: rides.waiting_rides_interval,
//   };
// }

// export function attemptClaim() {
//   return {
//     type: 'RIDE_CLAIM_ATTEMPT',
//   };
// }
// export function claimRideSuccess(ride) {
//   return {
//     type: 'RIDE_CLAIMED',
//     active_ride: ride,
//   };
// }

// export function attemptArchive() {
//   return {
//     type: 'RIDE_ARCHIVE_ATTEMPT',
//   };
// }

// export function archiveRideSuccess(active_ride) {
//   return {
//     type: 'RIDE_ARCHIVED',
//     active_ride,
//   };
// }

// export function attemptCancel() {
//   return {
//     type: 'RIDE_CANCEL_ATTEMPT',
//   };
// }

// export function cancelRideSuccess(active_ride) {
//   return {
//     type: 'RIDE_CANCELLED',
//     active_ride,
//   };
// }

// export function attemptPickup() {
//   return {
//     type: 'RIDER_PICKUP_ATTEMPT',
//   };
// }

// export function pickupRiderSuccess(ride) {
//   return {
//     type: 'RIDER_PICKUP',
//     active_ride: ride,
//   };
// }

// export function attemptDropoff() {
//   return {
//     type: 'RIDE_COMPLETE_ATTEMPT',
//   };
// }
// export function dropoffSuccess(ride) {
//   return {
//     type: 'RIDE_COMPLETE',
//     active_ride: ride,
//   };
// }
// export function setLocation(location) {
//   return {
//     type: 'LOCATION_UPDATED',
//     location: location.coords,
//   };
// }

// export function locationSaved(response) {
//   return {
//     type: 'LOCATION_SUBMITTED',
//     update_location_interval: response.response.update_location_interval,
//   };
// }

// export function fetchStatus() {
//   return dispatch => {
//     dispatch(requestStatus());
//     fetch(`${api}/status`, {
//       credentials: 'include',
//     })
//       .then(parseJSON)
//       .then(json => dispatch(receiveStatus(json.response)))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function fetchRideZoneStats() {
//   return dispatch => {
//     fetch(`${api}/ridezone_stats`, {
//       credentials: 'include',
//     })
//       .then(parseJSON)
//       .then(json => dispatch(receiveRideZoneStats(json.response)))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function submitUnavailable() {
//   // /unavailable
//   return dispatch => {
//     dispatch(requestToggle());
//     return fetch(`${api}/unavailable`, {
//       credentials: 'include',
//       method: 'POST',
//     })
//       .then(parseJSON)
//       .then(() => dispatch(driverUnavailable()))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function submitAvailable() {
//   return dispatch => {
//     dispatch(requestToggle());
//     return fetch(`${api}/available`, {
//       credentials: 'include',
//       method: 'POST',
//     })
//       .then(parseJSON)
//       .then(() => dispatch(driverAvailable()))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function submitLocation(location) {
//   return dispatch => {
//     fetch(
//       `${api}/location?latitude=${location.latitude}&longitude=${
//         location.longitude
//       }`,
//       {
//         credentials: 'include',
//         method: 'POST',
//       }
//     )
//       .then(parseJSON)
//       .then(json => dispatch(locationSaved(json)))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function fetchWaitingRides(location) {
//   let url = '/waiting_rides';
//   if (location) {
//     url += `?latitude=${location.latitude}&longitude=${location.longitude}`;
//   }
//   return dispatch => {
//     dispatch(requestRides());
//     fetch(`${api}${url}`, {
//       credentials: 'include',
//     })
//       .then(parseJSON)
//       .then(json => dispatch(receveWaitingRides(json)))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function claimRide(ride) {
//   return dispatch => {
//     dispatch(attemptClaim());
//     fetch(`${api}/accept_ride?ride_id=${ride.id}`, {
//       credentials: 'include',
//       method: 'POST',
//     })
//       .then(parseJSON)
//       .then(() => dispatch(claimRideSuccess(ride)))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function archiveRide(ride) {
//   return dispatch => {
//     dispatch(attemptArchive());
//     fetch(`${api}/cancel_ride?ride_id=${ride.id}`, {
//       credentials: 'include',
//       method: 'POST',
//     })
//       .then(parseJSON)
//       .then(() => dispatch(archiveRideSuccess(ride)))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function cancelRide(ride) {
//   return dispatch => {
//     dispatch(attemptCancel());
//     fetch(`${api}/unaccept_ride?ride_id=${ride.id}`, {
//       credentials: 'include',
//       method: 'POST',
//     })
//       .then(parseJSON)
//       .then(() => dispatch(cancelRideSuccess(ride)))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function pickupRider(ride) {
//   return dispatch => {
//     dispatch(attemptPickup());
//     fetch(`${api}/pickup_ride?ride_id=${ride.id}`, {
//       credentials: 'include',
//       method: 'POST',
//     })
//       .then(parseJSON)
//       .then(() => dispatch(pickupRiderSuccess(ride)))
//       .catch(error => dispatch(apiError(error)));
//   };
// }

// export function completeRide(ride) {
//   return dispatch => {
//     dispatch(attemptDropoff());
//     fetch(`${api}/complete_ride?ride_id=${ride.id}`, {
//       credentials: 'include',
//       method: 'POST',
//     })
//       .then(parseJSON)
//       .then(() => dispatch(dropoffSuccess(ride)), dispatch(fetchWaitingRides()))
//       .catch(error => dispatch(apiError(error)));
//   };
// }
