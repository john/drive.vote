import React from 'react';
import autobind from 'autobind-decorator';
import ContactVoter from '../components/ContactVoter';

@autobind
class ActiveRide extends React.Component {


    render() {
        const ride = this.props.ride;
        const passengers = 1 + parseInt(ride.additional_passengers);

        switch (ride.status) {
            case 'driver_assigned':
                let fromMapLink = `https://www.google.com/maps?saddr=My+Location&daddr=${ride.from_address}, ${ride.from_city}, ${ride.from_state}`;
                return (
                    <div className="panel panel-full ">
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
                            <p>Description: {ride.description}</p>
                            <p>Special requests: {ride.special_requests}</p>
                        </div>
                        <div className="bottom-controls">
                            <button className="btn btn-success btn-lg" onClick={()=>this.props.pickupRider(ride)}>Rider picked up</button>
                            <button className="btn btn-danger" onClick={()=>this.props.cancelRide(ride)}>Cancel Ride</button>
                        </div>
                    </div>
                )
            case 'picked_up':
                let toMapLink = `https://www.google.com/maps?saddr=My+Location&daddr=${ride.to_address}`;
                return (
                    <div className="panel panel-full ">
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
                            <p>Description: {ride.description}</p>
                            <p>Special requests: {ride.special_requests}</p>
                        </div>
                        <div className="bottom-controls">
                            <button className="btn btn-success btn-lg" onClick={()=>this.props.completeRide(ride)}>Complete Ride</button>
                            <button className="btn btn-danger" onClick={()=>this.props.cancelRide(ride)}>Cancel Ride</button>
                        </div>
                    </div>
                )
            case 'complete':
                return (
                    <div className="jumbotron text-center">
                        <h1>
                            <span className="fa-stack fa-5x">
                              <i className="fa fa-certificate fa-stack-2x text-success fa-spin"></i>
                              <i className="fa fa-thumbs-up fa-stack-1x fa-inverse"></i>
                            </span>
                        </h1>
                        <p>{ride.name} has been dropped off. Keep driving to pick up another voter!</p>
                        <div className="bottom-controls">
                            <button className="btn btn-success btn-lg" onClick={()=>this.props.fetchStatus(ride)}>Keep Driving</button>
                            <button className="btn btn-danger" onClick={()=>this.props.submitUnavailable(ride)}>Stop Driving</button>
                        </div>
                    </div>
                )
            default:
                return (
                    <div className="panel panel-full dispatcher-match">
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
                            <p>Description: {ride.description}</p>
                            <p>Special requests: {ride.special_requests}</p>
                        </div>
                        <div className="bottom-controls">
                            <button className="btn btn-success btn-lg" onClick={()=>this.props.claimRide(ride)}>Accept Ride</button>
                            <button className="btn btn-danger" onClick={()=>this.props.cancelRide(ride)}>Reject</button>
                        </div>
                    </div>
                )
        }
    }
}


export default ActiveRide;
