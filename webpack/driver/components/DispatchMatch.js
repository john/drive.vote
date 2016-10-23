import React from 'react';
import autobind from 'autobind-decorator';
import ContactVoter from '../components/ContactVoter';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

@autobind
class DispatchMatch extends React.Component {

    render() {
        const ride = this.props.ride;
        const passengers = 1 + parseInt(ride.additional_passengers);
        const mapLink = `http://maps.apple.com/?daddr=${ride.from_address},${ride.from_city},${ride.from_state}`;
        return (
            <div>
                <ReactCSSTransitionGroup 
                transitionName="dispatchMatch" 
                transitionAppear={true} 
                transitionAppearTimeout={500}>
                    <div className="panel panel-full p-y-sm dispatcher-match">
                        <h2 className="m-b-0">Ride Assigned by Dispatch</h2>
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
                            <button className="btn btn-success btn-api" onClick={()=>this.props.claimRide(ride)}>Accept Ride</button>
                            <button className="btn btn-danger btn-api" onClick={()=>this.props.cancelRide(ride)}>Decline Ride</button>
                        </div>
                    </div>
                </ReactCSSTransitionGroup>
            </div>
        )

    }
}


export default DispatchMatch;
