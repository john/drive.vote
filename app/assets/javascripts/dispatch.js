//= require jquery-ui

// app/assets/javascripts/dispatch.js
"use strict";

var dispatchController = {

  connected: function connected() {
    $('.disp-server-status').text("Connected").toggleClass('disp-text-alert', false);
  },

  disconnected: function disconnected() {
    $('.disp-server-status').text("Disconnected").toggleClass('disp-text-alert', true);
  },

  conversationCells: function conversationCells(c) {
    var statusClass = (c.status == 'help_needed') ? 'conv-alert' : 'conv-normal';
    return '<td>' + c.from_phone + '</td>' +
      '<td class="'+statusClass+'">' + c.status + '</td>' +
      '<td>' + c.message_count + '</td>' +
        '<td><a onclick="javascript: alert(\'modal!\')">View</a></td>'
  },

  updateConversationTable: function updateConversationTable(c, highlight) {
    dispatchController.updateTable('#conversations', 'conv-row-' + c.id, dispatchController.conversationCells(c), highlight);
  },

  // Called for new conversation event
  newConversation: function newConversation(event) {
    dispatchController.updateConversationTable(event.conversation, true);
  },

  // Called when conversation changes
  conversationChanged: function conversationChanged(event) {
    dispatchController.updateConversationTable(event.conversation, true);
  },

  refreshConversations: function refreshConversations() {
    $.ajax('/api/1/ride_zones/' + dispatchController.rideZoneId + '/conversations', {
      success: function(data, status, xhr) {
        for (var i = 0; i < data.response.length; ++i) {
          var convo = data.response[i];
          dispatchController.updateConversationTable(convo, false);
        }
      },
      error: function(xhr, status, err) { $('error_msg').text(xhr.responseText) }
    });
  },

  rideCells: function rideCells(r) {
    return '<td>' + r.name + '</td>' +
      '<td>' + c.status + '</td>' +
      '<td>' + c.pickup_at + '</td>'
  },

  updateRideTable: function updateRideTable(r, highlight) {
    dispatchController.updateTable('#rides', 'ride-row-' + r.id, dispatchController.rideCells(r), highlight);
  },

  // Called when a new ride is created
  newRide: function newRide(event) {
    dispatchController.updateRideTable(event.ride, true);
    // todo: update the map
  },

  // Called when ride changes
  rideChanged: function rideChanged(event) {
    dispatchController.updateRideTable(event.ride, true);
    // todo: update the map
  },

  refreshRides: function refreshRides() {
    $.ajax('/api/1/ride_zones/' + dispatchController.rideZoneId + '/rides', {
      success: function(data, status, xhr) {
        for (var i = 0; i < data.response.length; ++i) {
          dispatchController.updateRideTable(data.response[i], false);
        }
      },
      error: function(xhr, status, err) { $('error_msg').text(xhr.responseText) }
    });
  },

  updateTable: function updateTable(tableSelector, rowId, cells, highlight) {
    var existing = $('#'+rowId);
    if (existing.length > 0) {
      existing.html(cells);
      if (highlight) { existing.effect("highlight", {}, 3000); }
    } else {
      var row = '<tr id="'+rowId+'">' + cells +'</tr>';
      $(tableSelector).prepend(row);
    }
  },

  // Handle new driver creation
  newDriver: function newDriver(event) {
    // todo: update map
  },

  // Handle driver update
  driverChanged: function driverChanged(event) {
    // todo: update map
  },

  // Handle new message
  newMessage: function newMessage(event) {
    // do we want to do anything?
  },

  eventReceived: function eventReceived(event) {
    switch (event['event_type']) {
      case 'new_conversation':
        dispatchController.newConversation(event);
        break;
      case 'conversation_changed':
        dispatchController.conversationChanged(event);
        break;
      case 'new_ride':
        dispatchController.newRide(event);
        break;
      case 'ride_changed':
        dispatchController.rideChanged(event);
        break;
      case 'new_driver':
        dispatchController.newDriver(event);
        break;
      case 'driver_changed':
        dispatchController.driverChanged(event);
        break;
      case 'new_message':
        dispatchController.newMessage(event);
        break;
    }
  },

  setup: function(rideZoneId) {
    dispatchController.rideZoneId = rideZoneId;
    dispatchController.refreshConversations();
    dispatchController.refreshRides();
    createRideZoneChannel(rideZoneId, dispatchController.connected, dispatchController.disconnected, dispatchController.eventReceived);
  }
};
