import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux';

function driverState(state = {
    initialFetch: true,
    isFetching: true,
    rides: [],
}, action) {
    switch (action.type) {
        case 'REQUEST_STATUS':
        case 'REQUEST_TOGGLE':
        case 'RIDE_CLAIM_ATTEMPT':
            return Object.assign({}, state, {
                isFetching: true,
            })
        case 'RECEIVE_STATUS':
            return Object.assign({}, state, {
                initialFetch: false,
                isFetching: false,
                available: action.available,
                waiting_rides_interval: action.waiting_rides_interval * 100,
                update_location_interval: action.update_location_interval * 100,
                active_ride: action.active_ride,
            })
        case 'DRIVER_UNAVAILABLE':
            return Object.assign({}, state, {
                isFetching: false,
                available: false,
                active_ride: {}
            })
        case 'DRIVER_AVAILABLE':
            return Object.assign({}, state, {
                isFetching: false,
                available: true,
            })
        case 'RECEIVE_RIDES':
            return Object.assign({}, state, {
                isFetching: false,
                rides: action.rides,
                waiting_rides_interval: action.waiting_rides_interval * 100,
            })
        case 'RIDE_CLAIMED':
            action.active_ride.status = 'driver_assigned';
            return Object.assign({}, state, {
                isFetching: false,
                waiting_rides_interval: 0,
                active_ride: action.active_ride
            })
        case 'RIDE_CANCELLED':
            return Object.assign({}, state, {
                isFetching: false,
                active_ride: action.active_ride
            })
        case 'RIDER_PICKUP':
            action.active_ride.status = 'picked_up';
            return Object.assign({}, state, {
                isFetching: false,
                active_ride: action.active_ride
            })

        case 'RIDE_COMPLETE':
            action.active_ride.status = 'complete';
            return Object.assign({}, state, {
                isFetching: false,
                active_ride: action.active_ride
            })

        case 'LOCATION_UPDATED':
            return Object.assign({}, state, {
                isFetching: false,
                location: {
                    latitude: action.location.latitude,
                    longitude: action.location.longitude
                }
            })

        case 'LOCATION_SUBMITTED':
            return Object.assign({}, state, {
                isFetching: false,
                update_location_interval: action.update_location_interval * 100,
            })

        default:
            return state;
    }
}


const rootReducer = combineReducers({
    driverState,
    routing: routerReducer
});

export default rootReducer;
