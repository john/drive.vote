function DispatchMapController(map)
{
  this.map = map;
  this._rides = {};
  this._drivers = {};
}

// 10 minutes is pretty tight.
DispatchMapController.very_soon = 600;

DispatchMapController.prototype = {

  // https://github.com/john/drive.vote/blob/7ef10e17d/doc/drive_the_vote_dispatch_api.md#driver-events
  processDriver: function(obj)
  {
    var id = obj.id.toString(),
      lat = parseFloat(obj.latitude),
      lon = parseFloat(obj.longitude),
      label = obj.name,
      ride = obj.active_ride,
      icon = Map.icons.open_driver;

    if(lat == undefined || lat == null || lon == undefined || lon == null) { return }
    if(ride != undefined) {
      // this driver has a ride assigned
      icon = Map.icons.assigned_driver;
      this.setRide(ride);
    }

    if(this._drivers[id] != undefined) {
      // re-use the existing marker
      this.map.updateMarker(this._drivers[id], lat, lon, icon, label);

    } else {
      // make a new marker
      this._drivers[id] = this.map.addMarker(lat, lon, icon, label);
    }
  },

  // https://github.com/john/drive.vote/blob/7ef10e17d/doc/drive_the_vote_dispatch_api.md#ride-events
  processRide: function(obj)
  {
    var id = obj.id.toString(),
      lat = parseFloat(obj.from_latitude),
      lon = parseFloat(obj.from_longitude),
      label = obj.name,
      due = obj.pickup_time - DispatchMapController.very_soon,
      now = (new Date()).getTime() / 1000,
      icon = Map.icons.open_ride;

    if(lat == undefined || lat == null || lon == undefined || lon == null) { return }
    if(obj.status == 'waiting_assignment' && now > due) {
      // this ride is overdue for a driver
      icon = Map.icons.overdue_ride;

    } else if(obj.status == 'driver_assigned') {
      // this ride has an assigned driver
      icon = Map.icons.assigned_ride;
    }

    if(this._rides[id] != undefined) {
      // re-use the existing marker
      this.map.updateMarker(this._rides[id], lat, lon, icon, label);

    } else {
      // make a new marker
      this._rides[id] = this.map.addMarker(lat, lon, icon, label);
    }
  }

};
