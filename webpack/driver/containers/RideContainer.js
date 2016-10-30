import React from 'react';
import autobind from 'autobind-decorator';
import WaitingRidesContainer from '../containers/WaitingRidesContainer';
import ActiveRide from '../components/ActiveRide';
@autobind
class RideContainer extends React.Component {

    render() {
        if (this.props.state.driverState.active_ride) {
            return <ActiveRide {...this.props} ride={this.props.state.driverState.active_ride} />
        } else {
            return <WaitingRidesContainer {...this.props} />
        }
    }
};

export default RideContainer;
