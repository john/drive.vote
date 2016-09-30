import React from 'react';

import autobind from 'autobind-decorator';

@autobind
class ActiveRide extends React.Component {

  render() {

    const ride = this.props.ride;
    console.log('Active Ride!', ride);
    //Current status of the ride. One of waiting_assignment, driver_assigned, picked_up, complete.
    switch (ride.status) {
      case 'driver_assigned':
        let fromMapLink = `https://www.google.com/maps?saddr=My+Location&daddr=${ride.from_address}, ${ride.from_city}, ${ride.from_state}`;
        return (
            <div className="panel panel-default panel-ride">
              <div>Picking up:</div>
              <div className="panel-detail-lg"><b>{ride.name}</b> <span className="lt-gray">+{ride.additional_passengers} additional</span></div>
              <div>Address:</div>
              <div className="panel-detail-lg">{ride.from_address}</div>
              <div className="m-b">Special requests: <b className="drk-gray">{ride.special_requests}</b></div>
              <div>
                <a className="btn btn-success btn-ride btn-sm btn-call" target="_blank" href="tel:{ride.voter_phone_number}">📞 Call rider</a>
                <a className="btn btn-warning btn-ride btn-sm btn-sms" target="_blank" href="sms:{ride.voter_phone_number}">📱 Txt rider</a>
              </div>
              <a className="btn btn-info btn-block btn-ride btn-sm" target="_blank" href={fromMapLink}>Get directions</a>
              <button className="btn btn-success btn-block btn-ride btn-sm" onClick={()=>this.props.pickupRider(ride)}>Rider picked up</button>
              <button className="btn btn-danger btn-block btn-ride btn-sm" onClick={()=>this.props.cancelRide(ride)}>Cancel ride</button>
            </div>
        )
      case 'picked_up':
        let toMapLink = `https://www.google.com/maps?saddr=My+Location&daddr=${ride.to_address}`;
        return (
            <div className="panel panel-default panel-ride">
                <p>Drop off at voting station: <label>{ride.name}</label></p>
                <p>Additional passengers: <label>{ride.additional_passengers}</label></p>
                // <p>Description: <label>{ride.description}</label></p>
                <p>Special requests: <label>{ride.special_requests}</label></p>
                <p>{ride.to_address}</p>
                <a className="btn btn-info btn-block btn-ride btn-call" target="_blank" href="tel:{ride.voter_phone_number}">📞 Call rider</a>
                <a className="btn btn-info btn-block btn-ride btn-sms" target="_blank" href="sms:{ride.voter_phone_number}">📱 Txt rider</a>
                <a className="btn btn-info btn-block" target="_blank" href={toMapLink}>Get directions</a>
                <button className="btn btn-success btn-block" onClick={()=>this.props.completeRide(ride)}>Complete ride</button>
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
                <p>{ride.name} dropped off. Awesome!</p>
                <br />
                <br />
                <button className="btn btn-danger m-b" onClick={this.props.submitUnavailable}>Stop Driving</button>
                <br />
                <button className="btn btn-success" onClick={this.props.fetchStatus}>Keep Driving</button>
            </div>
        )
      default:
        console.log('should this be running?');
        this.props.fetchStatus();
        return null;
    }
  }
};

export default ActiveRide;
