$(document).ready ->
	$("[rel=popover]").popover()
	
	$("#dlreport").bind 'click', ->
		if $('#header').css('height') == '215px'
		  return true
		else
		  $('#report').modal('toggle')
		  return false