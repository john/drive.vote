import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux';

function driverState(state = {
    initialFetch: true,
    isFetching: true,
    error: '',
    rides: [],
}, action) {
    switch (action.type) {
        case 'REQUEST_STATUS':
        case 'REQUEST_TOGGLE':
            return Object.assign({}, state, {
                isFetching: true,
            })
        case 'RIDE_CLAIM_ATTEMPT':
        case 'RIDE_CANCEL_ATTEMPT':
        case 'RIDER_PICKUP_ATTEMPT':
        case 'RIDE_COMPLETE_ATTEMPT':
            return Object.assign({}, state, {
                changePending: true
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
        case 'RECEIVE_RIDE_ZONE_STATS':
            return Object.assign({}, state, {
                ride_zone_stats: {
                    total_drivers: action.total_drivers,
                    available_drivers: action.available_drivers,
                    completed_rides: action.completed_rides,
                    active_rides: action.active_rides,
                    scheduled_rides: action.scheduled_rides
                }
            })
        case 'DRIVER_UNAVAILABLE':
            return Object.assign({}, state, {
                isFetching: false,
                available: false,
                active_ride: null,
                completedRide: null
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
                active_ride: action.active_ride,
                changePending: false,
            })
        case 'RIDE_CANCELLED':
            return Object.assign({}, state, {
                isFetching: false,
                active_ride: null,
                changePending: false
            })
        case 'RIDER_PICKUP':
            action.active_ride.status = 'picked_up';
            return Object.assign({}, state, {
                isFetching: false,
                active_ride: action.active_ride,
                changePending: false,
                completedRide: null

            })

        case 'RIDE_COMPLETE':
            action.active_ride.status = 'complete';
            return Object.assign({}, state, {
                isFetching: false,
                active_ride: null,
                changePending: false,
                completedRide: action.active_ride
            })

        case 'LOCATION_UPDATED':
            return Object.assign({}, state, {
                location: {
                    latitude: action.location.latitude,
                    longitude: action.location.longitude
                }
            })

        case 'LOCATION_SUBMITTED':
            return Object.assign({}, state, {
                update_location_interval: action.update_location_interval * 100,
            })
        case 'API_ERROR':
            return Object.assign({}, state, {
                error: String(action.message),
                isFetching: false
            })
        case 'API_ERROR_CLEAR':
            return Object.assign({}, state, {
                error: '',
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
