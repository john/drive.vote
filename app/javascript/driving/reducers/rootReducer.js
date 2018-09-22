import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux';

import rides from './rides';

export const defaultState = {
  available: false,
  error: '',
  initialFetch: true,
  isFetching: true,
};
export function appReducer(state = defaultState, action) {
  switch (action.type) {
    case 'FETCH_STATUS_PENDING':
    case 'SUBMIT_UNAVAILABLE_PENDING':
    case 'SUBMIT_AVAILABLE_PENDING':
      return {
        ...state,
        isFetching: true,
      };

    case 'FETCH_STATUS_REJECTED':
    case 'SUBMIT_UNAVAILABLE_REJECTED':
    case 'SUBMIT_AVAILABLE_REJECTED':
      return {
        ...state,
        isFetching: false,
      };

    case 'FETCH_RIDES_FULFILLED':
      return {
        ...state,
        waiting_rides_interval: action.payload.waiting_rides_interval * 1000,
      };

    case 'FETCH_STATUS_FULFILLED':
      return {
        ...state,
        initialFetch: false,
        isFetching: false,
        available: action.payload.response.available,
        ride_zone_id: action.payload.response.ride_zone_id,
        waiting_rides_interval:
          action.payload.response.waiting_rides_interval * 1000,
        update_location_interval:
          action.payload.response.update_location_interval * 1000,
      };

    case 'FETCH_RIDE_ZONE_STATS_FULFILLED':
      return {
        ...state,
        isFetching: false,
        ride_zone_stats: {
          total_drivers: action.payload.total_drivers,
          available_drivers: action.payload.available_drivers,
          completed_rides: action.payload.completed_rides,
          active_rides: action.payload.active_rides,
          scheduled_rides: action.payload.scheduled_rides,
        },
      };
    case 'SUBMIT_UNAVAILABLE_FULFILLED':
      return {
        ...state,
        isFetching: false,
        available: false,
      };
    case 'SUBMIT_AVAILABLE_FULFILLED':
      return {
        ...state,
        isFetching: false,
        available: true,
      };
    case 'LOCATION_UPDATED':
      return {
        ...state,
        location: {
          latitude: action.location.latitude,
          longitude: action.location.longitude,
        },
      };

    case 'SUBMIT_LOCATION_FULFILLED':
      return {
        ...state,
        isFetching: false,
        update_location_interval:
          action.payload.response.update_location_interval * 1000,
      };

    case 'API_ERROR':
      return {
        ...state,
        error: String(action.message),
        isFetching: false,
      };
    case 'API_ERROR_CLEAR':
      return {
        ...state,
        error: '',
      };

    default:
      return state;
  }
}

const rootReducer = combineReducers({
  appState: appReducer,
  rides,
  routing: routerReducer,
});

export default rootReducer;
