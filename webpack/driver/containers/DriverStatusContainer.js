import React from 'react';
import autobind from 'autobind-decorator';
import { isObjectEqual } from '../helpers/Equal'

import RideListContainer from '../containers/RideListContainer';
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
                return <RideListContainer {...this.props} />
            } else {
                return <Unavailable {...this.props} />
            }
        } else {
            return <Loading />
        }
    }

};

export default DriverStatusContainer;
