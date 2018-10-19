var locationSyncing = {

  attach: function( from_city_state_el, to_city_state_el) {

    $( from_city_state_el ).change(function(){
        var new_city_state = $( from_city_state_el).val();

        $( to_city_state_el ).val(new_city_state);
    });
  }

}