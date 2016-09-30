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
                  <div>
                    <a className="btn btn-info btn-ride btn-xs btn-nrby-call" target="_blank" href="tel:{ride.voter_phone_number}">📞 Call rider</a>
                    <a className="btn btn-warning btn-ride btn-xs btn-nrby-sms" target="_blank" href="sms:{ride.voter_phone_number}">📱 Txt rider</a>
                    <a className="btn btn-success btn-ride btn-xs btn-nrby-accept" onClick={()=>this.props.claimRide(ride)}>👍 Accept Ride</a>
                  </div>

              </div>
            )
    }

};

export default PendingRide;
