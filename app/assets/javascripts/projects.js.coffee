# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  timeout = null
  source = null
  # Function to preload locations
  send_ajax_request_preload_locations = (url_preload, data_project) ->
    $.ajax
      url: url_preload,
      method: 'get',
      success: (data, status, xhr) ->
        if data instanceof Object
          notif('error', error) for error in data.errors
          clearTimeout(timeout)
          $("form.new_project").find("input[type=submit]").show()
          show_select_branch(data.branches) if data.branches
          $("form.new_project").find(".loader").remove()
        else if data.length > 1
          clearTimeout(timeout)
          $("ul.app-list").append(data_project)
          $(".loader").remove()
          $("form.new_project").find("input[type=submit]").show()
          $("#new-project").after(data);
          $("#new-project").hide()
          $('.new_project input[type="text"]').val('')
          $("#edit-project").show()
      error: (xhr, data, error) ->

  # Show html select for git branch choice when fetch fail for default branch
  show_select_branch = (branches) ->
    select_element = "<select name='project[default_branch]'>"
    select_element += "<option value=" + branch + ">" + branch + "</option>" for branch in branches
    select_element += "</select>"
    $("form.new_project").find("input[type=submit]").before(select_element)


  # ajax add project
  $(document).on "ajax:success", '#new-project form', (e, data, status, xhr) ->
    if data instanceof Array
      notif('error', error) for error in data
    else
      $("form.new_project").find("input[type=submit]").hide()
      $("form.new_project").find("select").remove()
      $("form.new_project").find("hr").after("<div class='loader'></div>")
      project_id = $(data).find(".repo-settings").data("id")
      url = window.location.origin + "/projects/" + project_id + "/check_environments_preloaded"
      timeout = setInterval ->
        send_ajax_request_preload_locations(url, data)
      , 1000

  # ajax load environments
  $(document).on "click", 'a.button.js-more-environment', ->
    $('ul.add-environment-list').replaceWith("<div class='loader'></div>")

  $(document).on "ajax:success", 'a.button.js-more-environment', (e, data, status, xhr) ->
    e.stopPropagation()
    if data instanceof Array
      notif('error', error) for error in data
    else if data.length <= 1
      $.ajax
        url: (window.location.origin + $('a.js-more-environment').attr('href')),
        method: 'get'
    else
      $('#edit-project').replaceWith(data)
      $('#edit-project').show()

  # ajax update all projects
  $(document).on "ajax:success", '.js-update-repos', (e, data, status, xhr) ->
    list_projects_id = $(".environment-list").children(".environment").map ->
      $(this).data("id")
    .get()
    $('.environment').find('.infos .version').replaceWith("<div class='tiny-loader'></div>")

  # ajax update one project
  $(document).on "ajax:success", 'a.update-repo', (e, data, status, xhr) ->
    $(this).parent().find('.infos .version').replaceWith("<div class='tiny-loader'></div>")

  # ajax deploy location
  $(document).on "ajax:success", "a.deploy-location", (e, data, status, xhr) ->
    unless $(this).hasClass("disabled")
      $("#console:hidden").slideToggle(100)
      $("#console").append("<div class='content loader'></div>")
      if $(this).attr('data-action') == "deploy"
        $(this)
          .attr('data-action', "stop")
          .text('running')
          .prev('.status')
          .attr('data-state', 'running');


  # close modal edit project
  $(document).on "ajax:success", "#edit-project form", (e, data, status, xhr) ->
    $("#edit-project").velocity("transition.expandOut",{duration: 300})
    $("#edit-project").remove()
    id = $(data).data('id')
    $("li[data-id='"+id+"']").replaceWith(data)
    $('.app-list .environment').hide().velocity("transition.swoopIn",{stagger: 100})

  # open modal new project
  $(document).on "ajax:success", "a.js-create-project", (e, data, status, xhr) ->
    $("ul.app-list").before(data)
    $('#new-project').velocity("transition.expandIn",{duration: 300})

  # destroy existing location
  $(document).on "ajax:success", "a.destroy-location", (e, data, status, xhr) ->
    e.stopPropagation()
    $(this).parents('li').remove()

  # close modal edit project
  $(document).on "click", '#new-project .close', ->
    $('#new-project').velocity("transition.expandOut",{duration: 300})

  # open modal edit project
  $(document).on "click", ".repo-settings", ->
    $('#edit-project').remove()
    $.ajax({
      url: $(this).data("action"),
      method: 'get'
    }).success (data, status, xhr) ->
      $("ul.app-list").before(data)
      $('#edit-project').velocity("transition.expandIn",{duration: 300})

  # open modal deployments
  $(document).on "ajax:success", ".show-deployments", (e, data, status, xhr) ->
    $("ul.app-list").before(data)
    $('#deployments').velocity("transition.expandIn",{duration: 300})

  # close modal deployments
  $(document).on "click", '#deployments .close', ->
    $('#deployments').remove()
    $('#deployments').velocity("transition.expandOut",{duration: 300})

  # close modal manager project
  $(document).on "click", "#edit-project .close", ->
    $('#edit-project').velocity("transition.expandOut",{duration: 300})

  # Modal : add an environment
  $(document).on "click", ".js-more-environment", ->
    newEnv = $('.add-environment-list li:first-child').clone()
    $(newEnv).appendTo('.add-environment-list').show()

  # Notification
  client = new Faye.Client('http://' + window.location.hostname + ':9292/faye')

  # Notification for deployment
  client.subscribe '/deploy_notifications', (data) ->

    if data.state == 'running'
      $('.environment[data-id='+data.location_id+']').find("[data-action='deploy']")
        .attr('data-action', "stop")
        .text('running')
        .prev('.status')
        .attr('data-state', 'running');

      content = $("#console").find('.content')
      $(content).removeClass('loader')
      $(content).addClass('terminal')
      $(content).append(data.message + "<br>")
      scrollHeight = $(".terminal")[0].scrollHeight
      $(".terminal").scrollTop(scrollHeight)
      unless $(".tiny-loader").length > 0
        $(".terminal").after("<div class='waiting'><div class='tiny-loader'></div></div>")
    else if data.state == 'failed'
      notif('error', 'The project has not been deployed')
      $('.environment[data-id='+data.location_id+']').find("[data-action='stop']")
        .attr('data-action', "deploy")
        .text('deploy')
        .prev('.status')
        .attr('data-state', 'error')
      $("#console").find('.tiny-loader').remove()
    else if data.state == 'success'
      notif('success', 'The project has been successfully deployed')
      $('.environment[data-id='+data.location_id+']').find("[data-action='stop']")
        .attr('data-action', "deploy")
        .text('deploy')
        .prev('.status')
        .attr('data-state', 'updated')
      $("#console").find('.tiny-loader').remove()

  # Notification for distance between HEAD of branch and deployed commit
  client.subscribe '/distance_notifications', (data) ->
    distance_element = null
    state = null

    environment = $('.environment[data-id='+data.location_id+']')
    deploy_button = $(environment).find('.button.deploy-location')

    $(deploy_button).removeClass('disabled')

    if data.distance == 0
      distance_element = "<div class='version updated'>Updated</div>"
      state = "updated"
    else if data.distance > 0
      distance_element = "<div class='version late'>" + data.distance + " commits from current branch</div>"
      state = "behind"
    else
      $(deploy_button).addClass('disabled')
      distance_element = "<div class='version error'>" + data.message + "</div>"
      state = "error"

    $(environment).find('.status').attr('data-state', state)

    if $(environment).find('.tiny-loader').length
      $(environment).find('.tiny-loader').replaceWith(distance_element)
    else
      $(environment).find('.version').replaceWith(distance_element)


  # Console close
  $(document).on "click", '.console-toggle', ->
    $("#console").slideToggle(100)
    $("#console").find(".content").remove()

  # Add effect to show environment
  $('.app-list .environment').hide().velocity("transition.swoopIn",{stagger: 100})




