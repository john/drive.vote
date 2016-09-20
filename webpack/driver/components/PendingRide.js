import React from 'react';

import autobind from 'autobind-decorator';

@autobind
class PendingRide extends React.Component {

    render() {
        const ride = this.props.ride;
            return (
              <div className="panel panel-default panel-ride">
                  <div>Ride #{ride.id}</div>
                  <div>Name: <span className="panel-detail">{ride.name}</span></div>
                  <div className="m-b">Pickup at: <span className="panel-detail">{ride.from_address}</span></div>
                  <button className="btn btn-success btn-sm center-block"  onClick={()=>this.props.claimRide(ride)}>Accept Ride</button>
              </div>
            )
    }

};

export default PendingRide;
