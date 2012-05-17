$(document).ready ->
  $('#inspection_name').typeahead(
    source: (typeahead, query) ->
      $.ajax(
        url: "/inspections/search.json?name="+query
        success: (data) =>
          return_list = []
          $(data.results.inspections).each ->
          	return_list.push("<span data-url='" + this.uri + "/edit'>" + this.name + ", " + this.town + "</span>") 
		  
          typeahead.process(return_list)
      )
      
    onselect: (obj) =>
      $('#inspection_name').val('')
      window.location.href = $(obj).attr("data-url")
  )
  
  $('#tagwrapper').typeahead(
    source: (typeahead, query) ->
      $.ajax(
        url: "/tags/search.json?tag="+query
        success: (data) =>
          return_list = []
          $(data.results.tags).each ->
          	return_list.push(this.name) 
		  
          typeahead.process(return_list)
      )
      
    onselect: (obj) =>
      $('#tagwrapper').val('')
      if $('#tags').val().length == 0
      	val = obj
      else
      	val = $('#tags').val() + "," + obj
      $('#tags').val(val)
      $('#addedtags').append("<span class='label label-info'><i class='icon-tag icon-white'></i><span>#{obj}</span><button class='delete'>×</button></span>")
      $(".delete").bind 'click', ->
        tag = $(this).parent().find('span').html()
        $('#tags').val($('#tags').val().replace(tag, ""))
        $(this).parent().remove()
        return false
  )