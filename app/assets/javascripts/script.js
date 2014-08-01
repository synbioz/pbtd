$(document).ready( function (){

  $('.app-list .environment').hide().velocity("transition.swoopIn",{stagger: 100})

  // Modal : add an environment
  $('.js-more-environment').click( function(){
    newEnv = $('#new-project .add-environment-list li:first-child').clone();
    $(newEnv).appendTo('#new-project .add-environment-list').show();
  });

  // Fake the Deploy and Stop for apps
  $('.environment [data-action]').click( function(){
    if ($(this).attr('data-action') === "deploy") {
      $(this)
        .attr('data-action', "stop")
        .text('running')
        .prev('.status')
        .attr('data-state', 'running');
    }
  });
});
