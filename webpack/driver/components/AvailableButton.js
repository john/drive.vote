import React from 'react';

class AvailableButton extends React.Component {
    render() {
        return (
            <div className="bottom-controls">
                <button className="btn btn-lg btn-success" onClick={this.props.submitAvailable}>Start driving</button>
            </div>
        )
    }
};

export default AvailableButton;
