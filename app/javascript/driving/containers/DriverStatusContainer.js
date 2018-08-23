import React from 'react';
import RideContainer from './RideContainer';
import Unavailable from '../components/Unavailable';
import Loading from '../components/Loading';

class DriverStatusContainer extends React.Component {
  componentDidMount() {
    this.props.fetchStatus();
  }

  render() {
    if (!this.props.state.driverState.initialFetch) {
      if (this.props.state.driverState.available) {
        return <RideContainer {...this.props} />;
      }
      return <Unavailable {...this.props} />;
    }
    return <Loading />;
  }
}

export default DriverStatusContainer;
