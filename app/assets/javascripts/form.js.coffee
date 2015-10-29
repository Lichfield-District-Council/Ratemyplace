$(document).ready ->

 editor = WysiHat.Editor.attach($('#inspection_hours'))
 
 $('#inspection_hours_editor').html($('#inspection_hours').val())
 
 boldButton = $('.editor_toolbar .bold').first();

 boldButton.click ->
   editor.boldSelection()
   return false
  
 editor.bind 'wysihat:cursormove', ->
   if (editor.boldSelected())
     boldButton.addClass('selected')
   else
     boldButton.removeClass('selected')
     
 listButton = $('.editor_toolbar .list').first();
 
 listButton.click ->
  editor.toggleUnorderedList()
  return false
  
 $(".form-horizontal").bind 'submit', ->
    $('#inspection_hours').val($('#inspection_hours_editor').html())

 $('.removefile').bind 'click', ->
  path = window.location.pathname.split('/')
  type = this.id
  $.getJSON "/admin/deleteattachment/#{path[2]}/#{type}", (data) ->
    if data.success == "true"
      $("#inspection_#{type}_filename").addClass('hidden')
  return false

 $("#searchaddress").bind 'click', ->
 	postcode = $("#postcode").val()
 	$('#loading').removeClass('hidden')
 	$.getJSON '/address/postcode/' + postcode, (data) ->
 	  items = []
 	  items.push('<option>---Please Select---</option>')
 	  $.each data, (key, item) ->
 	  	items.push("<option value='#{item.uprn}'>#{item.address}</option>") 
 	  if items.length > 1
	 	  $('#findaddress').addClass('hidden')
	 	  $('#results').removeClass('hidden')
	 	  
	 	  $('<select/>', 
	 	  	"id": "addresses"
	 	  	html: items.join('')
	 	  	change: ->
	 	  		uprn = $(this).val()
	 	  		$.getJSON '/address/uprn/' + uprn, (data) ->
	 	  			$('#address').removeClass('hidden')
	 	  			$('#inspection_address1').val(data.address1)
	 	  			if (data.address2 != "Null")
	 	  				$('#inspection_address2').val(data.address2)
	 	  			if (data.address3 != "Null")
	 	  				$('#inspection_address3').val(data.address3)
	 	  			if (data.address4 != "Null")
	 	  				$('#inspection_address4').val(data.address4)
	 	  			$('#inspection_town').val(data.town)
	 	  			$('#inspection_postcode').val(data.postcode)
	 	  			$('#inspection_town').val(data.town)
	 	  			$('#inspection_lat').val(data.lat)
	 	  			$('#inspection_lng').val(data.lng)
	 	  			$('#inspection_uprn').val(data.uprn)
	 	  ).appendTo('#results')
 	  else
	 	  alert("No addresses found. Please try again.")
	 	  $('#loading').addClass('hidden')	
  return false
  
 $("#searchuprn").bind 'click', ->
  uprn = $("#uprn").val()
  $('#loading2').removeClass('hidden')
  $.getJSON '../address/uprn/' + uprn, (data) ->
    if data != null
	    $('#findaddress').addClass('hidden')
	    $('#address').removeClass('hidden')
	    $('#inspection_address1').val(data.address1)
	    if (data.address2 != "Null")
	      $('#inspection_address2').val(data.address2)
	    $('#inspection_town').val(data.town)
	    $('#inspection_postcode').val(data.postcode)
	    $('#inspection_town').val(data.town)
	    $('#inspection_lat').val(data.lat)
	    $('#inspection_lng').val(data.lng)
	    $('#inspection_uprn').val(data.uprn)
    else
    	alert("UPRN not found. Please try again.")
    	$('#loading2').addClass('hidden')	
  return false
  
 $('#changeaddress').bind 'click', ->
   $('#findaddress').removeClass('hidden')
   $('#address').addClass('hidden')
   return false

 $('#appeals').bind 'click', ->
 	$('#appealdate').removeClass('hidden')
 	$('#appeals').addClass('hidden')
 	$('#appeal').val('1')
 
 $('#accept').bind 'click', ->
 	$('#appeal').val('0')
 	$('#appealnote').addClass('hidden')
 	
 $("#inspection_category").bind 'change', ->
 	if $("#inspection_category").val() == "Mobile food unit"
 		$('#address').removeClass('hidden')
 		$('#findaddress').addClass('hidden')
 		$('#inspection_postcode').val('Mobile')
 		$('#postcode_group').addClass('hidden')
 
 $("#inspection_scope").bind 'change', ->
 	if $("#inspection_scope").val() == "Exempt" || $("#inspection_scope").val() == "Exempt and Private"
 		$('#scores').addClass('hidden')
 		$('#inspection_rating').val("-1")
 		$('#rating').replaceWith("<div id='rating'><div class='control-group'><label for='inspection_rating'>Rating</label><div class='controls'><strong>Exempt</strong></div></div></div>")
 		
 		
 $("#addedtags .delete").bind 'click', ->
        tag = $(this).parent().find('span').html()
        $('#tags').val($('#tags').val().replace(tag, ""))
        $(this).parent().remove()
        return false

 $("#inspection_image").bind 'change', ->
 	$('#inspection_image_filename').addClass('hidden')
        
 $("#inspection_report").bind 'change', ->
 	$('#inspection_report_filename').addClass('hidden')
 	
 $("#inspection_menu").bind 'change', ->
 	$('#inspection_menu_filename').addClass('hidden')
 
 $("#inspection_hygiene, #inspection_structure, #inspection_confidence").bind 'change', ->
 	hygiene = parseInt($('#inspection_hygiene').val())
 	structure = parseInt($('#inspection_structure').val())
 	confidence = parseInt($('#inspection_confidence').val())
 	
 	if !isNaN(hygiene) and !isNaN(structure) and !isNaN(confidence)
 		stars = parseInt(hygiene + structure + confidence)
 			
			if stars >=0 and stars <=15		
				if hygiene > 20 or structure > 20 or confidence > 20
					rating = 0
				else if hygiene > 15 or structure > 15 or confidence > 15
					rating = 1
				else if hygiene > 10 or structure > 10 or confidence > 10
					rating = 2
				else if hygiene > 5 or structure > 5 or confidence > 5
					rating = 4
				else
					rating = 5
			else if stars >=16 and stars <=20
				if hygiene > 20 or structure > 20 or confidence > 20 
					rating = 0
				else if hygiene > 15 or structure > 15 or confidence > 15 
					rating = 1
				else if hygiene > 10 or structure > 10 or confidence > 10
					rating = 2
				else
					rating = 4
			else if stars >=21 and stars <=30 
				if hygiene > 20 or structure > 20 or confidence > 20
					rating = 0
				else if hygiene > 15 or structure > 15 or confidence > 15
					rating = 1
				else if hygiene > 10 or structure > 10 or confidence > 10
					rating = 2
				else
					rating = 3
			else if  stars >=31 and stars <=40
				if hygiene > 20 or structure > 20 or confidence > 20
					rating = 0
				else if hygiene > 15 or structure > 15 or confidence > 15 
					rating = 1
				else
					rating = 2
			else if  stars >=41 and stars <=50 
				if hygiene > 20 or structure > 20 or confidence > 20 
					rating = 0
				else
					rating = 1
			else if  stars > 50
				rating = 0
				
			$('#inspection_rating').val(rating)
		
		 $('#rating').replaceWith("<div id='rating'><div class='control-group'><label for='inspection_rating'>Rating</label><div class='controls'><span><img src='/assets/rating#{rating}.png' /></span></div></div></div>")