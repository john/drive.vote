import React from 'react';

import autobind from 'autobind-decorator';

import Loading from '../components/Loading.js';
import AvailableButton from '../components/AvailableButton.js';



@autobind
class Unavilable extends React.Component {

    componentWillMount() {
        this.props.fetchRideZoneStats();

    }

    render() {
        console.log(this.props.state.driverState.ride_zone_stats);

        if (this.props.state.driverState.ride_zone_stats) {
            return (
                <div className="searching-container">
                    <div className="jumbotron text-center">
                        <h1><i className="fa fa-circle-o-notch fa-spin text-info"></i></h1>
                        <p><strong>TODO: MAP</strong></p>
                    </div>
                    <AvailableButton submitAvailable={this.props.submitAvailable} />
                </div>
            )
        } else {
            return <Loading />
        }
    }

};

export default Unavilable;
