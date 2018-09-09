import React from 'react';
import PropTypes from 'prop-types';
import PendingRide from '../components/PendingRide';
import UnavailableButton from '../components/UnavailableButton';

const WaitingRidesContainer = props => {
  const {
    rides: { waiting_rides },
    completedRide,
    isFetching,
  } = props;

  let loadingIndicator;
  if (isFetching) {
    loadingIndicator = (
      <p className="display-3">
        <i className="fa fa-circle-o-notch fa-spin" />
        Checking for new ride requests
      </p>
    );
  } else {
    loadingIndicator = (
      <p className="display-3">New rides will load automatically</p>
    );
  }

  let completedRideComponent;
  if (completedRide) {
    completedRideComponent = (
      <div className="banner banner-success">
        <h4 className="m-b-0 text-center">
          <i className="fa fa-thumbs-up pull-left" /> {completedRide.name}{' '}
          dropped off
        </h4>
      </div>
    );
  }

  if (waiting_rides.length) {
    return (
      <div>
        <ul className="panel-list">
          {completedRide && completedRideComponent}
          {waiting_rides.map((ride, i) => (
            <PendingRide {...props} key={i} i={i} ride={ride} />
          ))}
        </ul>
        <UnavailableButton submitUnavailable={props.submitUnavailable} />
      </div>
    );
  }
  return (
    <div className="searching-container">
      {completedRide && completedRideComponent}
      <div className="jumbotron text-center">
        <h1>
          <i className="fa fa-map-o text-info" />
        </h1>
        <p>No voters in your area currently need a ride</p>
        <p className="m-t-md display-3">
          <strong className="text-success">
            <i className="fa fa-check-circle-o" />
            Connected to Dispatch
          </strong>
        </p>
        {loadingIndicator}
      </div>
      <UnavailableButton submitUnavailable={props.submitUnavailable} />
    </div>
  );
};

WaitingRidesContainer.propTypes = {
  completedRide: PropTypes.object,
  isFetching: PropTypes.bool.isRequired,
  rides: PropTypes.object.isRequired,
  submitUnavailable: PropTypes.func.isRequired,
};

export default WaitingRidesContainer;
