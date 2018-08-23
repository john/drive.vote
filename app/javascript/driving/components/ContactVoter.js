import React from 'react';

const ContactVoter = ({ voter_phone_number }) => (
  <div className="row m-b">
    <div className="col-xs-6">
      <a className="btn btn-gray btn-block" href={`tel:${voter_phone_number}`}>
        <i className="fa fa-phone p-r" />
        Call
      </a>
    </div>
    <div className="col-xs-6 p-l-0">
      <a className="btn btn-gray btn-block" href={`sms:${voter_phone_number}`}>
        <i className="fa fa-comment p-r" />
        Message
      </a>
    </div>
  </div>
);

export default ContactVoter;
