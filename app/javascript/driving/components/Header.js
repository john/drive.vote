import React from 'react';

const Header = ({ ride_zone_id }) => (
  <nav className="container text-center p-y-sm">
    <a>
      <img
        className="logo pull-left"
        src="/assets/dtv-logo-260w-eng-48cb2592520fc976c4cf3a9b47b4b23403b86e31972fea5dd4603a893cd8230e.png"
      />
    </a>
    <div className="pull-right nav-links">
      {ride_zone_id && <a href={`./ride/${ride_zone_id}`}>Request a ride</a>}
      <a href="./users/sign_out">Sign out</a>
    </div>
  </nav>
);

export default Header;
