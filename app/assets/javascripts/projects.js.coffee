# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  timeout = null
  source = null
  # Function to preload locations
  send_ajax_request_preload_locations = (url_preload) ->
    $.ajax
      url: url_preload,
      method: 'get',
      success: (data, status, xhr) ->
        if data instanceof Array
          notif('error', error) for error in data
          clearTimeout(timeout)
          $("#new-project").velocity("transition.expandOut",{duration: 300})
        else if data.length <= 1
          return
        else
          clearTimeout(timeout)
          $(".loader").remove()
          $("form.new_project").find("input[type=submit]").show()
          $("#new-project").after(data);
          $("#new-project").hide()
          $('.new_project input[type="text"]').val('')
          $("#edit-project").show()
      error: (xhr, data, error) ->


  # ajax add project
  $('#new-project form').on "ajax:success", (e, data, status, xhr) ->
    if data instanceof Array
      notif('error', error) for error in data
    else
      $("ul.app-list").append(data)
      $("form.new_project").find("input[type=submit]").hide()
      $("form.new_project").find("hr").after("<div class='loader'></div>")
      project_id = $(data).find(".repo-settings").data("id")
      url = window.location.origin + "/projects/" + project_id + "/check_environments_preloaded"
      timeout = setInterval ->
        send_ajax_request_preload_locations(url)
      , 1000
      notif('success', 'You add ' + $("#project_name").val() + ' project')

  # ajax update all projects
  $('.js-update-repos').on "ajax:success", (e, data, status, xhr) ->
    list_projects_id = $(".environment-list").children(".environment").map ->
      $(this).data("id")
    .get()
    $('.environment').find('.infos .version').replaceWith("<div class='tiny-loader'></div>")

  # ajax update one project
  $('a.update-repo').on "ajax:success", (e, data, status, xhr) ->
    $(this).parent().find('.infos .version').replaceWith("<div class='tiny-loader'></div>")

  # close modal edit project
  $(document).on "ajax:success", "#edit-project form", (e, data, status, xhr) ->
    $("#edit-project").velocity("transition.expandOut",{duration: 300})
    $("#edit-project").remove()
    id = $(data).data('id')
    $("li[data-id='"+id+"']").replaceWith(data)
    $('.app-list .environment').hide().velocity("transition.swoopIn",{stagger: 100})

  # open modal edit project
  $(document).on "click", ".repo-settings", ->
    $('#edit-project').remove()
    $.ajax({
      url: $(this).data("action"),
      method: 'get'
    }).success (data, status, xhr) ->
      $("ul.app-list").before(data)
      $('#edit-project').velocity("transition.expandIn",{duration: 300})

  # close modal manager project
  $(document).on "click", "#edit-project .close", ->
    $('#edit-project').velocity("transition.expandOut",{duration: 300})

  # Modal : add an environment
  $(document).on "click", ".js-more-environment", ->
    newEnv = $('.add-environment-list li:first-child').clone()
    $(newEnv).appendTo('.add-environment-list').show()

  # Notification
  client = new Faye.Client('http://0.0.0.0:8000/faye')

  client.subscribe '/distance_notifications', (data) ->
    distance_element = null
    if data.distance == 0
      distance_element = "<div class='version updated'>Updated</div>"
    else if data.distance > 0
      distance_element = "<div class='version late'>"+data.distance+" commits from current branch</div>"
    else
      distance_element = "<div class='version error'>Error in fetching commit</div>"

    $('.environment[data-id='+data.location_id+']').find('.tiny-loader').replaceWith(distance_element)



