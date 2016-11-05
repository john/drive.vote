import React from 'react';
import autobind from 'autobind-decorator';
import WaitingRidesContainer from '../containers/WaitingRidesContainer';
import ActiveRide from '../components/ActiveRide';
@autobind
class RideContainer extends React.Component {

    componentDidMount() {
        this.locationInterval = setInterval(() => this.props.submitLocation(this.props.state.driverState.location), this.props.state.driverState.update_location_interval);
        this.ridesInterval = setInterval(() => this.props.fetchWaitingRides(this.props.state.driverState.location), this.props.state.driverState.waiting_rides_interval);
    }

    componentWillUnmount() {
        clearInterval(this.locationInterval);
        clearInterval(this.ridesInterval);
    }

    render() {
        if (this.props.state.driverState.active_ride) {
            return <ActiveRide {...this.props} ride={this.props.state.driverState.active_ride} />
        } else {
            return <WaitingRidesContainer {...this.props} />
        }
    }
};

export default RideContainer;
