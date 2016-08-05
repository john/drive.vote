// app/assets/javascripts/channels/driving.js

//= require cable
//= require_self
//= require_tree .

// Call this from the driving page to set up the DrivingChannel to the server
// Then use App.driving.XXX methods to communicate to the server
function createDrivingChannel(connectedCallBack, disconnectedCallBack, receiveCallBack) {
  "use strict";

  App.driving = App.cable.subscriptions.create('DrivingChannel', {
    // Built-in, called by framework whenever connection is established
    connected: function (data) {
      console.log('DriverChannel connection to server established'); // debugging
      connectedCallBack();
    },

    // Built-in, called by framework whenever connection is broken
    disconnected: function() {
      console.log('DriverChannel connection to server disconnected'); // debugging
      disconnectedCallBack();
    },

    // Built-in, called by framework whenever data arrives from server
    received: function(data) {
      console.log('DriverChannel got data ' + JSON.stringify(data)); // debugging
      receiveCallBack(data);
    },

    // Outbound, send current location to server
    send_location: function() {
      if ("geolocation" in navigator) {
        navigator.geolocation.getCurrentPosition(
          function(position) {
            var data = {'latitude': position.coords.latitude, 'longitude': position.coords.longitude};
            this.perform('location_update', data);
          },
          function() {
            console.log('unable to get current position')
          }
        )
      }
      else {
        console.log('there is no geolocation available')
      }
    },

    // Outbound, send available status to server
    send_available: function() {
      console.log('sending available')
      this.perform('available');
    },

    // Outbound, send unavailable status to server
    send_unavailable: function() {
      console.log('sending unavailable')
      this.perform('unavailable');
    }
  });
}
