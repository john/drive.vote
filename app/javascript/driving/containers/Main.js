import React from 'react';
import Header from '../components/Header';
import AppError from '../components/AppError';
import '../styles/drive-vote.css';

const Main = props => {
  let fetchClass;
  if (props.state.driverState.changePending) {
    fetchClass = 'fetching';
  } else {
    fetchClass = '';
  }
  return (
    <div className={fetchClass}>
      <Header {...props} />
      <AppError
        errorState={props.state.driverState.error}
        clearError={props.clearError}
      />
      <div className="container p-a-0">
        {React.cloneElement(props.children, props)}
      </div>
    </div>
  );
};

export default Main;
