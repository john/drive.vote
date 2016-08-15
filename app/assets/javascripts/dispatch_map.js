// Wrapper for different kinds of maps. Currently supports
// OpenStreetMap via Leaflet with Stamen tiles, and Google Maps.
// To use Google, provide google_api_key in args parameter.
// Loaded map is passed to callback when ready for use.
function Map(element, callback, args)
{
    // 3rd-party map instances - exactly one of these should be defined.
    this._gmap = null;
    this._lmap = null;

    // List of map markers.
    this._markers = [];

    var view = {
        lat: (args && args.lat || 37.77073),
        lon: (args && args.lon || -122.43020),
        zoom: (args && args.zoom || 16)
        };

    if(args && args.google_api_key) {
        this._loadGoogleMap(element, view, callback, args.google_api_key);

    } else {
        this._loadLeafletMap(element, view, callback);
    }
}

// // Calculate URL prefix to reliably find icons.
// function _url_prefix()
// {
//     for(var i = 0; i < document.scripts.length; i++)
//     {
//         var parts = document.scripts[i].src.split('/');
//         if(parts.pop() == 'Map.js') { return parts.join('/') }
//     }
//
//     return '.';
// }

// Built-in icon options.
Map.icons = {
    // voter:   {w: 38, h: 57, url: _url_prefix() + '/map/icon-voter.svg'},
    // driver:  {w: 38, h: 57, url: _url_prefix() + '/map/icon-driver.svg'},
    // poll:    {w: 38, h: 57, url: _url_prefix() + '/map/icon-poll.svg'},
    voter:   {w: 38, h: 57, url: '/map/icon-voter.svg'},
    driver:  {w: 38, h: 57, url: '/map/icon-driver.svg'},
    poll:    {w: 38, h: 57, url: '/map/icon-poll.svg'},

    // Used when no other icon is provided.
    // default: {w: 38, h: 57, url: _url_prefix() + '/icon-default.svg'}
    default: {w: 38, h: 57, url: '/map/icon-default.svg'}
};

Map.prototype = {

    // Add a marker with an optional text-only popup.
    // Returns the new marker ID.
    addMarker: function(lat, lon, icon, name, href)
    {
        var marker,
            content = this._prepareMarkerContent(name, href),
            _icon = (icon || Map.icons.default);

        if(this._gmap) {
            marker = this._addGoogleMarker(lat, lon, _icon, content);

        } else if(this._lmap) {
            marker = this._addLeafletMarker(lat, lon, _icon, content);
        }

        // Return index of the marker as the ID
        return (this._markers.push(marker) - 1);
    },

    // Update an existing marker with an optional text-only popup.
    updateMarker: function(id, lat, lon, icon, name, href)
    {
        var marker = this._markers[id],
            content = this._prepareMarkerContent(name, href),
            _icon = (icon || Map.icons.default);

        if(marker && this._gmap) {
            this._updateGoogleMarker(marker, lat, lon, _icon, content);

        } else if(marker && this._lmap) {
            this._updateLeafletMarker(marker, lat, lon, _icon, content);
        }
    },

    _prepareMarkerContent(name, href)
    {
        var content;

        if(href && name) {
            content = document.createElement('a');
            content.appendChild(document.createTextNode(name));
            content.href = href;
        } else if(name) {
            content = document.createTextNode(name);
        }

        return content;
    },

    _addGoogleMarker: function(lat, lon, icon, content)
    {
        var gmap = this._gmap,
            gicon = {url: icon.url,
                    size: {width: icon.w, height: icon.h},
                    anchor: {x: icon.w/2, y: icon.h},
                    labelOrigin: {x: icon.w/2, y: 0}},
            gmarker = new google.maps.Marker({
                position: {lat: lat, lng: lon},
                icon: gicon,
                map: gmap,
                title: name
            });

        if(content) {
            var infowindow = new google.maps.InfoWindow({content: content}),
                listener = function() { infowindow.open(gmap, gmarker) };

            // Keep a reference to this so it can be updated later.
            gmarker.set('wrapper:listener', gmarker.addListener('click', listener));
        }

        return gmarker;
    },

    _addLeafletMarker: function(lat, lon, icon, content)
    {
        var licon = L.icon({iconUrl: icon.url,
                            iconSize: [icon.w, icon.h],
                            iconAnchor: [icon.w/2, icon.h],
                            popupAnchor: [0, -icon.h]}),
            lmarker = L.marker([lat, lon], {icon: licon}).addTo(this._lmap);

        if(content) {
            lmarker.bindPopup(content);
        }

        return lmarker;
    },

    _updateGoogleMarker: function(gmarker, lat, lon, icon, content)
    {
        var gmap = this._gmap,
            gicon = {url: icon.url,
                    size: {width: icon.w, height: icon.h},
                    anchor: {x: icon.w/2, y: icon.h},
                    labelOrigin: {x: icon.w/2, y: 0}};

        if(gmarker.get('wrapper:listener'))
        {
            google.maps.event.removeListener(gmarker.get('wrapper:listener'));
        }

        if(content) {
            var infowindow = new google.maps.InfoWindow({content: content}),
                listener = function() { infowindow.open(gmap, gmarker) };

            // Keep a reference to this so it can be updated later.
            gmarker.set('wrapper:listener', gmarker.addListener('click', listener));
        }

        gmarker.setIcon(gicon);
        gmarker.setPosition({lat: lat, lng: lon});

    },

    _updateLeafletMarker: function(lmarker, lat, lon, icon, content)
    {
        var licon = L.icon({iconUrl: icon.url,
                            iconSize: [icon.w, icon.h],
                            iconAnchor: [icon.w/2, icon.h],
                            popupAnchor: [0, -icon.h]});

        lmarker.setIcon(licon);
        lmarker.setLatLng([lat, lon]);
        lmarker.unbindPopup();
        lmarker.bindPopup(content);
        lmarker.update();
    },

    _loadGoogleMap: function(element, view, callback, api_key)
    {
        if(!window.google || !window.google.maps.Map)
        {
            // Include script for Google Maps, see:
            // https://developers.google.com/maps/documentation/javascript/tutorial

            var script = document.createElement('script');
            script.setAttribute('src', 'https://maps.googleapis.com/maps/api/js?key='+api_key);
            document.head.appendChild(script);
        }

        function awaitGoogleMap(map, element, view, callback)
        {
            // Wait another 50msec if Google Maps is not loaded.
            if(!window.google || !window.google.maps.Map) {
                return window.setTimeout(awaitGoogleMap, 50, map, element, view, callback);
            }

            // Set default view, and turn off scrollwheel zoom.
            var opts = {
                center: {lat: view.lat, lng: view.lon},
                zoom: view.zoom,
                scrollwheel: false,
                mapTypeControl: false,
                streetViewControl: false,
                zoomControlOptions: {position: google.maps.ControlPosition.TOP_RIGHT}
                };

            map._gmap = new google.maps.Map(element, opts);
            callback(map);
        }

        awaitGoogleMap(this, element, view, callback);
    },

    _loadLeafletMap: function(element, view, callback)
    {
        if(!window.L || !window.L.map)
        {
            // Include script and stylesheets for Leaflet, see:
            // http://leafletjs.com/examples/quick-start.html

            var script = document.createElement('script'),
                link = document.createElement('link');

            script.setAttribute('src', 'https://npmcdn.com/leaflet@1.0.0-rc.3/dist/leaflet.js');
            link.setAttribute('href', 'https://npmcdn.com/leaflet@1.0.0-rc.3/dist/leaflet.css');
            link.setAttribute('rel', 'stylesheet');

            document.head.appendChild(script);
            document.head.appendChild(link);
        }

        function awaitLeaflet(map, element, view, callback)
        {
            // Wait another 50msec if Leaflet is not loaded.
            if(!window.L || !window.L.map) {
                return window.setTimeout(awaitLeaflet, 50, map, element, view, callback);
            }

            // Set default view, and turn off scrollwheel zoom.
            var opts = {
                center: [view.lat, view.lon],
                zoom: view.zoom,
                scrollWheelZoom: false,
                zoomControl: false
                };

            map._lmap = L.map(element, opts);
            L.control.zoom({position: 'topright'}).addTo(map._lmap);

            // Add Stamen tile layer.
            L.tileLayer('http://tile.stamen.com/toner-lite/{z}/{x}/{y}@2x.png', {
                attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.',
                maxZoom: 18
            }).addTo(map._lmap);

            callback(map);
        }

        awaitLeaflet(this, element, view, callback);
    }

};
