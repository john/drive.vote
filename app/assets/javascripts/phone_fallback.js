var phoneFallback = {

  attach: function( form, phone_number ) {
    $(form).submit(function() {
      var voter_phone = $( phone_number ).val();

      $( phone_number ).val( voter_phone.length > 0 ? voter_phone : "5555555555" );
    });
  }

}
