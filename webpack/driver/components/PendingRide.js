import React from 'react';
import { isObjectEqual } from '../helpers/Equal'

import autobind from 'autobind-decorator';

@autobind
class PendingRide extends React.Component {

    shouldComponentUpdate(nextProps) {
        return !isObjectEqual(this.props.ride, nextProps.ride);
    }

    render() {

        //Setup time display
        const ride = this.props.ride;
        let time;
        if (ride.pickup_at) {
            const date = new Date(ride.pickup_at * 1000);
            const THIRTY_MINUTES = 10 * 60 * 1000;
            let hours = date.getHours();

            if (new Date() - date < THIRTY_MINUTES) {
                time = "Now";
            } else {
                if (hours > 12) {
                    hours -= 12;
                }
                time = `${hours}pm`;
            }
        } else {
            time = "!";
        }
        const passengers = 1 + parseInt(ride.additional_passengers);
        return (
            <div className="panel pending-ride row">
                <div className="col-xs-6">
                    <h3>{ride.name}</h3> 
                    <p>{passengers} People</p>
                    <p>Read More .. </p>
                </div>
                <div className="col-xs-6">
                    <h4>{time}</h4>
                    <p>{ride.from_address}</p>
                    <p>{ride.from_city}, {ride.from_state} {ride.from_zip}</p>
                </div>
            </div>
        )
    }

};

export default PendingRide;
