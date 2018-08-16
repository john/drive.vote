import React from 'react';

class UnavailableButton extends React.Component {
    render() {
        return (
            <div className="bottom-controls fixed">
              <button className="btn btn-danger btn-api" onClick={this.props.submitUnavailable}>Stop driving</button>
            </div>
        )
    }
};

export default UnavailableButton;