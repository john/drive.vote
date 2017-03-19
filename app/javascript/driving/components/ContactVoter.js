import React from 'react';

class ContactVoter extends React.Component {
    render() {
        let tel = `tel:${this.props.voter_phone_number}`;
        let sms = `sms:${this.props.voter_phone_number}`;
        return (
			<div className="row m-b">
				<div className="col-xs-6">
					<a className="btn btn-gray btn-block" href={tel}><i className="fa fa-phone p-r"></i>Call</a>
				</div>
				<div className="col-xs-6 p-l-0">
					<a className="btn btn-gray btn-block" href={sms}><i className="fa fa-comment p-r"></i>Message</a>
				</div>
			</div>
        )
    }
};

export default ContactVoter;
