import { appReducer, defaultState } from './rootReducer';

describe('appReducer', () => {
  it('returns the initial state', () => {
    expect(appReducer(undefined, { type: 'FOO_BAR' })).toEqual(defaultState);
  });

  it('handles pending states', () => {
    const result = appReducer(defaultState, {
      type: 'SUBMIT_LOCATION_PENDING',
    });
    expect(result).toEqual({
      ...defaultState,
      isFetching: true,
    });
  });

  it('handles rejected states', () => {
    const result = appReducer(defaultState, {
      type: 'FETCH_STATUS_REJECTED',
    });
    expect(result).toEqual({
      ...defaultState,
      isFetching: false,
    });
  });

  it('handles FETCH_RIDES_FULFILLED', () => {
    const result = appReducer(defaultState, {
      type: 'FETCH_RIDES_FULFILLED',
      payload: {
        waiting_rides_interval: 10,
      },
    });
    expect(result).toEqual({
      ...defaultState,
      waiting_rides_interval: 10 * 1000,
    });
  });

  it('handles FETCH_STATUS_FULFILLED', () => {
    const result = appReducer(defaultState, {
      type: 'FETCH_STATUS_FULFILLED',
      payload: {
        response: {
          available: true,
          ride_zone_id: 666,
          waiting_rides_interval: 666,
          update_location_interval: 666,
        },
      },
    });
    expect(result).toEqual({
      ...defaultState,
      initialFetch: false,
      available: true,
      isFetching: false,
      ride_zone_id: 666,
      waiting_rides_interval: 666 * 1000,
      update_location_interval: 666 * 1000,
    });
  });

  it('handles FETCH_RIDE_ZONE_STATS_FULFILLED', () => {
    const result = appReducer(defaultState, {
      type: 'FETCH_RIDE_ZONE_STATS_FULFILLED',
      payload: {
        response: {
          total_drivers: 1,
          available_drivers: 2,
          completed_rides: 3,
          active_rides: 4,
          scheduled_rides: 5,
        },
      },
    });
    expect(result).toEqual({
      ...defaultState,
      isFetching: false,
      ride_zone_stats: {
        total_drivers: 1,
        available_drivers: 2,
        completed_rides: 3,
        active_rides: 4,
        scheduled_rides: 5,
      },
    });
  });

  it('handles SUBMIT_UNAVAILABLE_FULFILLED', () => {
    const result = appReducer(defaultState, {
      type: 'SUBMIT_UNAVAILABLE_FULFILLED',
    });
    expect(result).toEqual({
      ...defaultState,
      isFetching: false,
      available: false,
    });
  });
  it('handles SUBMIT_AVAILABLE_FULFILLED', () => {
    const result = appReducer(defaultState, {
      type: 'SUBMIT_AVAILABLE_FULFILLED',
    });
    expect(result).toEqual({
      ...defaultState,
      isFetching: false,
      available: true,
    });
  });

  it('handles LOCATION_UPDATED', () => {
    const result = appReducer(defaultState, {
      type: 'LOCATION_UPDATED',
      location: {
        latitude: 'foo',
        longitude: 'bar',
      },
    });
    expect(result).toEqual({
      ...defaultState,
      location: {
        latitude: 'foo',
        longitude: 'bar',
      },
    });
  });

  it('handles SUBMIT_LOCATION_FULFILLED', () => {
    const result = appReducer(defaultState, {
      type: 'SUBMIT_LOCATION_FULFILLED',
      payload: {
        response: { update_location_interval: 1 },
      },
    });
    expect(result).toEqual({
      ...defaultState,
      isFetching: false,
      update_location_interval: 1 * 1000,
    });
  });

  it('handles API_ERROR', () => {
    const result = appReducer(defaultState, {
      type: 'API_ERROR',
      message: 'foo bar baz',
    });
    expect(result).toEqual({
      ...defaultState,
      isFetching: false,
      error: 'foo bar baz',
    });
  });

  it('handles API_ERROR_CLEAR', () => {
    const result = appReducer(
      {
        ...defaultState,
        error: 'foo bar baz',
      },
      {
        type: 'API_ERROR_CLEAR',
      }
    );
    expect(result).toEqual({
      ...defaultState,
    });
  });
});
