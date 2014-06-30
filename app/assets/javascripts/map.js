$(document).ready(function() {
	var map = new L.Map('map');
	var osmUrl = 'http://otile4.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png',
			osmAttribution = 'Tiles Courtesy of <a href="http://www.mapquest.com/">MapQuest</a> &mdash; Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
			osm = new L.TileLayer(osmUrl, {maxZoom: 18, attribution: osmAttribution});

		var latlng = new L.LatLng(lat, lng);
	map.setView(latlng, 16).addLayer(osm);

	var marker = new L.Marker(latlng, {icon: new L.Icon('/assets/marker.png')});
	map.addLayer(marker);
})
