$(document).on('ready page:load', function() {
  var message, type;
  window.notif = function(type, message, duration) {
    var notification;
    message || (message = "Pas de message");
    type || (type = "action");
    duration || (duration = 3000);
    notification = $('<div/>').html(message).addClass(type + ' notification');
    return $(notification)
      .appendTo('#notifications')
      .slideDown('100')
      .delay(duration)
      .click( function (event) {
        return $(this).remove();
      }).slideUp( function() {
        return $(this).unbind('click').remove();
      }
    );
  };
  if ($("#notifications").html().length) {
    type = $("#notifications").find('.notification').attr('class').split(' ')[0];
    message = $("#notifications").find('.notification').text();
    return notif(type, message, 2800);
  }
});
