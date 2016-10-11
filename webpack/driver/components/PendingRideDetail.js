import React from 'react';
import autobind from 'autobind-decorator';
import ContactVoter from '../components/ContactVoter';

@autobind
class PendingRideDetail extends React.Component {


    render() {
        const ride = this.props.ride;
        const passengers = 1 + parseInt(ride.additional_passengers);
        let fromMapLink = `https://www.google.com/maps?saddr=My+Location&daddr=${ride.from_address}, ${ride.from_city}, ${ride.from_state}`;
        return (
            <div className="panel panel-full p-y-sm">
                    <div className="rideDetails">
                        <a className="directionsLink" target="_blank" href={fromMapLink}><i className="fa fa-map-marker"></i> Directions</a>
                            <label>Accept Ride:</label>
                            <h3>{ride.name}</h3>
                        <p>
                            {ride.from_address}<br />
                            {ride.from_city}, {ride.from_state} {ride.from_zip}
                        </p>
                        <ContactVoter voter_phone_number={ride.voter_phone_number} />
                        <div className="secondary-info m-t">
                            <p>Total Passengers: {passengers}</p>
                            <p>Special requests: {ride.special_requests}</p>
                        </div>
                    </div>
                    <div className="bottom-controls secondary">
                        <button className="btn btn-success" onClick={()=>this.props.claimRide(ride)}>Accept</button>
                        <button className="btn btn-secondary" onClick={()=>this.props.declineRide()}>Back to list of Voters</button>
                    </div>
            </div>
        )

    }
}


export default PendingRideDetail;
