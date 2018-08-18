import React from 'react';

const UnavailableButton = ({ submitUnavailable }) => (
  <div className="bottom-controls fixed">
    <button className="btn btn-danger btn-api" onClick={submitUnavailable}>
      Stop driving
    </button>
  </div>
);

export default UnavailableButton;
