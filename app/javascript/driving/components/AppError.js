import React from 'react';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

// Not sure if automatically dismissing the banner is needed?
// setTimeout(() => {
//     this.props.clearError();
// }, 10000);

const AppError = ({ errorState }) =>
  errorState && (
    <div>
      <ReactCSSTransitionGroup
        transitionName="banner"
        transitionAppear
        transitionAppearTimeout={500}
      >
        <div className="errorBanner" key={1}>
          <i className="fa fa-exclamation" />
          {this.props.errorState}
          <a className="pull-right" onClick={this.props.clearError}>
            <i className="fa fa-close" />
          </a>
        </div>
      </ReactCSSTransitionGroup>
    </div>
  );

export default AppError;
