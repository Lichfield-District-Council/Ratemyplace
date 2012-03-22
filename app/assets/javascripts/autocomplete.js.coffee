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