// app/assets/javascripts/admin.js
"use strict";

function AdminController() {
}

AdminController.prototype = {

  changeRoles: function(rz_id) {
    $('#add-admin').change(function() {
      $.post( "/admin/ride_zones/" +  rz_id + "/add_role?role=admin&user_id=" + $(this).val() );
    });

    $('#add-dispatcher').change(function() {
      $.post( "/admin/ride_zones/" +  rz_id + "/add_role?role=dispatcher&user_id=" + $(this).val() );
    });

    $('#add-driver').change(function() {
      $.post( "/admin/ride_zones/" +  rz_id + "/add_role?role=driver&user_id=" + $(this).val() );
    });
  },

  init: function() {
    $(function() {

      $('#driver-filter').change(function() {
        window.open ("/admin/drivers?" + $(this).val() + "=true",'_self',false)
      });

    })
  }

};