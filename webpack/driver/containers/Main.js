import React from 'react';
import autobind from 'autobind-decorator';

import Header from '../components/Header';
import LocationManager from '../helpers/LocationManager';
import ErrorContainer from '../containers/ErrorContainer';
import '../styles/drive-vote.css';

@autobind
class Main extends React.Component {
    
    render() {
        return (
            <div>
                <Header />
                <ErrorContainer errorState={this.props.state.driverState.error} clearError={this.props.clearError}/>
                <LocationManager {...this.props} />
                <div className="container p-a-0">
                    {React.cloneElement(this.props.children, this.props)}
                </div>
            </div>

        )
    }
};

export default Main;
