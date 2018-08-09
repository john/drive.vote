import React from 'react';
import autobind from 'autobind-decorator';
import PendingRide from '../components/PendingRide';
import ActiveRide from '../components/ActiveRide';
import UnavailableButton from '../components/UnavailableButton';

autobind
class RideListContainer extends React.Component {

    render() {
        const availableRides = this.props.state.driverState.rides;
        const isFetching = this.props.state.driverState.isFetching;
        let completedRide;
        if (this.props.state.driverState.completedRide) {
            completedRide = (
                <div className="banner banner-success">
                    <h4 className="m-b-0 text-center"><i className="fa fa-thumbs-up pull-left"></i> {this.props.state.driverState.completedRide.name} dropped off</h4>
                </div>
            );
        }
        let loadingIndicator;
        if (isFetching) {
            loadingIndicator = (<p className="display-3"><i className="fa fa-circle-o-notch fa-spin"></i> Checking for new ride requests</p>);
        } else {
            //TODO: Transition state to make this not jarring on very fast connections
            loadingIndicator = (<p className="display-3">New rides will load automatically</p>);
        }

        if (availableRides.length) {
            return (
                <div>
                    <ul className="panel-list">
                        {completedRide}
                        {availableRides.map((ride, i) => <PendingRide {...this.props} key={i} i={i} ride={ride} />)}
                    </ul>
                    <UnavailableButton submitUnavailable={this.props.submitUnavailable} />
                </div>
            )
        } else {
            return (
                <div className="searching-container">
                    {completedRide}
                    <div className="jumbotron text-center">
                        <h1><i className="fa fa-map-o text-info"></i></h1>
                        <p>No voters in your area currently need a ride</p>
                        <p className="m-t-md display-3"><strong className="text-success"><i className="fa fa-check-circle-o"></i> Connected to Dispatch</strong></p>
                            {loadingIndicator}
                        </div>
                       <UnavailableButton submitUnavailable={this.props.submitUnavailable} />
                    </div>
            )
        }
    }

};

export default RideListContainer;
