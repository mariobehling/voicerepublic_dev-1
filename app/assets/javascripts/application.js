// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require jquery.jplayer.min
//= require select2
//
//= require date.js
//= require foundation_calendar-min.js
//
//= require advanced
//= require ckeditor/init
//
//= require player.js.erb
//
//= require_tree ./components

/* Alters-Success fade out after 8secs */
(function($){
  function hideAlerts() {
    var alerts = $('#flash_messages .alert.alert-success');
    setTimeout(function(){
      alerts.fadeOut('slow', function(){
        alerts.remove();
      });
    }, 5000);
  }

  $(function(){
    hideAlerts();
  });
})(jQuery);



$(function(){ $(document).foundation(); });
