import React from 'react';
import autobind from 'autobind-decorator';
import RideContainer from '../containers/RideContainer';
import Unavailable from '../components/Unavailable';
import Loading from '../components/Loading';
@autobind
class DriverStatusContainer extends React.Component {

    componentWillMount() {
        this.props.fetchStatus();
    }

    componentDidMount() {
        const locationInterval = setInterval(() => this.props.submitLocation(this.props.state.driverState.location), 60000);
        const ridesInterval = setInterval(() => this.props.fetchWaitingRides(this.props.state.driverState.location), 10000);
    }

    render() {
        if (!this.props.state.driverState.initialFetch) {

            if (this.props.state.driverState.available) {
                return (
                    <RideContainer {...this.props} />
                )
            } else {
                return <Unavailable {...this.props} />
            }
        } else {
            return <Loading />
        }
    }
};
export default DriverStatusContainer;
