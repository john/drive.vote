import React from 'react';
import PropTypes from 'prop-types';

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

AvailableButton.propTypes = {
  submitAvailable: PropTypes.func.isRequired,
};

export default AvailableButton;
