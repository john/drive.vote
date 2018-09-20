import { fetchAndCatch } from '../utilities/fetch';

// Expect API to be served off the same origin.
const api = '/driving';

export function apiError(message) {
  // The Fetch API leaves you in a lurch for detecting generic network errors,
  // Not sure if there's any way to catch this besides a RegExp
  const pattern = new RegExp(`TypeError: Failed to fetch`);
  if (pattern.test(message)) {
    return {
      type: 'CONNECTION_ERROR',
      message,
    };
  }
  return {
    type: 'API_ERROR',
    message,
  };
}

export function clearError() {
  return {
    type: 'API_ERROR_CLEAR',
  };
}

export function fetchStatus() {
  return fetchAndCatch({
    type: 'FETCH_STATUS',
    url: 'status',
    options: {
      method: 'GET',
    },
  });
}

export function fetchRideZoneStats() {
  return fetchAndCatch({
    type: 'FETCH_RIDE_ZONE_STATS',
    url: 'ridezone_stats',
    options: {
      method: 'GET',
    },
  });
}

export function submitUnavailable() {
  return fetchAndCatch({
    type: 'SUBMIT_UNAVAILABLE',
    url: 'unavailable',
  });
}

export function submitAvailable() {
  return fetchAndCatch({
    type: 'SUBMIT_AVAILABLE',
    url: 'unavailable',
  });
}

export function setLocation(location) {
  return {
    type: 'LOCATION_UPDATED',
    location: location.coords,
  };
}

export function submitLocation(location) {
  return fetchAndCatch({
    type: 'SUBMIT_LOCATION',
    url: `${api}/location?latitude=${location.latitude}&longitude=${
      location.longitude
    }`,
  });
}
