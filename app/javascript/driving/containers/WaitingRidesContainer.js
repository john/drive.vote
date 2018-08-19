import React from 'react';
import PendingRide from '../components/PendingRide';
import UnavailableButton from '../components/UnavailableButton';

const RideListContainer = props => {
  const { rides: availableRides, completedRide, isFetching } = props.state.driverState;

  let loadingIndicator;
  if (isFetching) {
    loadingIndicator = (
      <p className="display-3">
        <i className="fa fa-circle-o-notch fa-spin" />
        Checking for new ride requests
      </p>
    );
  } else {
    // TODO: Transition state to make this not jarring on very fast connections
    loadingIndicator = (
      <p className="display-3">New rides will load automatically</p>
    );
  }

  if (availableRides.length) {
    return (
      <div>
        <ul className="panel-list">
          {completedRide && (
            <div className="banner banner-success">
              <h4 className="m-b-0 text-center">
                <i className="fa fa-thumbs-up pull-left" />
                {` ${completedRide.name}`}
                dropped off
              </h4>
            </div>
          )}
          {availableRides.map((ride, i) => (
            <PendingRide {...props} key={i} i={i} ride={ride} />
          ))}
        </ul>
        <UnavailableButton submitUnavailable={props.submitUnavailable} />
      </div>
    );
  }
  return (
    <div className="searching-container">
      {completedRide}
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

export default RideListContainer;
