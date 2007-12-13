function handle_publicity_checkboxes(p_box) {
	var the_form = p_box.form;
	pq_box = document.getElementById("command_public_queries");
	pq_label = document.getElementById("command_public_queries_label");
	if (p_box.checked) {
		pq_box.disabled = false
		pq_box.checked = true				
		pq_label.removeClassName("disabled");				
		// pq_label.className = "enabled"
	} else {
		pq_box.disabled = true
		pq_box.checked = false
		pq_label.addClassName("disabled");								
		// pq_label.className = "disabled"				
	}	
}
