import React from 'react';
import { shallow } from 'enzyme';
import WaitingRidesContainer from './WaitingRidesContainer';
import { mockRide } from '../utilities/helpers';

jest.useFakeTimers();

const makeProps = props => ({
  isFetching: false,
  rides: {
    waiting_rides: [mockRide(), mockRide(), mockRide()],
    isFetching: false,
  },
  claimRide: () => {},
  submitUnavailable: () => {},
  ...props,
});

describe('WaitingRidesContainer', () => {
  it('renders a list of available rides', () => {
    const wrapper = shallow(<WaitingRidesContainer {...makeProps()} />);
    expect(wrapper.find('PendingRide').length).toEqual(3);
  });
  it('renders an empty state', () => {
    const wrapper = shallow(
      <WaitingRidesContainer {...makeProps({ rides: { waiting_rides: [] } })} />
    );
    expect(wrapper.find('.searching-container').length).toEqual(1);
  });
  it('renders a completed ride banner', () => {
    const wrapper = shallow(
      <WaitingRidesContainer
        {...makeProps({
          rides: { waiting_rides: [], completedRide: { name: "I'm done!" } },
        })}
      />
    );
    expect(wrapper.find('.banner-success').length).toEqual(1);
  });
});
