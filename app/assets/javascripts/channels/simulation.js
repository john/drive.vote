// app/assets/javascripts/channels/ride_zone.js

//= require cable
//= require_self
//= require_tree .

// Call this from the dispatch page to set up the RideZoneChannel to the server
function createSimulationChannel(receiveCallBack) {
  "use strict";

  App.simulation = App.cable.subscriptions.create({channel: 'SimulationChannel'}, {
    // Built-in, called by framework whenever connection is established
    connected: function (data) {
      console.log('Simulation connection to server established'); // debugging
    },

    // Built-in, called by framework whenever connection is broken
    disconnected: function() {
      console.log('Simulation connection to server disconnected'); // debugging
    },

    // Built-in, called by framework whenever data arrives from server
    received: function(data) {
      console.log('SimulationChannel got event ' + JSON.stringify(data)); // debugging
      receiveCallBack(data);
    }
  });
}