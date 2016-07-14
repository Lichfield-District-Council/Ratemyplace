$(document).ready(function() {
	var map = new L.Map('searchmap', {
		layers: MQ.mapLayer()
	});

	var latlng = new L.LatLng(52.6839, -1.82598);
	map.setView(latlng, 4);
	var mapBounds = new L.LatLngBounds();

	for (i in points) {
		var latlng = new L.LatLng(points[i]['lat'], points[i]['lng']);
		var marker = new L.Marker(latlng, {icon: new L.Icon({ iconUrl: '/assets/'+ i +'.png'})});
		marker.bindPopup("<h4><a href="+ points[i]['url'] +">"+ points[i]['name'] +"</a></h4><img src='/assets/rating"+points[i]['rating']+".png' /><br />"+ points[i]['rating'] +" stars");
		map.addLayer(marker);
		mapBounds.extend(latlng);
	}

	map.fitBounds(mapBounds);
})
