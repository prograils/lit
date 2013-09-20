@edited_rows = {}
$(document).ready ->
  $('td.localization_row[data-editing=0]').on 'click', ->
    $this = $(this)
    edited_rows[$this.data('id')] = $this.html()
    unless parseInt($this.data('editing'))
      $this.data('editing', '1')
      $.get $this.data('edit')
  $('td.localization_row').on 'click', 'form button.cancel', (e)->
    $this = $(this)
    if $this[0].localName=='button'
      $this = $this.parents('td.localization_row')
    $this.data('editing', 0)
    $this.html edited_rows[$this.data('id')]
    e.preventDefault()
    false
