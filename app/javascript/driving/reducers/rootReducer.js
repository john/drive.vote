import { combineReducers } from 'redux';
import rides from './rides';
import { routerReducer } from 'react-router-redux';

const defaultState = {
  available: false,
  error: '',
  completedRide: null,
  changePending: false,
  initialFetch: true,
  isFetching: true,
  // rides: [],
};
function driverState(state = defaultState, action) {
  switch (action.type) {
    case 'REQUEST_STATUS':
    case 'REQUEST_TOGGLE':
    case 'FETCH_RIDES_PENDING':
      return {
        ...state,
        isFetching: true,
      };

    case 'RECEIVE_STATUS':
      return {
        ...state,
        initialFetch: false,
        isFetching: false,
        available: action.available,
        ride_zone_id: action.ride_zone_id,
        waiting_rides_interval: action.waiting_rides_interval * 1000,
        update_location_interval: action.update_location_interval * 1000,
        active_ride: action.active_ride,
      };
    case 'RECEIVE_RIDE_ZONE_STATS':
      return {
        ...state,
        ride_zone_stats: {
          total_drivers: action.total_drivers,
          available_drivers: action.available_drivers,
          completed_rides: action.completed_rides,
          active_rides: action.active_rides,
          scheduled_rides: action.scheduled_rides,
        },
      };
    case 'DRIVER_UNAVAILABLE':
      return {
        ...state,
        isFetching: false,
        available: false,
        active_ride: null,
        completedRide: null,
      };
    case 'DRIVER_AVAILABLE':
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

    case 'LOCATION_SUBMITTED':
      return {
        ...state,
        update_location_interval: action.update_location_interval * 1000,
      };

    case 'API_ERROR':
      return {
        ...state,
        error: String(action.message),
        isFetching: false,
        changePending: false,
      };
    case 'CONNECTION_ERROR':
      return {
        ...state,
        connectionError: String(action.message),
        isFetching: false,
        changePending: false,
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
  driverState,
  rides,
  routing: routerReducer,
});

export default rootReducer;
