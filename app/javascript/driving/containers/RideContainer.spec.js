import React from 'react';
import { shallow } from 'enzyme';
import RideContainer from './RideContainer';
import { mockRide } from '../utilities/helpers';

jest.useFakeTimers();

const makeProps = props => ({
  initialFetch: true,
  rides: {
    active_ride: null,
    isFetching: false,
  },
  isFetching: false,
  ride_zone_stats: null,
  update_location_interval: 60000,
  waiting_rides_interval: 60000,
  archiveRide: () => {},
  cancelRide: () => {},
  claimRide: () => {},
  fetchRides: () => {},
  fetchStatus: () => {},
  fetchRideZoneStats: () => {},
  pickupRide: () => {},
  submitAvailable: () => {},
  submitLocation: () => {},
  submitUnavailable: () => {},
  ...props,
});

describe('RideContainer', () => {
  it('submits location and fetches rides on mount', () => {
    const mockedSubmitLocation = jest.fn();
    const mockedFetchRides = jest.fn();
    const wrapper = shallow(
      <RideContainer
        {...makeProps({
          submitLocation: mockedSubmitLocation,
          fetchRides: mockedFetchRides,
        })}
      />
    );
    expect(mockedSubmitLocation).toHaveBeenCalledTimes(1);
    expect(mockedFetchRides).toHaveBeenCalledTimes(1);
  });
  it('sends API requests based on an interval', () => {
    const threeMinutes = 60 * 3 * 1000;
    const mockedSubmitLocation = jest.fn();
    const mockedFetchRides = jest.fn();
    const wrapper = shallow(
      <RideContainer
        {...makeProps({
          submitLocation: mockedSubmitLocation,
          fetchRides: mockedFetchRides,
        })}
      />
    );
    jest.advanceTimersByTime(threeMinutes);
    expect(mockedSubmitLocation).toHaveBeenCalledTimes(4);
    expect(mockedFetchRides).toHaveBeenCalledTimes(4);
  });
  it('renders ActiveRide', () => {
    const wrapper = shallow(
      <RideContainer {...makeProps({ rides: { active_ride: mockRide() } })} />
    );
    expect(wrapper.find('ActiveRide').length).toEqual(1);
  });
  it('renders WaitingRidesContainer', () => {
    const wrapper = shallow(
      <RideContainer
        {...makeProps()}
      />
    );
    expect(wrapper.find('WaitingRidesContainer').length).toEqual(1);
  });
});
