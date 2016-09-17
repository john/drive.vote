import React from 'react';
import autobind from 'autobind-decorator';

import PendingRide from '../components/PendingRide.js';
import ActiveRide from '../components/ActiveRide.js';


@autobind
class RideListContainer extends React.Component {



    render() {
        const availableRides = this.props.state.driverState.rides;

        if (this.props.state.driverState.active_ride && this.props.state.driverState.active_ride.id) {
            return <ActiveRide {...this.props} ride={this.props.state.driverState.active_ride} />

        } else {
            if (this.props.state.driverState.available) {
                if (availableRides.length) {
                    return (
                        <div>
                            <ul className="panel-list">
                                {availableRides.map((ride, i) => <PendingRide {...this.props} key={i} i={i} ride={ride} />)}
                            </ul>
                            <div className="bottom-controls">
                                <button className="btn btn-danger" onClick={this.props.submitUnavailable}>Stop driving</button>
                            </div>
                        </div>
                    )
                } else {
                    return (
                        <div className="searching-container">
                            <div className="jumbotron text-center">
                                <h1><i className="fa fa-circle-o-notch fa-spin text-info"></i></h1>
                                <p><strong>Looking for voters...</strong></p>
                            </div>
                            <div className="bottom-controls">
                                <button className="btn btn-danger" onClick={this.props.submitUnavailable}>Stop driving</button>
                            </div>
                        </div>
                    )
                }
            }
        }
    }

};

export default RideListContainer;
