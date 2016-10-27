import React from 'react';
import h from '../helpers/helpers';
import autobind from 'autobind-decorator';
import PendingRideDetail from '../components/PendingRideDetail';
import DispatchMatch from '../components/DispatchMatch';

@autobind
class PendingRide extends React.Component {

    constructor(props) {
        super(props);
        this.state = { clicked: false };
    }

    handleClick() {
        this.setState({
            clicked: true
        });
    }

    declineRide() {
        this.setState({
            clicked: false
        })
    }

    render() {
        const ride = this.props.ride;
        if (ride.status === 'waiting_acceptance') {
            return <DispatchMatch ride={this.ride} {...this.props} />
        } else {
            const time = h.formatTime(this.props.ride.pickup_at);
            const passengers = 1 + parseInt(ride.additional_passengers);
            let name;
            if (ride.name) {
                name = ride.name;
            } else {
                name = ride.voter_phone_number;
            }
            if (!this.state.clicked) {
                return (
                    <div className="panel pending-ride row p-x-0" onClick={()=>this.handleClick()}>
                    <div className="col-xs-7">
                        <h3>{name}</h3> 
                        <p>Total Passengers: {passengers}</p>
                        <p>Read More <i className="fa fa-angle-right"></i></p>
                    </div> 
                    <div className="col-xs-5 p-l-0">
                        <h4>{time} <span className="p-l">{ride.distance_to_voter} mi</span></h4>
                        <p>{ ride.from_address }</p>
                        <p>{ ride.from_city }, { ride.from_state } { ride.from_zip }</p>
                    </div>  
                    <i className="fa fa-angle-right pendingArrow"></i>
                </div>
                )
            } else {
                return <PendingRideDetail {...this.props} declineRide={this.declineRide} />
            }
        }
    }
};

export default PendingRide;