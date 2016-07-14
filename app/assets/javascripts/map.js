$(document).ready(function() {
	var map = new L.Map('map', {
		layers: MQ.mapLayer()
	});

	var latlng = new L.LatLng(lat, lng);
	map.setView(latlng, 16);

	var marker = new L.Marker(latlng, {icon: new L.Icon({iconUrl : '/assets/marker.png'})});
	map.addLayer(marker);
})
