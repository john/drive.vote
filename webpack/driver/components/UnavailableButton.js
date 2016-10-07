import React from 'react';

class UnavailableButton extends React.Component {
    render() {
        return (
            <div className="bottom-controls">
				<button className="btn btn-danger" onClick={this.props.submitUnavailable}>Stop driving</button>
			</div>
        )
    }
};

export default UnavailableButton;