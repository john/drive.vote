//= require jquery-ui
// app/assets/javascripts/dispatch.js
"use strict";

function DispatchController(rideZoneId, mapController, botDisabled) {
  this._rideZoneId = rideZoneId;
  this._mapController = mapController;
  this._botDisabled = botDisabled;
  this._activeConversationId = undefined;
  this.OVERDUE_ASSIGNMENT = 10*60*1000;
  this.OVERDUE_PICKUP = 15*60*1000;
  this.OVERDUE_COMPLETION = 30*60*1000;
  this._statusStrings = {
    messaging: 'Messaging', help_needed: 'Help Needed', scheduled: 'Scheduled',
    waiting_assignment: 'Waiting for Assignment', assignment_overdue: 'Assignment Overdue',
    waiting_pickup: 'Waiting for Pickup', pickup_overdue: 'Pickup Overdue',
    driving: 'Driving', completion_overdue: 'Completion Overdue', complete: 'Complete'
  };
  this._statusClasses = [];
  for (var status in this._statusStrings) {
    this._statusClasses.push('conv-status-' + status)
  }
  this._statusStyles = {}
}

DispatchController.prototype = {

  connected: function () {
    $('.disp-server-status').text("Connected").toggleClass('disp-text-alert', false);
  },

  disconnected: function () {
    $('.disp-server-status').text("Disconnected").toggleClass('disp-text-alert', true);
  },

  toggleBotDisabled: function () {
    var self = this;
    $.ajax('/api/1/ride_zones/' + this._rideZoneId, {
      method: 'PUT',
      data: { ride_zone: { bot_disabled: !self._botDisabled } },
      dataType: 'json',
      content_type: 'application/json',
      success: function(responseData, status, xhr) {
        self._botDisabled = responseData.bot_disabled;
        $('.disp-bot-disable').text(self._botDisabled ? 'Enable Bot' : 'Disable Bot');
      },
      error: function(xhr, status, err) { $('error_msg').text(xhr.responseText) }
    });
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
        $('#msg-input').text('');
        $('#msg-input').prop('disabled',false);
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
        var msg = '';
      } else {
        // this copies everything over from the conversation
        var url = '/api/1/conversations/' + id + '/rides?driver_id=' + $(el).val();
        var msg = 'A new ride was created! It should appear in the \'rides\' column, and on the map.';
      }

      $.post( url, function() {
         $('#conv-modal').modal('hide');
         $('body').removeClass('modal-open');
         $('.modal-backdrop').remove();

         humane.log(msg, { waitForMove: true });
        })
        .fail(function() {
          humane.log ('Something has gone horribly wrong.');
        });
      e.preventDefault();
    });
  },

  conversationStatus: function (c) {
    var ride = c.ride,
        desired_time = (ride !== undefined && ride !== null) ? new Date(ride.pickup_at*1000) : null,
        last_msg_time = new Date(c.last_message_time * 1000),
        now = Date.now(),
        status = c.status;
    if (ride !== undefined && ride !== null) {
      switch (ride.status) {
        case 'complete':
          return 'complete';
        case 'picked_up':
          if (now - desired_time > this.OVERDUE_COMPLETION)
            return 'completion_overdue';
          return 'driving';
        case 'driver_assigned':
          if (now - desired_time > this.OVERDUE_PICKUP)
            return 'pickup_overdue';
          return 'waiting_pickup';
        case 'waiting_assignment':
          if (now > desired_time - this.OVERDUE_ASSIGNMENT)
            return 'assignment_overdue';
          return 'waiting_assignment';
        default:
          return 'scheduled';
      }
    }
    switch(status) {
      case 'help_needed':
        return 'help_needed';
      case 'closed':
        return 'complete';
    }
    if (c.message_count == 0 || now - last_msg_time > 20*60*1000)
      return 'help_needed'
    return 'messaging';
  },

  conversationCells: function (c, status) {
    var timestamp = (c.last_message_time === undefined) ? '' : new Date(c.last_message_time*1000).toISOString();
    var pickup = (c.ride === undefined) ? '' : new Date(c.ride.pickup_at*1000).toISOString();
    var ride_icon = (c.ride !== undefined) ? '🚕' : '';
    var ride_id = (c.ride !== undefined) ? c.ride.id : 0;

    var cells = '<td class="ride-icon" data-ride-id="'+ ride_id +'">' + ride_icon + '</td>' +
      '<td class="from">' + c.from_phone + '<br>' + c.name + '</td>' +
      '<td>' +
        '<div class="sm pull-right">+' + (c.message_count-1) + ' earlier</div>' +
        '<span class="sm">' +
          '<time class="timeago" datetime="' + timestamp + '">' + timestamp + '</time>' +
        '</span>' +
        '<br>' + c.last_message_body.truncate(100) + '</td>' +
      '<td>' + this._statusStrings[status]+ '</td>';
    if (status == 'complete' || status == 'driving') {
      cells = cells + '<td></td>';
    } else {
      cells = cells + '<td><time class="timeago" datetime="' + pickup + '">' + pickup + '</time> </td>';
    }
    return cells
  },

  // Adds or replaces row in the conversation table with data from conversation
  // object c. Returns the conversation's calculated status.
  updateConversationTable: function (c) {
    var status = this.conversationStatus(c),
        rowId = 'conv-row-'+c.id,
        existing = $('#' + rowId),
        cells = this.conversationCells(c, status);

    if (existing.length > 0) {
      existing.html(cells);
      this.setRowStatus(existing, status);
    } else {
      var classes = "conv-row clickable conv-status-" + status,
          row = '<tr id="'+rowId+'" class="'+classes+'" data-cid="'+c.id+'">' + cells +'</tr>';
      $('#conversations').prepend(row);
    }
    $('#' + rowId).data('objref', c);
    $("time.timeago").timeago();
    this.recalcBadges();
    return status;
  },

  showConversationsWithStatuses: function (statusList) {
    var toShow = (statusList == '*') ? Object.keys(this._statusStrings) : statusList.split(' '),
        all = Object.keys(this._statusStrings);
    for (var i = 0; i < all.length; ++i) {
      var status = all[i],
          style = this._statusStyles[status];
      if (style !== null && style !== undefined) {
        if (toShow.indexOf(status) == -1) {
          style.visibility = 'hidden';
          style.display = 'none';
          this.visibleMapMarkersWithStatus(status, false);
        } else {
          style.visibility = 'visible';
          style.display = '';
          this.visibleMapMarkersWithStatus(status, true);
        }
      } else
        console.log("ERROR: style " + all[i] + " NOT FOUND");
    }
  },

  // Returns true if rows with 'status' are currently visible
  statusIsVisible: function(status) {
    var style = this._statusStyles[status];
    return style.visibility == 'visible';
  },

  // Sets all ride markers in the map with 'status' visible true/false
  visibleMapMarkersWithStatus: function (status, visible) {
    var self = this;
    $('.conv-row.conv-status-'+status).each(function() {
      var ride = $(this).data('objref').ride;
      if (ride !== null && ride !== undefined) {
        self._mapController.visibleRide(ride, visible);
      }
    })
  },

  animateRide: function(rideId) {
    this._mapController.animateRideId(rideId);
  },

  unanimateRide: function(rideId) {
    this._mapController.unanimateRideId(rideId);
  },

  // Counts the number of items that match the filters for each filter button
  // and updates their text to have (N) badge with count
  recalcBadges: function() {
    $('.btn-conv-filter').each(function() {
      var total = 0,
          statuses = $(this).data('statuses').split(' '),
          curr_name = $(this).text();
      if (statuses[0] == '*') {
        total = $('.conv-row').length;
      } else {
        for (var i = 0; i < statuses.length; ++i) {
          total = total + $('.conv-status-' + statuses[i]).length;
        }
      }
      if (total == 0) {
        if (curr_name.includes('(')) {
          $(this).text(curr_name.replace(/ \(.*/, ''));
        }
      } else {
        $(this).text(curr_name.replace(/ \(.*/, '') + ' (' + total + ')');
      }
    })
  },

  // Sets the conv-status-xxx status for this row object and removes all other
  // conv-status-xxx statuses from the row
  setRowStatus: function(row, rowStatus) {
    var statusClass = 'conv-status-' + rowStatus,
        classes = this._statusClasses.slice(0),
        index = classes.indexOf(statusClass);

    row.addClass(statusClass);
    classes.splice(index, 1);
    row.removeClass(classes.join(' '));
  },

  // Iterates over all conversation table rows and recomputes their status. If
  // it has changed, processes the conversation fresh.
  refreshStatuses: function() {
    var self = this;
    $('.conv-row').each(function() {
      var status = self.conversationStatus($(this).data('objref'));
      if (!$(this).hasClass('conv-status-'+status)) {
        self.processConversation($(this).data('objref'));
      }
    })
  },

  sendReply: function() {
    $('#msg-submit').text('Sending...').prop('disabled',true);
    $('#msg-input').prop('disabled',true);
    var args = {'message' : {'body': $('#msg-input').text()}};
    var url = '/api/1/conversations/' + this._activeConversationId + '/messages';

    $.ajax(url, {type: 'POST', dataType: 'json', data: args, process_data: false, content_type: 'application/json'});
  },

  // Called for new conversation event or changed
  processConversation: function (convo) {
    var status = this.updateConversationTable(convo);
    if (convo.ride != undefined) {
      this._mapController.processRide(convo.ride, this.statusIsVisible(status));
    }
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
        $('.btn-send').text('Send');
        $('.btn-send').prop('disabled',false);;
        $('#msg-input').text('');
        $('#msg-input').prop('disabled',false);
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
    var statuses = Object.keys(this._statusStrings)
    this._statusStyles = getStyleRules('.conv-status-', statuses);
    this.refreshConversations();
    this.refreshDrivers();
    createRideZoneChannel(this._rideZoneId, this.connected.bind(this), this.disconnected.bind(this), this.eventReceived.bind(this));

    $('#conv-modal').on('shown.bs.modal', function () {
      $('#msg-input').keypress(function(e){
        if(e.which == 13){
          dispatchController.sendReply(); return false;
        }
      });
      $('#msg-input').focus();
    })
  }
};
