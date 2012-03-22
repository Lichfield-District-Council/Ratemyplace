$(document).ready(function() {
	var map = new L.Map('map');
	var cloudmadeUrl = 'http://{s}.tile.cloudmade.com/3a36067fc4f2404eb235c892bb344b06/997/256/{z}/{x}/{y}.png',
			cloudmadeAttrib = 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2011 CloudMade',
			cloudmade = new L.TileLayer(cloudmadeUrl, {maxZoom: 18, attribution: cloudmadeAttrib});
		
		var latlng = new L.LatLng(lat, lng); 
	map.setView(latlng, 16).addLayer(cloudmade);
	 
	var marker = new L.Marker(latlng, {icon: new L.Icon('/assets/marker.png')});
	map.addLayer(marker);
})