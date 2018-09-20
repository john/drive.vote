import React from 'react';
import renderer from 'react-test-renderer';
import ActiveRide from './ActiveRide';

const makeProps = rideProps => ({
  ride: {
    additional_passengers: 0,
    from_address: '123 Jest Street',
    from_city: 'Testville',
    from_state: 'CA',
    from_zip: '11222',
    name: 'Dan Abramov',
    special_requests: '',
    status: 'waiting_acceptance',
    to_address: '456 Foobarbaz Blvd',
    to_city: 'Snapshot City',
    to_state: 'CA',
    to_zip: '60622',
    voter_phone_number: '312-867-5309',
    ...rideProps,
  },
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
