var locationAutocomplete = {

  attach: function() {
    var addressPicker = new AddressPicker({autocompleteService: {types: ['(cities)'], componentRestrictions: {country: 'US'}}});

    $('#user_city_state').typeahead({minLength: 0}, {
      displayKey: 'description',
      source: addressPicker.ttAdapter(),
      display: function(data){
        var city_state = data.description.split(',');
        return city_state[0] + ', ' + city_state[1];
      }
    });

    addressPicker.bindDefaultTypeaheadEvent($('#user_city_state'));
    $(addressPicker).on('addresspicker:selected', function (event, result) {
      //alert('result.address(): ' + result.address());
      var city_state = result.address().split(',');
      $('#user_city').val( city_state[0] );
      $('#user_state').val( city_state[1] );
    });
  }

}