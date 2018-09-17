import reducer, { defaultState } from './rides';

describe('rides reducer', () => {
  it('returns the initial state', () => {
    expect(reducer(undefined, { type: 'FOO_BAR' })).toEqual(defaultState);
  });

  describe('FECH_RIDES', () => {
    const result = reducer(defaultState, { type: 'FETCH_RIDES_FULFILLED', payload: {
      response: ['foo', 'bar'],
      waiting_rides_interval: 10
    }});
    expect(result).toEqual({
      active_ride: null,
      completedRide: null,
      isFetching: false,
      waiting_rides: ['foo', 'bar']
    });
  });

  describe('CLAIM_RIDE', () => {
    const result = reducer(defaultState, { type: 'CLAIM_RIDE_FULFILLED', meta: {
      active_ride: { name: "foo_bar", status: "not active" }
    }});
    expect(result).toEqual({
      active_ride: {
        name: "foo_bar",
        status: 'driver_assigned'
      },
      completedRide: null,
      isFetching: false,
      waiting_rides: [],
    });
  });

});
