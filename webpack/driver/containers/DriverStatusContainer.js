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
