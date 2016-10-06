import React from 'react';

import autobind from 'autobind-decorator';

@autobind
class PendingRideDetail extends React.Component {


    render() {
        console.log('ride props', this.props);
        const ride = this.props.ride;
        const passengers = 1 + parseInt(ride.additional_passengers);
        let fromMapLink = `https://www.google.com/maps?saddr=My+Location&daddr=${ride.from_address}, ${ride.from_city}, ${ride.from_state}`;

        return (
            <div className="panel panel-full">
                <div className="rideDetails">
                    <a className="btn btn-info btn-sm pull-right" target="_blank" href={fromMapLink}><i className="fa fa-map-marker"></i> Directions</a>
                        <label>Picking up:</label>
                        <h3>{ride.name}</h3>
                    <p>
                        {ride.from_address}<br />
                        {ride.from_city}, {ride.from_state} {ride.from_zip}
                    </p>
                    <div className="secondary-info">
                        <p>Total Passengers: {passengers}</p>
                        <p>Description: {ride.description}</p>
                        <p>Special requests: {ride.special_requests}</p>
                    </div>
                </div>
                <div className="bottom-controls secondary">
                    <button className="btn btn-success btn-lg" onClick={()=>this.props.claimRide(ride)}>Accept Ride</button>
                    <button className="btn btn-secondary" onClick={()=>this.props.declineRide()}>Back to list of Voters</button>
                </div>
            </div>
        )

    }
}


export default PendingRideDetail;
