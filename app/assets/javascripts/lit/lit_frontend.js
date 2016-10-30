var $btn, $elem;
$(document).ready(function(){
  $('<div id="lit_button_wrapper" />').appendTo('body');
  $btn = $('#lit_button_wrapper').text('Enable / disable lit highlight');
  $btn.on('click', function(){
    if($btn.hasClass('lit-highlight-enabled')){
      $('.lit-key-generic').removeClass('lit-key-highlight');
      $btn.removeClass('lit-highlight-enabled');
      $('.lit-key-generic').each(function(_, elem){
        $elem = $(elem);
        $elem.attr('title', $elem.data('old-title') || '');
      });
    }else{
      $('.lit-key-generic').addClass('lit-key-highlight');
      $btn.addClass('lit-highlight-enabled');
      $('.lit-key-generic').each(function(_, elem){
        $elem = $(elem);
        $elem.data('old-title', $elem.attr('title'));
        $elem.attr('title', $elem.data('title'));
      });
    }
  });
});
