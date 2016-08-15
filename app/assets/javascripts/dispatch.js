//= require jquery-ui

// app/assets/javascripts/dispatch.js
"use strict";

var dispatchController = {

  connected: function () {
    $('.disp-server-status').text("Connected").toggleClass('disp-text-alert', false);
  },

  disconnected: function () {
    $('.disp-server-status').text("Disconnected").toggleClass('disp-text-alert', true);
  },

  conversationCells: function (c) {
    var statusClass = (c.status == 'help_needed') ? 'conv-alert' : 'conv-normal';
    return '<td>' + c.from_phone + '</td>' +
      '<td class="'+statusClass+'">' + c.status + '</td>' +
      '<td>' + new Date(c.status_updated_at*1000).toTimeString() + '</td>' +
      '<td>' + c.message_count + '</td>' +
        '<td><a onclick="javascript: alert(\'modal!\')">View</a></td>'
  },

  updateConversationTable: function (c, highlight) {
    dispatchController.updateTable('#conversations', 'conv', c, dispatchController.conversationCells(c), highlight);
  },

  // Called for new conversation event
  newConversation: function (event) {
    dispatchController.updateConversationTable(event.conversation, true);
  },

  // Called when conversation changes
  conversationChanged: function (event) {
    dispatchController.updateConversationTable(event.conversation, true);
  },

  refreshConversations: function () {
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

  showAllConversations: function () {
    dispatchController.showAllRows('#conversations');
  },

  showStatusConversations: function (status) {
    dispatchController.showOnlyRows('#conversations', function(r) { return r.data('objref').status == status });
  },

  showStaleConversations: function (status) {
    dispatchController.showOnlyRows('#conversations', function(r) { return dispatchController.stale(r.data('objref')) });
  },

  rideCells: function rideCells(r) {
    return '<td>' + r.name + '</td>' +
      '<td>' + r.status + '</td>' +
      '<td>' + new Date(r.status_updated_at*1000).toTimeString() + '</td>' +
      '<td>' + r.pickup_at + '</td>'
  },

  updateRideTable: function (r, highlight) {
    dispatchController.updateTable('#rides', 'ride', r, dispatchController.rideCells(r), highlight);
  },

  // Called when a new ride is created
  newRide: function (event) {
    dispatchController.updateRideTable(event.ride, true);
    // todo: update the map
  },

  // Called when ride changes
  rideChanged: function (event) {
    dispatchController.updateRideTable(event.ride, true);
    // todo: update the map
  },

  refreshRides: function () {
    $.ajax('/api/1/ride_zones/' + dispatchController.rideZoneId + '/rides', {
      success: function(data, status, xhr) {
        for (var i = 0; i < data.response.length; ++i) {
          dispatchController.updateRideTable(data.response[i], false);
        }
      },
      error: function(xhr, status, err) { $('error_msg').text(xhr.responseText) }
    });
  },

  showAllRides: function () {
    dispatchController.showAllRows('#rides');
  },

  showStatusRides: function (status) {
    dispatchController.showOnlyRows('#rides', function(r) { return r.data('objref').status == status });
  },

  showStaleRides: function (status) {
    dispatchController.showOnlyRows('#rides', function(r) { return dispatchController.stale(r.data('objref')) });
  },

  refreshDrivers: function () {
    $.ajax('/api/1/ride_zones/' + dispatchController.rideZoneId + '/drivers', {
      success: function(data, status, xhr) {
        for (var i = 0; i < data.response.length; ++i) {
          var driver = data.response[i];
          // todo: handle driver
        }
      },
      error: function(xhr, status, err) { $('error_msg').text(xhr.responseText) }
    });
  },

  stale: function(data) {
    return 1000*data.status_updated_at < (new Date - 30*60*1000)
  },

  updateTable: function (tableSelector, type, obj, cells, highlight) {
    var rowId = type+'-row-'+obj.id;
    var existing = $('#' + rowId);
    if (existing.length > 0) {
      existing.html(cells);
      if (highlight) { existing.effect("highlight", {}, 3000); }
    } else {
      var row = '<tr id="'+rowId+'">' + cells +'</tr>';
      $(tableSelector).prepend(row);
    }
    $('#' + rowId).data('objref', obj);
  },

  showAllRows: function (sel) {
    $(sel).find('tr').show();
  },

  showOnlyRows: function (sel, filter) {
    $(sel).find('tr').each(function(i) {
      if (i == 0 || filter($(this)))
        $(this).show();
      else
        $(this).hide();
    })
  },

  // Handle new driver creation
  newDriver: function (event) {
    // todo: update map
  },

  // Handle driver update
  driverChanged: function (event) {
    // todo: update map
  },

  // Handle new message
  newMessage: function (event) {
    // do we want to do anything?
  },

  eventReceived: function (event) {
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
    dispatchController.refreshDrivers();
    createRideZoneChannel(rideZoneId, dispatchController.connected, dispatchController.disconnected, dispatchController.eventReceived);
  }
};
