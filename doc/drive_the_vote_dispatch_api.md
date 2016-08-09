## Drive the Vote Dispatch API

The Drive the Vote application allows dispatchers to manage the volunteer drivers and voters in a specific "ride zone" - a geographic area with one or more polling places. This document describes the REST and event-based API's available to the UI from the backend DtV server.

### Core Concepts

*Ride Zone* - A geographic area with one or more polling places.

*Dispatcher* - A person responsible for managing conversations with voters and ensuring voters are driven to polling places and back home.

*Conversation* - A back-and-forth exchange of SMS messages. Conversations have a status - in_progress, ride_created, or closed.

*Ride* - A single vehicle trip from point A to point B.

*Driver* - A volunteer who can driver voters to the polls or back home.

### REST API

View doc/dispatch_api.yaml in editor.swagger.io for a description of the REST API

### Events API

The Rails 5 DtV server offers a web-socket connection to front-end clients over which it can stream events. This section describes those events.

All events are delivered to the front end as JSON objects with this structure:

	{
		"event_type" : "X",
		... other attributes
	}

#### Conversation Events
##### New Conversation
This event indicates a new conversation has been created in the subscribed ride zone. A conversation is created automatically when an SMS arrives from a new phone number, or when an SMS arrives from an existing voter and all their prior conversations have been closed.

	{
		"event_type" : "new_conversation",
		"conversation" : {
			"id" : unique_id_integer,
			"from_phone" : "phone number originating the conversation",
			"status" : "in_progress, ride_created, or closed",
			"lifecycle" : "need_language, need_name, need_origin, need_destination, need_time, or info_complete",
			"name" : "voter name",
			"from_address" : "address line",
			"from_city" : "city",
			"to_address" : "address line",
			"to_city" : "city",
			"pickup_at" : integer_unix_epoch_time,
			"special_requests" : "any requests"
		}
	}

##### Conversation Changed
This event indicates an existing conversation has changed its status, lifecycle, or information.

	{
		"event_type" : "conversation_changed",
		"conversation" : *same as new_conversation*
	}

#### Message Events
##### New Message
This event indicates a new message has been attached to a conversation. The message could come from the voter or from a dispatcher.

	{
		"event_type" : "new_message",
		"message" : {
			"id" : unique_id_integer,
			"conversation_id" : id_of_conversation_integer,
			"from_phone" : "phone number originating the message",
			"is_from_voter" : true | false,
			"body" : "text of the SMS message",
			"created_at" : integer_unix_epoch_time
		}
	}

#### Ride Events
##### New Ride
This event indicates a new ride has been created in the ride zone. Rides are only created when the origin, destination, and pickup time are known.

	{
		"event_type" : "new_ride",
		"ride" : {
			"id" : unique_id_integer,
			"ride_zone_id" : unique_ride_zone_id_integer,
			"status" : ""incomplete_info, scheduled, waiting_assignment, driver_assigned, picked_up, or complete""
			"conversation_id" : id_of_conversation_integer,
			"name" : "voter name",
			"from_address" : "address",
			"from_latitude" : decimal,
			"from_longitude" : decimal,
			"to_address" : "address",
			"to_latitude" : decimal,
			"to_longitude" : decimal,
			"num_passengers" : integer,
			"pickup_time" : integer_unix_epoch_time,
			"special_requests" : "any requests from voter, e.g. wheelchair, car seat"
		}
	}

##### Ride Changed
This event indicates that a ride has changed status or its information has changed.

	{
		"event_type" : "ride_changed",
		"ride" : *same as new_ride*
	}


#### Driver Events
##### New Driver
This event indicates a new driver has been added to the ride zone.

	{
		"event_type" : "new_driver",
		"driver" : {
			"id" : unique_id_integer,
			"name" : "driver name",
			"phone" : "phone number",
			"available" : true | false,
			"latitude" : decimal_number,
			"longitude" : decimal_number,
			"location_timestamp" : integer_unix_epoch_time,
			"active_ride" : nil_or_ride_object
		}
	}

##### Driver Changed
This event indicates a driver's location, ride status, or availability has changed

	{
		"event_type" : "driver_changed",
		"driver" : *same as new_driver*
	}
