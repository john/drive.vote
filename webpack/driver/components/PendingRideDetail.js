import React from 'react';

import autobind from 'autobind-decorator';

@autobind
class PendingRideDetail extends React.Component {


    render() {
        console.log('ride props', this.props);
        const ride = this.props.ride;
        const passengers = 1 + parseInt(ride.additional_passengers);
        let fromMapLink = `https://www.google.com/maps?saddr=My+Location&daddr=${ride.from_address}, ${ride.from_city}, ${ride.from_state}`;
        let tel = `tel:${ride.voter_phone_number}`;
        let sms = `sms:${ride.voter_phone_number}`;

        return (
            <div className="panel panel-full">
                <div className="rideDetails">
                    <a className="directionsLink pull-right" target="_blank" href={fromMapLink}><i className="fa fa-map-marker"></i> Directions</a>
                        <label>Accept Ride:</label>
                        <h3>{ride.name}</h3>
                    <p>
                        {ride.from_address}<br />
                        {ride.from_city}, {ride.from_state} {ride.from_zip}
                    </p>
                    <div className="row">
                        <div className="col-xs-6">
                            <a className="btn btn-gray btn-block" href={tel}><i className="fa fa-phone p-r"></i>Call</a>
                        </div>
                        <div className="col-xs-6">
                            <a className="btn btn-gray btn-block" href={sms}><i className="fa fa-comment p-r"></i>Message</a>
                        </div>
                    </div>
                    <div className="secondary-info m-t">
                        <p>Total Passengers: {passengers}</p>
                        <p>Description: {ride.description}</p>
                        <p>Special requests: {ride.special_requests}</p>
                    </div>
                </div>
                <div className="bottom-controls secondary">
                    <button className="btn btn-success btn-lg" onClick={()=>this.props.claimRide(ride)}>Accept</button>
                    <button className="btn btn-secondary" onClick={()=>this.props.declineRide()}>Back to list of Voters</button>
                </div>
            </div>
        )

    }
}


export default PendingRideDetail;
