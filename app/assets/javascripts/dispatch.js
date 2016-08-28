//= require jquery-ui

// app/assets/javascripts/dispatch.js
"use strict";

function DispatchController(rideZoneId, mapController) {
  this._rideZoneId = rideZoneId;
  this._mapController = mapController;
  this._activeConversationId = undefined;
}

DispatchController.prototype = {

  connected: function () {
    $('.disp-server-status').text("Connected").toggleClass('disp-text-alert', false);
  },

  disconnected: function () {
    $('.disp-server-status').text("Disconnected").toggleClass('disp-text-alert', true);
  },

  loadRidePane: function (id, action) {
    var sameConvo = (id === this._activeConversationId);
    this._activeConversationId = id;
    if (action === undefined) {
      action = 'create';
    }
    var url = '/admin/conversations/' + id + '/ride_pane';
    if(action=='edit') {
      url += '?edit=true';
    }
    $('#conversation-form').load( url, function( response, status, xhr ) {
      if (!sameConvo) {
        $('#body').val('');
      }
    });
  },

  loadConversationMessages: function (id) {
    $('#conversation-messages').load('/admin/conversations/' + id + '/messages', function( response, status, xhr ) {
      var cont = $('.messages');
      cont[0].scrollTop = cont[0].scrollHeight;
    });
  },

  attachRideClick: function (id, el, action) {
    if (action === undefined) {
      action = 'create';
    }
    $( "#create_or_edit_ride" ).click( function(e) {

      if((action=='edit') && (el == '#driver_select')) {
        // just change the driver, on the ride object
        var url = '/api/1/rides/' + id + '/update_attribute?name=driver_id&value=' + $(el).val();
        var msg = ''
      } else {
        // this copies everything over from the conversation
        var url = '/api/1/conversations/' + id + '/rides?driver_id=' + $(el).val();
        var msg = 'A new ride was created! It should appear in the \'rides\' column, and on the map.'
      }

      $.post( url, function() {
         $('#conv-modal').modal('hide');
         $('body').removeClass('modal-open');
         $('.modal-backdrop').remove();

         humane.log(msg, { waitForMove: true });
        })
        .fail(function() {
          humane.log ('Something has gone horribly wrong.')
        });
      e.preventDefault();
    });
  },

  conversationCells: function (c) {
    var statusClass = (c.status == 'help_needed') ? 'conv-alert' : 'conv-normal';
    var timestamp = new Date(c.last_message_time*1000).toISOString();
    var ride_icon = (c.status == 'ride_created') ? '🚕' : '';

    return '<td>' + ride_icon + '</td>' +
      '<td class="from">' + c.from_phone + '<br>' + c.name + '</td>' +
      '<td>' +
        '<div class="sm pull-right">+' + (c.message_count-1) + ' earlier</div>' +
        '<span class="sm">' +
          '<time class="timeago" datetime="' + timestamp + '">' + timestamp + '</time>' +
        '</span>' +
        '<br>' + c.last_message_body + '</td>' +
      '<td class="'+statusClass+'">' + c.status.replace('_', ' ') + '</td>' +
      '<td class="updated"></td>'
  },

  updateConversationTable: function (c) {
    this.updateTable('#conversations', 'conv', c, this.conversationCells(c));
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
      '<td>' + strftime('%l:%M%P', new Date(r.status_updated_at*1000)) + '</td>' +
      '<td>' + strftime('%l:%M%P', new Date(r.pickup_at*1000)) + '</td>'
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
      //existing.effect("highlight", {}, 100);
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

  sendReply: function() {
    var args = {'message' : {'body': $('#body').val()}};
    var url = '/api/1/conversations/' + this._activeConversationId + '/messages';

    $.ajax(url, {type: 'POST', dataType: 'json', data: args, process_data: false, content_type: 'application/json'});
    $('#body').val('')
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
    if (msg.conversation_id == this._activeConversationId) {
      this.loadConversationMessages(this._activeConversationId);
    }
  },

  refreshConversations: function () {
    var self = this;
    $("#conversations > tbody").html("");
    $.ajax('/api/1/ride_zones/' + this._rideZoneId + '/conversations', {
      success: function(data, status, xhr) {
        for (var i = 0; i < data.response.length; ++i) {
          self.processConversation(data.response[i]);
        }
      $("time.timeago").timeago()
      },
      error: function(xhr, status, err) { $('error_msg').text(xhr.responseText) }
    });
  },

  refreshRides: function () {
    var self = this;
    this._mapController.clearRideMarkers();
    $("#rides > tbody").html("");
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
    this._mapController.clearDriverMarkers();
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
