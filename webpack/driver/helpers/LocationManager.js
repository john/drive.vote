import React from 'react';
import autobind from 'autobind-decorator';

@autobind
class LocationManager extends React.Component {

    componentWillMount() {
        this.setupLocationStatus();
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
        // TODO: This is broken
        var self = this;

        // this.locationCount = this.locationCount || 0;
        // this.rideCount = this.rideCount || 0;
        // clearInterval(this.intervalCount);
        // clearInterval(this.rideCount);
        // let locationUpdateInterval = nextProps.state.driverState.update_location_interval;
        // if (locationUpdateInterval && nextProps.location) {
        const locationInterval = setInterval(function() { self.props.submitLocation(self.props.state.driverState.location) }, 5000);
        //     this.locationCount = locationInterval;

        // }
        // let waitingRidesInterval = nextProps.state.driverState.waiting_rides_interval;
        // if (waitingRidesInterval) {
        const ridesInterval = setInterval(function() { self.props.fetchWaitingRides() }, 5000);
        // const statusInterval = setInterval(function() { self.props.fetchStatus() }, 5000);
        //     this.rideCount = ridesInterval;
        // }
    }

    render() {
        if (this.state.location) {
            return null
        } else {
            return (
                <div className="container">
                <div className="panel panel-default panel-ride">
                  <h6>Drive the Vote requires you to share your location.</h6>
                  <p>Please reload to start sharing your location</p>
                </div>
              </div>
            )
        }
    }

};

export default LocationManager;
