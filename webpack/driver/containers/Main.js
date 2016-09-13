import React from 'react';
import autobind from 'autobind-decorator';

import Header from '../components/Header';
import LocationManager from '../helpers/LocationManager';
import '../styles/drive-vote.css';

@autobind
class Main extends React.Component {
    
    render() {
        return (
            <div>
                <Header logout={this.logout} />
                <LocationManager {...this.props} />
                <div className="container">
                    {React.cloneElement(this.props.children, this.props)}
                </div>
            </div>

        )
    }
};

export default Main;
