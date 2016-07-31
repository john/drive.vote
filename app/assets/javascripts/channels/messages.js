// app/assets/javascripts/channels/messages.js

//= require cable
//= require_self
//= require_tree .

App.messages = App.cable.subscriptions.create('MessagesChannel', {
  
  connected: function(data) {
  },
  
  received: function(data) {
    $("#messages").removeClass('hidden')
    return $('#messages').prepend( this.renderMessage(data) );
  },

  renderMessage: function(data) {
    var row1 = "<div class='message'><table><tr><td class='field-name'>From:</td><td class='info'>" + data.from + "</td></tr>";
    var row2 = "<tr><td class='field-name'>Message:</td><td class='info'>" + data.body + "</td></tr>";
    var row3 = "<tr><td class='field-name'>Status:</td><td class='info'>" + data.status + "</td></tr>";
    var row4 = "<tr><td></td><td class='info'><a href='/admin/messages/" + data.message_id + "' class='btn btn-xs btn-primary'>View</a></td></table></div>"
    return row1 + row2 + row3 + row4;
  }
});