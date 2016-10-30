var $btn, $elem;

buildLocalizationForm = function(e){
  $this = $(this)
  meta = $('meta[name="lit-url-base"]');
  if(meta.length > 0){
    getLocalizationPath($this, meta);
    //replaceWithForm(e.currentTarget, value, update_path)
  }
  e.stopPropagation();
  return false;
}

getLocalizationPath = function(elem, metaElem) {
  $.getJSON(metaElem.attr('value'),
    { locale: $this.data('locale'),
      key: $this.data('key') },
    function(data){
      getLocalizationDetails(elem, data.path);
    }
  );
};

getLocalizationDetails = function(elem, path){
  $.getJSON(path, {},
    function(data){
      replaceWithForm(elem, data.value, path);
    }
  );
};

replaceWithForm = function(elem, value, update_path){
  removeLitForm();
  $this = $(elem);
  $form = $('<form id="litForm"><textarea id="lit_textarea" /></form>').appendTo('body');
  $area = $('#lit_textarea');
  $area.offset($this.offset());
  $area.css($this.css(['background', 'font-family', 'font-style', 'font-size', 'text', 'color', 'height', 'width', 'padding', 'margin', 'font-weight', 'display']));
  $area.css('min-width', $this.css('width'));
  //$area.val( $this[0].innerHTML );
  $area.val( value );
  $area.focus();
  $area.on('blur', function(){
    $this.html( $area.val() );
    submitForm(elem, $area.val(), update_path);
    removeLitForm();
  });
};

submitForm = function(elem, val, update_path){
  $.ajax({
    type: 'PATCH',
    dataType: 'json',
    url: update_path,
    data: { 'localization[translated_value]': val },
    success: function(data){
      elem.html( data.value );
    },
    error: function(){
      alert('ups, ops, something went wrong');
    }
  });
};

removeLitForm = function(){
  $('#litForm').remove();
}
$(document).ready(function(){
  $('<div id="lit_button_wrapper" />').appendTo('body');
  $btn = $('#lit_button_wrapper').text('Enable / disable lit highlight');
  $btn.on('click', function(){
    removeLitForm();
    if($btn.hasClass('lit-highlight-enabled')){
      $('.lit-key-generic').removeClass('lit-key-highlight').off('click.form');
      $btn.removeClass('lit-highlight-enabled');
      $('.lit-key-generic').each(function(_, elem){
        $elem = $(elem);
        $elem.attr('title', $elem.data('old-title') || '');
      });
    }else{
      $('.lit-key-generic').addClass('lit-key-highlight').on('click.form', buildLocalizationForm);
      $btn.addClass('lit-highlight-enabled');
      $('.lit-key-generic').each(function(_, elem){
        $elem = $(elem);
        $elem.data('old-title', $elem.attr('title'));
        $elem.attr('title', $elem.data('key'));
      });
    }
  });
  $('#lit_button_wrapper').click();
});
