$(document).ready ->
  $('td.localization_row[data-editing=0]').on 'click', ->
    $this = $(this)
    unless parseInt($this.data('editing'))
      $this.data('editing', '1')
      $.get $this.data('edit')
  $('td.localization_row').on 'click', 'form button.cancel', (e)->
    $this = $(this)
    if $this[0].localName=='button'
      $this = $this.parents('td.localization_row')
    $this.data('editing', 0)
    $this.html $this.data('content')
    e.preventDefault()
    false
