// app/assets/javascripts/channels/ride_zone.js

//= require cable
//= require_self
//= require_tree .

// Call this from the dispatch page to set up the RideZoneChannel to the server
function createRideZoneChannel(rideZoneId, connectedCallBack, disconnectedCallBack, receiveCallBack) {
  "use strict";

  if (App.ridezone) {
    App.cable.subscriptions.remove(App.ridezone)
  }
  App.ridezone = App.cable.subscriptions.create({channel: 'RideZoneChannel', id: rideZoneId}, {
    // Built-in, called by framework whenever connection is established
    connected: function (data) {
      console.log('RideZoneChannel connection to server established: '+rideZoneId); // debugging
      connectedCallBack();
    },

    // Built-in, called by framework whenever connection is broken
    disconnected: function() {
      console.log('RideZoneChannel connection to server disconnected: '+rideZoneId); // debugging
      disconnectedCallBack();
    },

    // Built-in, called by framework whenever data arrives from server
    received: function(data) {
      console.log('RideZoneChannel: '+rideZoneId + ' got data ' + JSON.stringify(data)); // debugging
      receiveCallBack(data);
    }

  });
}