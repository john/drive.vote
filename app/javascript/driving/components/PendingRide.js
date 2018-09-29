import React from 'react';
import PropTypes from 'prop-types';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

import { formatTime, RidePropTypes } from '../utilities/helpers';
import PendingRideDetail from './PendingRideDetail';
import ActiveRide from './ActiveRide';

class PendingRide extends React.Component {
  constructor(props) {
    super(props);
    this.state = { clicked: false };

    this.declineRide = this.declineRide.bind(this);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    this.setState({
      clicked: true,
    });
  }

  declineRide() {
    this.setState({
      clicked: false,
    });
  }

  render() {
    const { ride } = this.props;

    if (ride.status === 'waiting_acceptance') {
      return (
        <ReactCSSTransitionGroup
          transitionName="dispatchMatch"
          transitionAppear
          transitionAppearTimeout={500}
        >
          <ActiveRide ride={this.ride} {...this.props} />
        </ReactCSSTransitionGroup>
      );
    }
    const time = formatTime(ride.pickup_at);
    const passengers = 1 + parseInt(ride.additional_passengers, 10);
    const name = ride.name ? ride.name : ride.voter_phone_number;
    let specialRequests;
    let requestLabel;

    if (
      ride.special_requests.length &&
      ride.special_requests.toLowerCase() !== 'none'
    ) {
      specialRequests = (
        <div className="col-xs-12">
          <p className="special-requests">{ride.special_requests}</p>
        </div>
      );
      requestLabel = <p className="special-requests p-t">Special Requests:</p>;
    }
    if (!this.state.clicked) {
      return (
        <div
          className="panel pending-ride row p-x-0"
          onClick={() => this.handleClick()}
        >
          <div className="col-xs-7">
            <h3>{name}</h3>
            <p>
              Total Passengers:&nbsp;
              {passengers}
            </p>
            <p>
              Requested Pickup Time:&nbsp;
              {time}
            </p>
            {requestLabel}
          </div>
          <div className="col-xs-5 p-l-0">
            <h4>
              <span className="p-l">{`${ride.distance_to_voter} mi`}</span>
            </h4>
            <p>{ride.from_address}</p>
            <p>{`${ride.from_city}, ${ride.from_state} ${ride.from_zip}`}</p>
          </div>
          {specialRequests}
          <i className="fa fa-angle-right pendingArrow" />
        </div>
      );
    }
    return <PendingRideDetail {...this.props} declineRide={this.declineRide} />;
  }
}

PendingRide.propTypes = {
  ride: RidePropTypes,
  claimRide: PropTypes.func.isRequired,
};

export default PendingRide;
