# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  # ajax add project
  $('#new-project form').on "ajax:success", (e, data, status, xhr) ->
    if data instanceof Array
      notif('error', error) for error in data
    else
      $("ul.app-list").append(data)
      $('#new-project').velocity("transition.expandOut",{duration: 300});
      notif('success', 'You add ' + $("#project_name").val() + ' project')

  # open modal manager project
  $(document).on "click", ".repo-settings", ->
    $('#manager-project').remove()
    $.ajax({
      url: $(this).data("action"),
      method: 'get'
    }).success (data, status, xhr) ->
      $("ul.app-list").before(data)
      $('#manager-project').velocity("transition.expandIn",{duration: 300})

  # close modal manager project
  $(document).on "click", "#manager-project .close", ->
    $('#manager-project').velocity("transition.expandOut",{duration: 300})

  # Modal : add an environment
  $(document).on "click", ".js-more-environment", ->
    newEnv = $('#manager-project .add-environment-list li:first-child').clone()
    $(newEnv).appendTo('#manager-project .add-environment-list').show()


