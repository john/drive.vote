import React from 'react';
import autobind from 'autobind-decorator';

@autobind
class Header extends React.Component {

    render() {
        const rzid = this.props.state.driverState.ride_zone_id;
        return (
            <nav className="container text-center p-y-sm">
	            <a><img className="logo pull-left" src="/assets/dtv-logo-260w-eng-48cb2592520fc976c4cf3a9b47b4b23403b86e31972fea5dd4603a893cd8230e.png" /></a>
	            <div className="pull-right nav-links">
                    {rzid ? <span><a href={`./ride/${rzid}`}>Request a ride</a>&nbsp;&nbsp;·&nbsp;&nbsp;</span> : null}
		            <a href="./users/sign_out">Sign out</a>
	            </div>
			</nav>
        )
    }
};

export default Header;