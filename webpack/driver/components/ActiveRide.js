import React from 'react';
import autobind from 'autobind-decorator';
import ContactVoter from '../components/ContactVoter';

@autobind
class ActiveRide extends React.Component {

    render() {
        console.log('ActiveRide');
        const ride = this.props.ride;
        console.log(ride.status);
        const passengers = 1 + parseInt(ride.additional_passengers);

        switch (ride.status) {
            case 'waiting_acceptance':
                return (
                    <div className="panel panel-full p-y-sm dispatcher-match">
                       <h2>Dispatcher Match</h2>
                        <a className="directionsLink" target="_blank" href={fromMapLink}><i className="fa fa-map-marker"></i> Directions</a>
                        <label>Picking up:</label>
                        <h3>{ride.name}</h3>
                        <p>
                            {ride.from_address}<br />
                            {ride.from_city}, {ride.from_state} {ride.from_zip}
                        </p>
                        <ContactVoter voter_phone_number={ride.voter_phone_number} />
                        <div className="secondary-info">
                            <p>Total Passengers: {passengers}</p>
                            <p>Special requests: {ride.special_requests}</p>
                        </div>
                        <div className="bottom-controls secondary">
                            <button className="btn btn-success btn-api" onClick={()=>this.props.claimRide(ride)}>Accept Ride</button>
                            <button className="btn btn-danger btn-api" onClick={()=>this.props.cancelRide(ride)}>Decline Ride</button>
                        </div>
                    </div>
                )
            case 'driver_assigned':
                let fromMapLink = `https://www.google.com/maps?saddr=My+Location&daddr=${ride.from_address}, ${ride.from_city}, ${ride.from_state}`;
                return (
                    <div className="panel panel-full p-y-sm">
                        <a className="directionsLink" target="_blank" href={fromMapLink}><i className="fa fa-map-marker"></i> Directions</a>
                        <label>Picking up:</label>
                        <h3>{ride.name}</h3>
                        <p>
                            {ride.from_address}<br />
                            {ride.from_city}, {ride.from_state} {ride.from_zip}
                        </p>
                        <ContactVoter voter_phone_number={ride.voter_phone_number} />
                        <div className="secondary-info">
                            <p>Total Passengers: {passengers}</p>
                            <p>Special requests: {ride.special_requests}</p>
                        </div>
                        <div className="bottom-controls secondary">
                            <button className="btn btn-success btn-api" onClick={()=>this.props.pickupRider(ride)}>Rider picked up</button>
                            <button className="btn btn-danger btn-api" onClick={()=>this.props.cancelRide(ride)}>Cancel Ride</button>
                        </div>
                    </div>
                )
            case 'picked_up':
                let toMapLink = `https://www.google.com/maps?saddr=My+Location&daddr=${ride.to_address}`;
                return (
                    <div className="panel panel-full p-y-sm">
                        <a className="directionsLink" target="_blank" href={fromMapLink}><i className="fa fa-map-marker"></i> Directions</a>
                        <label>Dropping off:</label>
                        <h3>{ride.name}</h3>
                        <p>
                            {ride.from_address}<br />
                            {ride.from_city}, {ride.from_state} {ride.from_zip}
                        </p>
                        <ContactVoter voter_phone_number={ride.voter_phone_number} />
                        <div className="secondary-info">
                            <p>Total Passengers: {passengers}</p>
                            <p>Special requests: {ride.special_requests}</p>
                        </div>
                        <div className="bottom-controls secondary">
                            <button className="btn btn-success btn-api" onClick={()=>this.props.completeRide(ride)}>Complete Ride</button>
                            <button className="btn btn-danger btn-api" onClick={()=>this.props.cancelRide(ride)}>Cancel Ride</button>
                        </div>
                    </div>
                )
            default:
                return (
                    <div className="panel panel-full p-y-sm dispatcher-match">
                       <h2>Ride With an unknown Status</h2>
                        <a className="directionsLink" target="_blank" href={fromMapLink}><i className="fa fa-map-marker"></i> Directions</a>
                        <label>Picking up:</label>
                        <h3>{ride.name}</h3>
                        <p>
                            {ride.from_address}<br />
                            {ride.from_city}, {ride.from_state} {ride.from_zip}
                        </p>
                        <ContactVoter voter_phone_number={ride.voter_phone_number} />
                        <div className="secondary-info">
                            <p>Total Passengers: {passengers}</p>
                            <p>Special requests: {ride.special_requests}</p>
                        </div>
                        <div className="bottom-controls secondary">
                            <button className="btn btn-success btn-api" onClick={()=>this.props.claimRide(ride)}>Accept Ride</button>
                            <button className="btn btn-danger btn-api" onClick={()=>this.props.cancelRide(ride)}>Decline Ride</button>
                        </div>
                    </div>
                )
        }
    }
}


export default ActiveRide;
