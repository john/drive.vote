import fetch from 'isomorphic-fetch';

const dev = 'http://localhost:3000/driving';
const prod = 'https://drive.vote/driving';
const api = prod;

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
        active_ride: {}
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

// TODO: API urls to environment vars
export function fetchStatus() {
    return function(dispatch) {
        dispatch(requestStatus())
        fetch(`${api}/status`, {
                credentials: 'include',
            })
            .then(response => response.json())
            .then(json =>
                dispatch(receiveStatus(json.response))
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
            .then(response => response.json())
            .then(json =>
                dispatch(driverUnavailable())
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
            .then(response => response.json())
            .then(json =>
                dispatch(driverAvailable()),
            )
    }
}

export function submitLocation(location) {
    return function(dispatch) {
        fetch(`${api}/location?latitude=${location.latitude}&longitude=${location.longitude}`, {
                // fetch(`${api}/location?latitude=28.5364748&longitude=-81.399317', {
                credentials: 'include',
                method: 'POST'
            })
            .then(response => response.json())
            .then(json =>
                dispatch(locationSaved(json))
            )
    }
}

export function fetchWaitingRides() {

    return function(dispatch) {
        dispatch(requestStatus())
        fetch(`${api}/waiting_rides`, {
                credentials: 'include',
            })
            .then(response => response.json())
            .then(json =>
                dispatch(receveWaitingRides(json))
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
            .then(response => response.json())
            .then(json =>
                dispatch(claimRideSuccess(ride))
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
            .then(response => response.json())
            .then(json =>
                dispatch(cancelRideSuccess(ride))
            )
    }
}

export function pickupRider(ride) {
    return function(dispatch) {;
        dispatch(attemptPickup())
        fetch(`${api}/pickup_ride?ride_id=${ride.id}`, {
                credentials: 'include',
                method: 'POST',
            })
            .then(response => response.json())
            .then(json =>
                dispatch(pickupRiderSuccess(ride))
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
            .then(response => response.json())
            .then(json =>
                dispatch(dropoffSuccess(ride))
            )
    }
}
