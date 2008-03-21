
// If a command's publicity is set to private, its queries are necessarily private too
// Toggle the unchchecking, disabling, and fading of the query publicity checkbox.
function handle_publicity_checkboxes(input) {
  var form = input.form;
  var q = $('command_public_queries')
  var l = $('command_public_queries_label')
  if (input.checked) {
    $('command_public_queries').checked = true;
    q.disabled = false;
    l.removeClassName("disabled");
  } else {
    q.checked = false;
    q.disabled = true;
    l.addClassName("disabled");
  }  
}