import React from 'react';

import autobind from 'autobind-decorator';

@autobind
class PendingRide extends React.Component {


//     id(pin):1
// voter_id(pin):1
// ride_zone_id(pin):2
// name(pin):"New Test Ride"
// description(pin):"This is a description"
// status(pin):"waiting_assignment"
// driver_id(pin):3
// from_latitude(pin):null
// from_longitude(pin):null
// from_address(pin):null
// to_latitude(pin):null
// to_longitude(pin):null
// to_address(pin):null
// additional_passengers(pin):3
// special_requests(pin):"Needs other stuff"
// from_city(pin):null
// to_city(pin):null
// status_updated_at(pin):1474145117
// to_state(pin):""
// from_state(pin):""
// from_zip(pin):""
// to_zip(pin):""
// conversation_id(pin):null
// pickup_at(pin):1474145040

    render() {
        const ride = this.props.ride;
        const passengers = 1 + parseInt(ride.additional_passengers);
            return (
                <div className="panel pending-ride row">
                    <div className="col-xs-6">
                        <h3>{ride.name}</h3> 
                   <p>{passengers} People</p>
                    <p>Read More .. </p>
                    </div>
                    <div className="col-xs-6">
                        <h4>Now .4mi</h4>
                        <p>{ride.from_address}</p>
                        <p>{ride.from_city}, {ride.from_state} {ride.from_zip}</p>
                    </div>
                </div>
            )  
    }

};

export default PendingRide;
