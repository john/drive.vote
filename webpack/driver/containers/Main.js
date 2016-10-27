import React from 'react';
import autobind from 'autobind-decorator';

import Header from '../components/Header';
import ErrorContainer from '../containers/ErrorContainer';
import '../styles/drive-vote.css';

@autobind
class Main extends React.Component {

    render() {
        let fetchClass;
        if (this.props.state.driverState.changePending) {
            fetchClass = 'fetching';
        } else {
            fetchClass = '';
        }
        return (
            <div className={fetchClass}>
                <Header />
                <ErrorContainer errorState={this.props.state.driverState.error} clearError={this.props.clearError}/>
                <div className="container p-a-0">
                    {React.cloneElement(this.props.children, this.props)}
                </div>
            </div>

        )
    }
};

export default Main;
