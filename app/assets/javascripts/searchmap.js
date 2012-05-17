$(document).ready(function() {
	var map = new L.Map('searchmap');
	var cloudmadeUrl = 'http://{s}.tile.cloudmade.com/3a36067fc4f2404eb235c892bb344b06/997/256/{z}/{x}/{y}.png',
			cloudmadeAttrib = 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2011 CloudMade',
			cloudmade = new L.TileLayer(cloudmadeUrl, {maxZoom: 18, attribution: cloudmadeAttrib});
	
	var latlng = new L.LatLng(52.6839, -1.82598); 
	map.setView(latlng, 4).addLayer(cloudmade);
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