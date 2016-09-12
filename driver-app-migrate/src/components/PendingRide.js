import React from 'react';

import autobind from 'autobind-decorator';

@autobind
class PendingRide extends React.Component {

    render() {
        const ride = this.props.ride;
            return (
                <div className="panel panel-default">
                    <p>Ride <label>{ride.id}</label></p>
                    <p>{ride.from_address}</p>
                    <button className="btn btn-success"  onClick={()=>this.props.claimRide(ride)}>Accept Ride</button>
                </div>
            )  
    }
};

export default PendingRide;
