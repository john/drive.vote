import React from 'react';

class Loading extends React.Component {

    render() {
        return (
			<div className="jumbotron text-center">
				<h1><i className="fa fa-circle-o-notch fa-spin"></i></h1>
				<p>Loading...</p>
			</div>
        )
    }
};

export default Loading;
