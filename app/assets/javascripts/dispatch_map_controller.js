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
      label = obj.name + ' ' + obj.phone,
      ride = obj.active_ride,
      available = obj.available,
      icon = Map.icons.open_driver;

    if(lat == undefined || lat == null || lon == undefined || lon == null) { return }
    if(ride != undefined && ride.status != 'complete' && ride.status != 'canceled') {
      // this driver has an active ride
      if (ride.status == 'driver_assigned') {
        icon = Map.icons.assigned_driver;
      } else {
        icon = Map.icons.driving_driver;
        ride.from_latitude = lat;   // move the ride with the driver
        ride.from_longitude = lon;
        this.processRide(ride, true);
      }
    }

    if(this._drivers[id] != undefined) {
      if (!available) {
        this.map.removeMarker(this._drivers[id]);
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
  processRide: function(ride, visible)
  {
    var id = ride.id.toString(),
      lat = parseFloat(ride.from_latitude),
      lon = parseFloat(ride.from_longitude),
      label = ride.name,
      now = (new Date()).getTime() / 1000,
      icon = Map.icons.waiting_assignment;

    var pickupWarning, notPickedUpWarning;
    if (ride.pickup_at != undefined) {
      pickupWarning = ride.pickup_at - DispatchMapController.unassignedWindow;
      notPickedUpWarning = ride.pickup_at + DispatchMapController.notPickedUpWindow;
    }

    if (lat == undefined || lat == null || lon == undefined || lon == null) { return }
    if (ride.status == 'waiting_assignment' || ride.status == 'new_ride') {
      if (pickupWarning != undefined && now > pickupWarning) {
        // this ride is overdue for a driver
        icon = Map.icons.overdue_assignment;
        label = label + ' Pickup time: ' + strftime('%l:%M%P', new Date(ride.pickup_at*1000))
      }
    } else if (ride.status == 'driver_assigned' || ride.status == 'waiting_acceptance') {
      // this ride has an assigned driver
      if (notPickedUpWarning != undefined && now > notPickedUpWarning) {
        // this ride is overdue to be picked up
        icon = Map.icons.overdue_pickup;
        label = label + ' Pickup time: ' + strftime('%l:%M%P', new Date(ride.pickup_at*1000))
      } else {
        icon = Map.icons.waiting_pickup;
      }
    } else if (ride.status == 'complete' || ride.status == 'canceled') {
      visible = false;
    }

    if (this._rides[id] != undefined) {
      // re-use the existing marker
      this.map.updateMarker(this._rides[id], lat, lon, icon, label);
    } else {
      // make a new marker
      this._rides[id] = this.map.addMarker(lat, lon, icon, label);
    }
    this.visibleRide(ride, visible);
  },

  visibleRide: function(ride, visible) {
    var id = ride.id.toString();

    if (this._rides[id] != undefined) {
      this.map.visibleMarker(this._rides[id], visible);
    }
  },

  animateRideId: function(rideId) {
    var marker = this._rides[rideId];

    if (marker != undefined)
      this.map.animateMarker(marker);
  },

  unanimateRideId: function(rideId) {
    var marker = this._rides[rideId];

    if (marker != undefined)
      this.map.unanimateMarker(marker);
  }
};
