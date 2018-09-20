import fetchMock from 'fetch-mock';
import promiseMiddleware from 'redux-promise-middleware';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import { createApiRequest } from './fetch';

import { defaultState } from '../reducers/rides';
import { fetchRides } from '../actions/rides';

const mockStore = configureMockStore([thunk, promiseMiddleware()]);

describe('async utilities', () => {
  afterEach(() => {
    fetchMock.reset();
    fetchMock.restore();
  });

  describe('createApiRequest', () => {
    beforeEach(() => {
      fetchMock.mock('*', {});
    });

    it('returns fetch promise using url args', () => {
      const fetchPromise = createApiRequest('foobar');

      expect(typeof fetchPromise.then === 'function').toEqual(true);
      expect(fetchMock.lastUrl()).toEqual('/driving/foobar');
    });

    it('request POST by default', () => {
      createApiRequest();
      expect(fetchMock.lastCall()[1].method).toEqual('POST');
    });

    it('requests via GET', () => {
      createApiRequest('', { method: 'GET' });
      expect(fetchMock.lastCall()[1].method).toEqual('GET');
    });
  });

  describe('fetchAndCatch', () => {
    it('catches network errors and dispatches error actions', () => {
      const store = mockStore(defaultState);
      const expectedActions = [
        { type: 'FETCH_RIDES_PENDING' },
        {
          error: true,
          type: 'FETCH_RIDES_REJECTED',
          payload: 'oh no!',
        },
        { message: 'oh no!', type: 'API_ERROR' },
      ];

      expect.assertions(1);
      fetchMock.mock('*', { throws: 'oh no!' });

      store.dispatch(fetchRides()).then(() => {
        expect(store.getActions()).toEqual(expectedActions);
      });
    });
  });
});
