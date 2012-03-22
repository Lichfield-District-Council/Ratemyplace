$(document).ready ->
	if (geo_position_js.init())
		geo_position_js.getCurrentPosition (pos) ->
			$('#lat').val(pos.coords.latitude)
			$('#lng').val(pos.coords.longitude)
			$('#geo').removeClass('hidden')