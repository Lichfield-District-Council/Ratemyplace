$(document).ready(function() {
	var map = new L.Map('searchmap');
	var osmUrl = 'http://otile4.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png',
			osmAttribution = 'Tiles Courtesy of <a href="http://www.mapquest.com/">MapQuest</a> &mdash; Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
			osm = new L.TileLayer(osmUrl, {maxZoom: 18, attribution: osmAttribution});

	var latlng = new L.LatLng(52.6839, -1.82598);
	map.setView(latlng, 4).addLayer(osm);
	var mapBounds = new L.LatLngBounds();

	for (i in points) {
		var latlng = new L.LatLng(points[i]['lat'], points[i]['lng']);
		var marker = new L.Marker(latlng, {icon: new L.Icon('/assets/'+ i +'.png')});
		marker.bindPopup("<h4><a href="+ points[i]['url'] +">"+ points[i]['name'] +"</a></h4><img src='/assets/rating"+points[i]['rating']+".png' /><br />"+ points[i]['rating'] +" stars");
		map.addLayer(marker);
		mapBounds.extend(latlng);
	}

	map.fitBounds(mapBounds);
})
