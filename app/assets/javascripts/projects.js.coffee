# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $("a.repo-settings[data-remote]").on "ajax:success", (e, data, status, xhr) ->
    $("ul.app-list").before(data)
    $('#new-project').velocity("transition.expandIn",{duration: 300})

  $('#new-project .close').click ->
    $('#new-project').velocity("transition.expandOut",{duration: 300})

  $('#new-project form').on "ajax:success", (e, data, status, xhr) ->
    if data instanceof Array
      notif('error', error) for error in data
    else
      $("ul.app-list").append(data)
      $('#new-project').velocity("transition.expandOut",{duration: 300});
      notif('success', 'You add ' + $("#project_name").val() + ' project')
