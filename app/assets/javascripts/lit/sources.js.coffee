$ ->
  sourceId = $('#source_id').attr('value')
  apiKey = $('#api_key').attr('value')

  updateFunc = ->
    $.ajax "/lit/api/v1/sources/" + sourceId + "/sync_complete",
      type: 'GET'
      headers:
        'Authorization': "Token token=\"#{apiKey}\""
      success: (xml, textStatus, xhr) ->
        if xhr.responseJSON.sync_complete
          $('.loading').addClass('loaded').removeClass('loading')
          clearInterval(interval)
          location.reload()
      statusCode:
        404: ->
          $('.loading').text('Could not update synchronization status, please try refreshing page')
        401: ->
          $('.loading').text('Invalid API key, please check source settings')
        500: ->
          $('.loading').text('Something went wrong, please try synchronizing again')
      error: ->
        clearInterval(interval)

  if $('.loading').length > 0
    interval = window.setInterval(updateFunc, 500)
