import React from 'react';
import DriverStatusContainer from './DriverStatusContainer';

class LocationManager extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      location: 'prompt',
    };

    this.updateLocationState = this.updateLocationState.bind(this);
    this.setupLocationStatus = this.setupLocationStatus.bind(this);
  }

  componentDidMount() {
    const queryArgs = this.props.location.query;
    if (queryArgs.latitude && queryArgs.longitude) {
      const testLocation = {
        coords: {
          latitude: queryArgs.latitude,
          longitude: queryArgs.longitude,
        },
      };
      this.props.setLocation(testLocation);
      this.updateLocationState('available');
    }
  }

  setupLocationStatus() {
    this.updateLocationState('pending');
    if ('geolocation' in navigator) {
      navigator.geolocation.watchPosition(
        position => {
          this.props.setLocation(position);
          this.updateLocationState('available');
        },
        error => {
          //   0: unknown error
          //   1: permission denied
          //   2: position unavailable (error response from locaton provider)
          //   3: timed out
          console.log('Something went wrong getting location:', error);
          if (error.code === 1) {
            this.updateLocationState('denied');
          } else if (error.code === 2) {
            this.updateLocationState('error');
          }
        }
      );
    } else {
      this.updateLocationState('notfound');
    }
  }

  updateLocationState(location) {
    this.setState({
      location,
    });
  }

  render() {
    switch (this.state.location) {
      case 'available':
        return <DriverStatusContainer {...this.props} />;
      case 'prompt':
        return (
          <div className="container">
            <div className="panel panel-default panel-full text-center">
              <h1 className="m-y">
                <i className="fa fa-map-marker text-info" />
              </h1>
              <h6>Enable Location</h6>
              <p>
                Get started by allowing Drive the Vote access to your location.
              </p>
              <button
                type="button"
                className="btn btn-success"
                onClick={this.setupLocationStatus}
              >
                Ok
              </button>
            </div>
          </div>
        );

      case 'pending':
        return (
          <div className="container">
            <div className="panel panel-default panel-full text-center">
              <h1 className="m-y">
                <i className="fa fa-map-marker text-info" />
              </h1>
              <h6>Enable Location</h6>
              <p>
                Get started by allowing Drive the Vote access to your location.
              </p>
              <button type="button" className="btn btn-success disabled">
                Getting Location
                <i className="m-l fa fa-spinner fa-spin" />
              </button>
            </div>
          </div>
        );

      case 'error':
        return (
          <div className="container">
            <div className="panel panel-default panel-full text-center">
              <h1>
                <span className="fa-stack">
                  <i className="fa fa-map-marker fa-stack-1x text-info" />
                  <i className="fa fa-exclamation-triangle position-error fa-stack-1x text-danger" />
                </span>
              </h1>
              <h6>Location Error</h6>
              <p>Something is wrong with your GPS tracking.</p>
            </div>
          </div>
        );

      case 'denied':
        return (
          <div className="container">
            <div className="panel panel-default panel-full text-center">
              <h1>
                <span className="fa-stack">
                  <i className="fa fa-map-marker fa-stack-1x text-info" />
                  <i className="fa fa-ban fa-stack-2x text-danger" />
                </span>
              </h1>
              <h6>Location Access Denied</h6>
              <p>Sharing your location is required to drive.</p>
              <p>
                <strong>
                  <i className="fa fa-android fa-fw" />
                  {' '}
Android:
                </strong>
                {' '}
                For more information on how to re-enable access, visit:
                {' '}
                <a
                  href="https://support.google.com/chrome/answer/142065?hl=en"
                  target="_blank"
                >
                  https://support.google.com/chrome/answer/142065?hl=en
                </a>
              </p>
              <p>
                <strong>
                  <i className="fa fa-apple fa-fw" />
                  {' '}
iOS:
                </strong>
                {' '}
                Please refresh the page to try again, if that fails you will
                need to reset location warnings via the Settings App
              </p>
              <p>
                <code>
                  Settings -> General -> Reset -> Reset Location Warnings /
                  Reset Location & Privacy
                  {' '}
                </code>
              </p>
            </div>
          </div>
        );

      default:
        return null;
    }
  }
}

export default LocationManager;
