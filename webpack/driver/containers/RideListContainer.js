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
                        <div className="container">
                            <h5 className="text-center">Voters Found!</h5>
                            <ul>
                                {availableRides.map((ride, i) => <PendingRide {...this.props} key={i} i={i} ride={ride} />)}
                            </ul>
                            <button className="btn btn-danger btn-bottom" onClick={this.props.submitUnavailable}>Tap here to stop driving</button>
                        </div>
                    )
                } else {
                    return (
                        <div>
                            <div className="jumbotron text-center">
                                <h1><i className="fa fa-circle-o-notch fa-spin text-info"></i></h1>
                                <p>Looking for voters...</p>
                            </div>
                            <button className="btn btn-danger btn-bottom" onClick={this.props.submitUnavailable}>Tap here to stop driving</button>
                        </div>
                    )
                }
            }
        }
    }

};

export default RideListContainer;
