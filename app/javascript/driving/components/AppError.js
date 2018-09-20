import React from 'react';
import PropTypes from 'prop-types';

import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

// Not sure if automatically dismissing the banner is needed?
// setTimeout(() => {
//     this.props.clearError();
// }, 10000);

const AppError = ({ error, clearError }) =>
  error && (
    <div>
      <ReactCSSTransitionGroup
        transitionName="banner"
        transitionAppear
        transitionAppearTimeout={500}
        transitionLeaveTimeout={0}
        transitionEnterTimeout={0}
      >
        <div className="errorBanner" key={1}>
          {error}
          <a className="close-button" onClick={clearError}>
            <i className="fa fa-close" />
          </a>
        </div>
      </ReactCSSTransitionGroup>
    </div>
  );

AppError.propTypes = {
  error: PropTypes.string,
  clearError: PropTypes.func.isRequired,
};

export default AppError;
