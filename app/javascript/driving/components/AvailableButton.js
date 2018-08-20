import React from 'react';

const AvailableButton = ({ submitAvailable }) => (
  <div className="bottom-controls fixed">
    <button
      type="button"
      className="btn btn-lg btn-success btn-api"
      onClick={submitAvailable}
    >
      Start driving
    </button>
  </div>
);

export default AvailableButton;
