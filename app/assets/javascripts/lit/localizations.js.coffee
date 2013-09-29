@edited_rows = {}
$(document).ready ->
  $('td.localization_row[data-editing=0]').on 'click', ->
    $this = $(this)
    if parseInt($this.data('editing'))==0
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
  $('tr.localization_versions_row').on 'click', '.close_versions', (e)->
    $this = $(this)
    $parent = $this.parents('tr.localization_versions_row')
    $parent.addClass('hidden')
    $parent.children('td').html('')
  $('tr.localization_key_row').on 'click', 'input.wysiwyg_switch', (e)->
    $(this).parents('form').find("textarea").jqte()
