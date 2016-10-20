import fetch from 'isomorphic-fetch';

// Expect API to be served off the same origin.
const api = '/driving';

function parseJSON(response) {
    if (response.ok) {
        return response.json();
    } else {
        return response.json()
            .then(function(response) {
                console.log(response.error);
                throw new Error(response.error);
            });
    }
}

export function apiError(message) {
    return {
        type: 'API_ERROR',
        message,
    }
}

export function clearError() {
    return {
        type: 'API_ERROR_CLEAR',
    }
}
export function requestStatus() {
    return {
        type: 'REQUEST_STATUS',
    }
}

export function receiveStatus(status) {
    return {
        type: 'RECEIVE_STATUS',
        available: status.available,
        waiting_rides_interval: status.waiting_rides_interval,
        update_location_interval: status.update_location_interval,
        active_ride: status.active_ride
    }
}

export function receiveRideZoneStats(rideZoneStats) {
    return {
        type: 'RECEIVE_RIDE_ZONE_STATS',
        total_drivers: rideZoneStats.total_drivers,
        available_drivers: rideZoneStats.available_drivers,
        completed_rides: rideZoneStats.completed_rides,
        active_rides: rideZoneStats.active_rides,
        scheduled_rides: rideZoneStats.scheduled_rides
    }
}
export function requestToggle() {
    return {
        type: 'REQUEST_TOGGLE',
    }
}
export function driverUnavailable() {
    return {
        type: 'DRIVER_UNAVAILABLE',
    }
}

export function driverAvailable() {
    return {
        type: 'DRIVER_AVAILABLE',
    }
}

export function receveWaitingRides(rides) {
    return {
        type: 'RECEIVE_RIDES',
        rides: rides.response,
        waiting_rides_interval: rides.waiting_rides_interval

    }
}

export function attemptClaim() {
    return {
        type: 'RIDE_CLAIM_ATTEMPT',
    }
}
export function claimRideSuccess(ride) {
    return {
        type: 'RIDE_CLAIMED',
        active_ride: ride
    }
}

export function attemptCancel() {
    return {
        type: 'RIDE_CANCEL_ATTEMPT',
    }
}

export function cancelRideSuccess(ride) {
    return {
        type: 'RIDE_CANCELLED',
        active_ride: null
    }
}

export function attemptPickup() {
    return {
        type: 'RIDER_PICKUP_ATTEMPT',
    }
}

export function pickupRiderSuccess(ride) {
    return {
        type: 'RIDER_PICKUP',
        active_ride: ride
    }
}

export function attemptDropoff() {
    return {
        type: 'RIDE_COMPLETE_ATTEMPT',
    }
}
export function dropoffSuccess(ride) {
    return {
        type: 'RIDE_COMPLETE',
        active_ride: ride
    }
}
export function setLocation(location) {
    return {
        type: 'LOCATION_UPDATED',
        location: location.coords
    }
}

export function locationSaved(response) {
    return {
        type: 'LOCATION_SUBMITTED',
        update_location_interval: response.update_location_interval
    }
}

export function fetchStatus() {
    return function(dispatch) {
        dispatch(requestStatus())
        fetch(`${api}/status`, {
                credentials: 'include',
            })
            .then(parseJSON)
            .then(json =>
                dispatch(receiveStatus(json.response))
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}

export function fetchRideZoneStats() {
    return function(dispatch) {
        fetch(`${api}/ridezone_stats`, {
                credentials: 'include',
            })
            .then(parseJSON)
            .then(json =>
                dispatch(receiveRideZoneStats(json.response))
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}

export function submitUnavailable() {
    // /unavailable
    return function(dispatch) {
        dispatch(requestToggle());
        return fetch(`${api}/unavailable`, {
                credentials: 'include',
                method: 'POST',
            })
            .then(parseJSON)
            .then(json =>
                dispatch(driverUnavailable())
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}

export function submitAvailable() {
    return function(dispatch) {
        dispatch(requestToggle());
        return fetch(`${api}/available`, {
                credentials: 'include',
                method: 'POST',
            })
            .then(parseJSON)
            .then(json =>
                dispatch(driverAvailable()),
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}

export function submitLocation(location) {
    return function(dispatch) {
        fetch(`${api}/location?latitude=28.532&longitude=-81.37`, {
                // fetch(`${api}/location?latitude=${location.latitude}&longitude=${location.longitude}`, {
                credentials: 'include',
                method: 'POST'
            })
            .then(parseJSON)
            .then(json =>
                dispatch(locationSaved(json))
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}

export function fetchWaitingRides(location) {

    return function(dispatch) {
        dispatch(requestStatus())
        fetch(`${api}/waiting_rides?latitude=28.532&longitude=-81.37`, {
                // fetch(`${api}/waiting_rides?latitude=${location.latitude}&longitude=${location.longitude}`, {
                credentials: 'include',
            })
            .then(parseJSON)
            .then(json =>
                dispatch(receveWaitingRides(json))
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}

export function claimRide(ride) {
    return function(dispatch) {
        dispatch(attemptClaim());
        fetch(`${api}/accept_ride?ride_id=${ride.id}`, {
                credentials: 'include',
                method: 'POST',
            })
            .then(parseJSON)
            .then(json =>
                dispatch(claimRideSuccess(ride))
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}

export function cancelRide(ride) {
    return function(dispatch) {
        dispatch(attemptCancel());
        fetch(`${api}/unaccept_ride?ride_id=${ride.id}`, {
                credentials: 'include',
                method: 'POST',
            })
            .then(parseJSON)
            .then(json =>
                dispatch(cancelRideSuccess(ride))
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}

export function pickupRider(ride) {
    return function(dispatch) {
        dispatch(attemptPickup());
        fetch(`${api}/pickup_ride?ride_id=${ride.id}`, {
                credentials: 'include',
                method: 'POST',
            })
            .then(parseJSON)
            .then(json =>
                dispatch(pickupRiderSuccess(ride))
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}

export function completeRide(ride) {
    return function(dispatch) {
        dispatch(attemptDropoff());
        fetch(`${api}/complete_ride?ride_id=${ride.id}`, {
                credentials: 'include',
                method: 'POST',
            })
            .then(parseJSON)
            .then(json =>
                dispatch(dropoffSuccess(ride)),
                dispatch(fetchWaitingRides())
            ).catch(error =>
                dispatch(apiError(error))
            )
    }
}