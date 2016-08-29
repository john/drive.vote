"use strict";

function DispatchMapController(map)
{
  this.map = map;
  this._rides = {}; // hash keyed by the ride unique id, value is map object's marker id
  this._drivers = {}; // hash keyed by the driver unique id, value is map object's marker id
}

// 10 minutes before pickup time to warn unassigned
DispatchMapController.unassignedWindow = 600;

// 15 minutes after pickup time to warn not picked up
DispatchMapController.notPickedUpWindow = 900;

DispatchMapController.prototype = {

  // https://github.com/john/drive.vote/blob/7ef10e17d/doc/drive_the_vote_dispatch_api.md#driver-events
  processDriver: function(obj)
  {
    var id = obj.id.toString(),
      lat = parseFloat(obj.latitude),
      lon = parseFloat(obj.longitude),
      label = obj.name,
      ride = obj.active_ride,
      available = obj.available,
      icon = Map.icons.open_driver;

    if(lat == undefined || lat == null || lon == undefined || lon == null) { return }
    if(ride != undefined && ride.status != 'complete') {
      // this driver has an active ride
      if (ride.status == 'driver_assigned') {
        icon = Map.icons.assigned_driver;
      } else {
        icon = Map.icons.driving_driver;
      }
      this.processRide(ride);
    }

    if(this._drivers[id] != undefined) {
      if (!available) {
        self.map.removeMarker(this._drivers[id]);
        delete this._drivers[id];
      } else {
        // re-use the existing marker
        this.map.updateMarker(this._drivers[id], lat, lon, icon, label);
      }
    } else if (available) {
      // make a new marker
      this._drivers[id] = this.map.addMarker(lat, lon, icon, label);
    }
  },

  clearRideMarkers: function()
  {
    var self = this;

    Object.keys(this._rides).forEach(function (key) {
      self.map.removeMarker(self._rides[key])
    });
    this._rides = {}
  },

  clearDriverMarkers: function()
  {
    var self = this;

    Object.keys(this._drivers).forEach(function (key) {
      self.map.removeMarker(self._drivers[key])
    });
    this._drivers = {};
  },

  // https://github.com/john/drive.vote/blob/7ef10e17d/doc/drive_the_vote_dispatch_api.md#ride-events
  processRide: function(obj)
  {
    var id = obj.id.toString(),
      lat = parseFloat(obj.from_latitude),
      lon = parseFloat(obj.from_longitude),
      label = obj.name,
      now = (new Date()).getTime() / 1000,
      icon = Map.icons.waiting_ride,
      hideIt = false;

    var pickupWarning, notPickedUpWarning;
    if (obj.pickup_at != undefined) {
      pickupWarning = obj.pickup_at - DispatchMapController.unassignedWindow;
      notPickedUpWarning = obj.pickup_at + DispatchMapController.notPickedUpWindow;
    }

    if (lat == undefined || lat == null || lon == undefined || lon == null) { return }
    if (obj.status == 'waiting_assignment') {
      if (pickupWarning != undefined && now > pickupWarning) {
        // this ride is overdue for a driver
        icon = Map.icons.overdue_ride;
        label = label + ' Pickup time: ' + strftime('%l:%M%P', new Date(obj.pickup_at*1000))
      }
    } else if (obj.status == 'driver_assigned') {
      // this ride has an assigned driver
      if (notPickedUpWarning != undefined && now > notPickedUpWarning) {
        // this ride is overdue to be picked up
        icon = Map.icons.overdue_ride;
        label = label + ' Pickup time: ' + strftime('%l:%M%P', new Date(obj.pickup_at*1000))
      } else {
        icon = Map.icons.assigned_ride;
      }
    } else if (obj.status == 'picked_up' || obj.status == 'complete') {
      hideIt = true;
    }

    if (this._rides[id] != undefined) {
      // re-use the existing marker
      if (hideIt)
        this.map.removeMarker(this._rides[id]);
      else
        this.map.updateMarker(this._rides[id], lat, lon, icon, label);
    } else if (!hideIt) {
      // make a new marker
      this._rides[id] = this.map.addMarker(lat, lon, icon, label);
    }
  }

};
