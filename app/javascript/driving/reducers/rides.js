export const defaultState = {
  active_ride: null,
  completedRide: null,
  isFetching: false,
  waiting_rides: [],
};

export default (state = defaultState, { meta, type, payload }) => {
  switch (type) {
    case 'ARCHIVE_RIDE_PENDING':
    case 'CANCEL_RIDE_PENDING':
    case 'CLAIM_RIDE_PENDING':
    case 'COMPLETE_RIDE_PENDING':
    case 'FETCH_RIDES_PENDING':
    case 'PICKUP_RIDE_PENDING':
      return {
        ...state,
        isFetching: true,
      };
    case 'FETCH_RIDES_FULFILLED':
      return {
        ...state,
        isFetching: false,
        waiting_rides: payload.response,
      };
    case 'CLAIM_RIDE_FULFILLED':
      return {
        ...state,
        isFetching: false,
        active_ride: {
          ...meta.active_ride,
          status: 'driver_assigned',
        },
      };
    case 'ARCHIVE_RIDE_FULFILLED':
    case 'CANCEL_RIDE_FULFILLED':
      return {
        ...state,
        isFetching: false,
        active_ride: null,
        waiting_rides: state.waiting_rides.filter(
          ride => ride.id !== meta.active_ride.id
        ),
      };

    case 'PICKUP_RIDE_FULFILLED':
      return {
        ...state,
        isFetching: false,
        active_ride: {
          ...meta.active_ride,
          status: 'picked_up',
        },
      };

    case 'COMPLETE_RIDE_FULFILLED':
      return {
        ...state,
        isFetching: false,
        active_ride: null,

        completedRide: {
          ...meta.active_ride,
          status: 'complete',
        },
      };

    case 'ARCHIVE_RIDE_REJECTED':
    case 'CANCEL_RIDE_REJECTED':
    case 'CLAIM_RIDE_REJECTED':
    case 'COMPLETE_RIDE_REJECTED':
    case 'FETCH_RIDES_REJECTED':
    case 'PICKUP_RIDE_REJECTED':
      return {
        ...state,
        isFetching: false,
      };

    case 'FETCH_STATUS_FULFILLED':
      return {
        ...state,
        active_ride: payload.active_ride,
      };

    default:
      return state;
  }
};
