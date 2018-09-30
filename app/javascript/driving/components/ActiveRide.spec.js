import React from 'react';
import renderer from 'react-test-renderer';
import ActiveRide from './ActiveRide';
import { mockRide } from '../utilities/helpers';

const makeProps = rideProps => ({
  ride: mockRide(rideProps),
  archiveRide: () => {},
  claimRide: () => {},
  cancelRide: () => {},
  completeRide: () => {},
  pickupRide: () => {},
});

describe('ActiveRide', () => {
  describe('handles ride states', () => {
    it('waiting_acceptance', () => {
      const tree = renderer.create(<ActiveRide {...makeProps()} />).toJSON();
      expect(tree).toMatchSnapshot();
    });

    it('waiting_assignment', () => {
      const tree = renderer
        .create(<ActiveRide {...makeProps({ status: 'waiting_assignment' })} />)
        .toJSON();
      expect(tree).toMatchSnapshot();
    });

    it('driver_assigned', () => {
      const tree = renderer
        .create(<ActiveRide {...makeProps({ status: 'driver_assigned' })} />)
        .toJSON();
      expect(tree).toMatchSnapshot();
    });

    it('picked_up', () => {
      const tree = renderer
        .create(<ActiveRide {...makeProps({ status: 'picked_up' })} />)
        .toJSON();
      expect(tree).toMatchSnapshot();
    });
  });
});
