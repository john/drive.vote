import React from 'react';
import autobind from 'autobind-decorator';

import RideListContainer from '../containers/RideListContainer.js';

@autobind
class DriverStatusContainer extends React.Component {

    componentWillMount() {
        this.props.fetchStatus();
    }

    render() {
        if (!this.props.state.driverState.initialFetch) {
            if (this.props.state.driverState.available) {
                return <RideListContainer {...this.props} />
            } else {
                return (
                    <div>
                        <div className="jumbotron text-center">
                            <h1><i className="fa fa-ban"></i></h1>
                            <p>Not available to drive<br /> Tap the button below to get started</p>
                        </div>
                        <button className="btn btn-success btn-bottom" onClick={this.props.submitAvailable}>Tap here to start driving</button>
                    </div>
                )
            }
        } else {
            return (
                <div className="jumbotron text-center">
                    <h1><i className="fa fa-circle-o-notch fa-spin"></i></h1>
                    <p>Loading...</p>
                </div>
            )
        }
    }

};

export default DriverStatusContainer;
