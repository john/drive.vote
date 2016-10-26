import React from 'react';
import autobind from 'autobind-decorator';

@autobind
class LocationManager extends React.Component {


    constructor(props) {
        super(props);
        this.state = { location: false };
    }

    componentWillMount() {
        const queryArgs = this.props.location.query;
        if (queryArgs.latitude && queryArgs.longitude) {
            const testLocation = {
                coords: {
                    latitude: queryArgs.latitude,
                    longitude: queryArgs.longitude
                }
            };
            this.props.setLocation(testLocation);
            this.updateLocationState(true);
        }
    }

    setupLocationStatus() {
        var self = this;
        let locationAvailable = true;
        let errorCount = 0;
        if ("geolocation" in navigator) {
            navigator.geolocation.watchPosition(function(position) {
                self.props.setLocation(position);
                errorCount = 0;
            }, function(error) {
                //   0: unknown error
                //   1: permission denied
                //   2: position unavailable (error response from locaton provider)
                //   3: timed out
                console.log('Something went wrong getting location:', error);
                if (error.code === 1) {
                    console.log('User denied access');
                    locationAvailable = false;
                    self.updateLocationState(locationAvailable);
                } else {
                    errorCount++;
                }
            });
        } else {
            locationAvailable = false;
        }
        if (errorCount >= 10) {
            console.log('Something is wrong with location tracking...');
            // TODO: Implement location not available warning
        }
        this.updateLocationState(locationAvailable);
    }

    updateLocationState(locationAvailable) {
        this.setState({
            location: locationAvailable
        });
    }

    componentDidMount() {
        if (this.state.location) {
            const locationInterval = setInterval(() => this.props.submitLocation(this.props.state.driverState.location), 60000);
            const ridesInterval = setInterval(() => this.props.fetchWaitingRides(this.props.state.driverState.location), 10000);
        }
    }

    render() {
        if (this.state.location) {
            return null
        } else {
            return (
                <div className="container">
                <div className="panel panel-default panel-full text-center">
                <h1><i className="fa fa-map-marker text-info"></i></h1>
                  <h6>Enable Location.</h6>
                  <p>Get started by allowing Drive the Vote access to your location</p>
                  <button className="btn btn-success p-x-lg" onClick={this.setupLocationStatus}>Ok</button>
                </div>
              </div>
            )
        }
    }

};

export default LocationManager;
