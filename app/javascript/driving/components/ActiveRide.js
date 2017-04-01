import React from 'react';
import autobind from 'autobind-decorator';
import ContactVoter from '../components/ContactVoter';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';
import DispatchMatch from '../components/DispatchMatch';

@autobind
class ActiveRide extends React.Component {

    render() {
        let mapLink;
        const ride = this.props.ride;
        const passengers = 1 + parseInt(ride.additional_passengers);

        switch (ride.status) {
            case 'waiting_acceptance':
                return <DispatchMatch ride={this.ride} {...this.props} />
            case 'driver_assigned':
                mapLink = `https://maps.apple.com/?daddr=${ride.from_address}, ${ride.from_city}, ${ride.from_state}`;
                return (
                    <div className="panel panel-full p-y-sm">
                        <a className="directionsLink" target="_blank" href={mapLink}><i className="fa fa-map-marker"></i> Directions</a>
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
                mapLink = `https://maps.apple.com/?daddr=${ride.to_address}, ${ride.to_city}, ${ride.to_state}`;
                return (
                    <div className="panel panel-full p-y-sm">
                        <a className="directionsLink" target="_blank" href={mapLink}><i className="fa fa-map-marker"></i> Directions</a>
                        <label>Dropping off:</label>
                        <h3>{ride.name}</h3>
                        <p>
                            {ride.to_address}<br />
                            {ride.to_city}, {ride.to_state} {ride.to_zip}
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
                       <h2>Ride with an unknown Status!</h2>
                    </div>
                )
        }
    }
}


export default ActiveRide;
