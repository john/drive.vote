//= require jquery-ui

// app/assets/javascripts/dispatch.js
"use strict";

function DispatchController(rideZoneId, mapController) {
  this._rideZoneId = rideZoneId;
  this._mapController = mapController;
}

DispatchController.prototype = {

  connected: function () {
    $('.disp-server-status').text("Connected").toggleClass('disp-text-alert', false);
  },

  disconnected: function () {
    $('.disp-server-status').text("Disconnected").toggleClass('disp-text-alert', true);
  },

  loadConversationForm: function (id) {
    $('#conversation-form').load('/admin/conversations/' + id + '/form');
  },

  loadConversationMessages: function (id) {
    $('#conversation-messages').load('/admin/conversations/' + id + '/messages');
  },

  conversationCells: function (c) {
    var statusClass = (c.status == 'help_needed') ? 'conv-alert' : 'conv-normal';
    return '<td class="msg">' + ((c.message_count == null) ? '0' : c.message_count) + '</td>' +
      '<td class="from">' + c.from_phone + '<br>' + c.messages[0].body + '</td>' +
      '<td class="'+statusClass+'">' + c.status.replace('_', ' ') + '</td>' +
      '<td class="updated">' + strftime('%l:%M%P', new Date(c.status_updated_at*1000)) + '</td>'
  },

  updateConversationTable: function (c) {
    this.updateTable('#conversations', 'conv', c, this.conversationCells(c));
  },

  loadConversationForm: function (id) {
    $('#conversation-form').load('/admin/conversations/' + id + '/form');
  },

  loadConversationMessages: function (id) {
    $('#conversation-messages').load('/admin/conversations/' + id + '/messages');
  },

  showAllConversations: function () {
    this.showAllRows('#conversations');
    $( ".btn-conv" ).css( "background-color", "#bdc3c7" );
    $("#conv-all").css( "background-color", "#777" );
  },

  showAllConversations: function () {
     this.showAllRows('#conversations');
     $( ".btn-conv" ).css( "background-color", "#bdc3c7" );
     $("#conv-all").css( "background-color", "#777" );
   },

  showStatusConversations: function (status) {
    this.showOnlyRows('#conversations', function(r) { return r.data('objref').status == status });
    $( ".btn-conv" ).css( "background-color", "#bdc3c7" );
    if (status == 'need_help') {
      $("#conv-help").css( "background-color", "#777" );
    } else if (status == 'in_progress') {
      $("#conv-prog").css( "background-color", "#777" );
    }
  },

  showStaleConversations: function (status) {
    var self = this;
    this.showOnlyRows('#conversations', function(r) { return self.stale(r.data('objref')) });
    $( ".btn-conv" ).css( "background-color", "#bdc3c7" );
    $("#conv-stale").css( "background-color", "#777" );
  },

  rideCells: function (r) {
    return '<td>' + r.name + '</td>' +
      '<td>' + r.status + '</td>' +
      '<td>' + new Date(r.status_updated_at*1000).toTimeString() + '</td>' +
      '<td>' + r.pickup_at + '</td>'
  },

  updateRideTable: function (r) {
    this.updateTable('#rides', 'ride', r, this.rideCells(r));
  },

  showAllRides: function () {
    this.showAllRows('#rides');
    $( ".btn-ride" ).css( "background-color", "#bdc3c7" );
    $("#ride-all").css( "background-color", "#777" );
  },

  showStatusRides: function (status) {
    this.showOnlyRows('#rides', function(r) { return r.data('objref').status == status });
    $( ".btn-ride" ).css( "background-color", "#bdc3c7" );
    if (status == 'waiting_assignment') {
      $("#ride-waiting").css( "background-color", "#777" );
    } else if (status == 'driver_assigned') {
      $("#ride-assigned").css( "background-color", "#777" );
    }
  },

  showStaleRides: function (status) {
    var self = this;
    this.showOnlyRows('#rides', function(r) { return self.stale(r.data('objref')) });
    $( ".btn-ride" ).css( "background-color", "#bdc3c7" );
    $("#ride-stale").css( "background-color", "#777" );
  },

  stale: function(data) {
    return 1000*data.status_updated_at < (new Date - 30*60*1000)
  },

  updateTable: function (tableSelector, type, obj, cells) {
    var rowId = type+'-row-'+obj.id;
    var existing = $('#' + rowId);
    if (existing.length > 0) {
      existing.html(cells);
      existing.effect("highlight", {}, 1500);
    } else {
      var row = '<tr id="'+rowId+'" class="clickable" data-cid="'+obj.id+'">' + cells +'</tr>';
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

  sendReply: function(url) {
    // alert('this will send, but then it just reloads the page. it needs to insert the sent message into the DOM on this modal.');
    var args = {'message' : {'body': $('#body').val()}};
    $.ajax(url, {type: 'POST', dataType: 'json', data: args, process_data: false, content_type: 'application/json'})
      .success(function(res) {
        var bod = res['response']['message']['body'];
        var sent_at = res['response']['message']['sent_at'];
        $(".messages").append("<tr><td>" + sent_at + "</td><td>?</td><td>" + bod + "</td></tr>");
      });
  },

  // Called for new conversation event or changed
  processConversation: function (convo) {
    this.updateConversationTable(convo);
  },

  // Called when a ride is created or changed
  processRide: function (ride) {
    this.updateRideTable(ride);
    this._mapController.processRide(ride);
  },

  // Handle new driver creation or change
  processDriver: function (driver) {
    this._mapController.processDriver(driver);
  },

  // Handle new message
  processMessage: function (msg) {
    // do we want to do anything?
  },

  refreshConversations: function () {
    var self = this;
    $.ajax('/api/1/ride_zones/' + this._rideZoneId + '/conversations', {
      success: function(data, status, xhr) {
        for (var i = 0; i < data.response.length; ++i) {
          self.processConversation(data.response[i]);
        }
      },
      error: function(xhr, status, err) { $('error_msg').text(xhr.responseText) }
    });
  },

  refreshRides: function () {
    var self = this;
    $.ajax('/api/1/ride_zones/' + this._rideZoneId + '/rides', {
      success: function(data, status, xhr) {
        for (var i = 0; i < data.response.length; ++i) {
          self.processRide(data.response[i]);
        }
      },
      error: function(xhr, status, err) { $('error_msg').text(xhr.responseText) }
    });
  },

  refreshDrivers: function () {
    var self = this;
    $.ajax('/api/1/ride_zones/' + this._rideZoneId + '/drivers', {
      success: function(data, status, xhr) {
        for (var i = 0; i < data.response.length; ++i) {
          self.processDriver(data.response[i]);
        }
      },
      error: function(xhr, status, err) { $('error_msg').text(xhr.responseText) }
    });
  },

  eventReceived: function (event) {
    switch (event['event_type']) {
      case 'new_conversation':
        this.processConversation(event.conversation);
        break;
      case 'conversation_changed':
        this.processConversation(event.conversation);
        break;
      case 'new_ride':
        this.processRide(event.ride);
        break;
      case 'ride_changed':
        this.processRide(event.ride);
        break;
      case 'new_driver':
        this.processDriver(event.driver);
        break;
      case 'driver_changed':
        this.processDriver(event.driver);
        break;
      case 'new_message':
        this.processMessage(event.message);
        break;
    }
  },

  init: function() {
    this.refreshConversations();
    this.refreshRides();
    this.refreshDrivers();
    createRideZoneChannel(this._rideZoneId, this.connected.bind(this), this.disconnected.bind(this), this.eventReceived.bind(this));
  }
};
