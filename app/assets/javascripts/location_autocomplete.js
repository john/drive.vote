var locationAutocomplete = {

  attach: function( city_state_el, city_el, state_el, zip_el ) {
    var addressPicker = new AddressPicker({autocompleteService: {types: ['(cities)'], componentRestrictions: {country: 'US'}}});

    $( city_state_el ).typeahead({minLength: 0}, {
      displayKey: 'description',
      source: addressPicker.ttAdapter(),
      display: function(data){
        var city_state = data.description.split(',');
        return city_state[0] + ', ' + city_state[1];
      }
    });

    addressPicker.bindDefaultTypeaheadEvent($( city_state_el ));

    $(addressPicker).on('addresspicker:selected', function (event, result) {
      var city_state = result.address().split(',');
      var city = city_state[0];
      var state_zip = city_state[1].trim().split(' ');
      var state = state_zip[0].trim();
      var zip = state_zip[1].trim();

      $( city_el ).val( city );
      $( state_el ).val( state );
      $( zip_el ).val( zip );
    });
  }

}