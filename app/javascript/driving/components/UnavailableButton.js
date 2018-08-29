import React from 'react';
import PropTypes from 'prop-types';

const UnavailableButton = ({ submitUnavailable }) => (
  <div className="bottom-controls fixed">
    <button className="btn btn-danger btn-api" onClick={submitUnavailable}>
      Stop driving
    </button>
  </div>
);

UnavailableButton.propTypes = {
  submitUnavailable: PropTypes.func.isRequired,
};

export default UnavailableButton;
