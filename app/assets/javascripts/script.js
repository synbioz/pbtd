$(document).ready( function (){

  $('.app-list .environment').hide().velocity("transition.swoopIn",{stagger: 100})

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
