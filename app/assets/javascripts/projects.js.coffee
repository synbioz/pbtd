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
      $("form.new_project").find("input[type=submit]").hide()
      $("form.new_project").find("hr").after("<div class='loader'></div>")
      project_id = $(data).find(".repo-settings").data("id")
      url = window.location.href + "projects/" + project_id + "/check_environments_preloaded"
      send_ajax_request = () ->
        $.ajax({
          url: url,
          method: 'get'
        }).success (data, status, xhr) ->
          if data.length <= 1
            timeout = setTimeout(send_ajax_request, 1000)
          else
            clearTimeout(timeout)
            $(".loader").replaceWith(data)
      send_ajax_request()
      #$('#new-project').velocity("transition.expandOut",{duration: 300});
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
    newEnv = $('.add-environment-list li:first-child').clone()
    $(newEnv).appendTo('.add-environment-list').show()


