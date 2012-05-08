$(document).ready ->

 $("#searchaddress").bind 'click', ->
 	postcode = $("#postcode").val()
 	$('#loading').removeClass('hidden')
 	$.getJSON '../address/postcode/' + postcode, (data) ->
 	  items = []
 	  items.push('<option value="">---Please Select---</option>')
 	  $.each data, (key, item) ->
 	  	items.push("<option value='#{item.uprn}'>#{item.address}</option>") 
 	  if items.length > 1
	 	  $('#findaddress').addClass('hidden')
	 	  $('#results').removeClass('hidden')
	 	  
	 	  $('<select/>', 
	 	  	"id": "addresses"
	 	  	"name": "altuprn"
	 	  	html: items.join('')
	 	  	).appendTo('#results')
 	  else
	 	  alert("No addresses found. Please try again.")
	 	  $('#loading').addClass('hidden')	
  return false