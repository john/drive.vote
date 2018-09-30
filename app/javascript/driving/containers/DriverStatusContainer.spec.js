import React from 'react';
import { shallow } from 'enzyme';
import DriverStatusContainer from './DriverStatusContainer';

jest.useFakeTimers();

const makeProps = props => ({
  available: false,
  initialFetch: true,
  rides: {
    isFetching: false,
  },
  ride_zone_stats: null,
  update_location_interval: 0,
  waiting_rides_interval: 0,
  fetchRides: () => {},
  fetchStatus: () => {},
  fetchRideZoneStats: () => {},
  submitAvailable: () => {},
  submitLocation: () => {},
  ...props,
});

describe('DriverStatusContainer', () => {
  it('fetches driver status on mount', () => {
    const mockedFetchStatus = jest.fn();
    const wrapper = shallow(
      <DriverStatusContainer
        {...makeProps({ fetchStatus: mockedFetchStatus })}
      />
    );
    expect(mockedFetchStatus).toHaveBeenCalledTimes(1);
  });
  it('fetches driver status every 60 seconds', () => {
    const mockedFetchStatus = jest.fn();
    const wrapper = shallow(
      <DriverStatusContainer
        {...makeProps({ fetchStatus: mockedFetchStatus })}
      />
    );
    const threeMinutes = 60 * 3 * 1000;
    jest.advanceTimersByTime(threeMinutes);
    expect(mockedFetchStatus).toHaveBeenCalledTimes(4);
  });
  it('renders an initial Loader', () => {
    const wrapper = shallow(<DriverStatusContainer {...makeProps()} />);
    expect(wrapper.find('Loading').length).toEqual(1);
  });
  it('renders RideContainer', () => {
    const wrapper = shallow(
      <DriverStatusContainer
        {...makeProps({ initialFetch: false, available: true })}
      />
    );
    expect(wrapper.find('RideContainer').length).toEqual(1);
  });
  it('renders Unavailable', () => {
    const wrapper = shallow(
      <DriverStatusContainer
        {...makeProps({ initialFetch: false, available: false })}
      />
    );
    expect(wrapper.find('Unavilable').length).toEqual(1);
  });
});
