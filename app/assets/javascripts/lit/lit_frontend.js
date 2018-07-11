//= require ./mousetrap.js
"use strict";

(function() {
  var $btn, $elem;
  var buildLocalizationForm, getLocalizationPath, getLocalizationDetails,
    replaceWithForm, submitForm, removeLitForm;

  buildLocalizationForm = function(e){
    var $this = $(this);
    var meta = $('meta[name="lit-url-base"]');
    if(meta.length > 0){
      getLocalizationPath($this, meta);
    }
    e.stopPropagation();
    return false;
  };

  getLocalizationPath = function(elem, metaElem) {
    $.getJSON(metaElem.attr('value'),
      { locale: elem.data('locale'),
        key: elem.data('key') },
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
    var $this = $(elem);
    $this.attr('contenteditable', true);
    $this.html( value );
    $this.focus();
    $this.on('blur', function(){
      submitForm($this, $this.html(), update_path);
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
        elem.html( data.html );
        elem.attr('contentEditable', false);
        console.log('saved ' + elem.data('key'));
      },
      error: function(){
        console.log('problem saving ' + elem.data('key'));
        alert('ups, ops, something went wrong');
      }
    });
  };

  removeLitForm = function(){
    $('#litForm').remove();
  };

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
    $('.lit-translations-info .lit-open-button').click(function(){
      $('.lit-translations-info').toggleClass('collapsed expanded');
    });
    $('.lit-translations-info .lit-close-button').click(function(){
      $('.lit-translations-info').toggleClass('collapsed expanded');
    });
  });

}).call(this);

