import reducer, { defaultState } from './rides';

const sampleRide = {
  name: 'foo bar baz',
  id: 123,
  status: 'waiting_acceptance',
};

const waiting_rides = [
  sampleRide,
  {
    ...sampleRide,
    id: 456,
  },
  {
    ...sampleRide,
    id: 789,
  },
];

describe('rides reducer', () => {
  it('returns the initial state', () => {
    expect(reducer(undefined, { type: 'FOO_BAR' })).toEqual(defaultState);
  });

  it('handles pending states', () => {
    const result = reducer(defaultState, {
      type: 'ARCHIVE_RIDE_PENDING',
    });
    expect(result).toEqual({
      ...defaultState,
      isFetching: true,
    });
  });

  it('handles rejected states', () => {
    const result = reducer(defaultState, {
      type: 'ARCHIVE_RIDE_REJECTED',
    });
    expect(result).toEqual({
      ...defaultState,
      isFetching: false,
    });
  });

  it('handles FETCH_RIDES_FULFILLED', () => {
    const result = reducer(defaultState, {
      type: 'FETCH_RIDES_FULFILLED',
      payload: {
        response: waiting_rides,
        waiting_rides_interval: 10,
      },
    });
    expect(result).toEqual({
      ...defaultState,
      waiting_rides,
    });
  });

  it('handles CLAIM_RIDE_FULFILLED', () => {
    const result = reducer(defaultState, {
      type: 'CLAIM_RIDE_FULFILLED',
      meta: {
        active_ride: sampleRide,
      },
    });
    expect(result).toEqual({
      ...defaultState,
      active_ride: {
        ...sampleRide,
        status: 'driver_assigned',
      },
    });
  });

  it('handles ARCHIVE_RIDE_FULFILLED', () => {
    const waitingRidesState = reducer(defaultState, {
      type: 'FETCH_RIDES_FULFILLED',
      payload: {
        response: waiting_rides,
        waiting_rides_interval: 10,
      },
    });
    const activeRideState = reducer(waitingRidesState, {
      type: 'CLAIM_RIDE_FULFILLED',
      meta: { active_ride: sampleRide },
    });
    const result = reducer(activeRideState, {
      type: 'ARCHIVE_RIDE_FULFILLED',
      meta: {
        active_ride: sampleRide,
      },
    });
    expect(result).toEqual({
      active_ride: null,
      completedRide: null,
      isFetching: false,
      waiting_rides: waiting_rides.slice(1),
    });
  });

  it('handles PICKUP_RIDE_FULFILLED', () => {
    const result = reducer(defaultState, {
      type: 'PICKUP_RIDE_FULFILLED',
      meta: {
        active_ride: sampleRide,
      },
    });
    expect(result).toEqual({
      ...defaultState,
      active_ride: {
        ...sampleRide,
        status: 'picked_up',
      },
    });
  });

  it('handles COMPLETE_RIDE_FULFILLED', () => {
    const result = reducer(defaultState, {
      type: 'COMPLETE_RIDE_FULFILLED',
      meta: {
        active_ride: sampleRide,
      },
    });
    expect(result).toEqual({
      ...defaultState,
      completedRide: {
        ...sampleRide,
        status: 'complete',
      },
    });
  });

  it('handles FETCH_STATUS_FULFILLED', () => {
    const result = reducer(defaultState, {
      type: 'FETCH_STATUS_FULFILLED',
      payload: {
        response: {
          active_ride: sampleRide,
        },
      },
    });
    expect(result).toEqual({
      ...defaultState,
      active_ride: {
        ...sampleRide,
      },
    });
  });
});
