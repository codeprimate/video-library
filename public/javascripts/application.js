function show_progress() {
	$('search_button').disabled = true;
	$('loading_gif').show();
}

function hide_progress() {
	$('search_button').disabled = false;
	$('loading_gif').hide();
	$('search_text').focus();
}

