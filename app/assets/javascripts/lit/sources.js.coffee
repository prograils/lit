$ ->
  sourceId = $('#source_id').attr('value')

  updateFunc = ->
    $.ajax "/lit/sources/" + sourceId + "/sync_complete",
      type: 'GET'
      format: 'json'
      success: (xml, textStatus, xhr) ->
        if xhr.responseJSON.sync_complete
          $('.loading').addClass('loaded').removeClass('loading')
          clearInterval(interval)
          location.reload()
      statusCode:
        404: ->
          $('.loading').text('Could not update synchronization status, please try refreshing page')
        401: ->
          $('.loading').text('You are not authorized. Please check if you are properly logged in')
        500: ->
          $('.loading').text('Something went wrong, please try synchronizing again')
      error: ->
        clearInterval(interval)

  if $('.loading').length > 0
    interval = window.setInterval(updateFunc, 500)
