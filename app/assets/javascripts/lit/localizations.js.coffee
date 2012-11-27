$(document).ready ->
  $('td.localization_row').on 'click', ->
    $this = $(this)
    unless parseInt($this.data('editing'))
      $.get $this.data('edit')
