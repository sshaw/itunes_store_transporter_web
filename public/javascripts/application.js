iTMS = {};
iTMS.QUEUED = 'queued';
iTMS.RUNNING = 'running';

iTMS.fileSelected = function(id, file) {
    var basename = '/', match = file.match(/([^/]+)\/?$/);
    if(match) basename = match[1];

    $('#'+id).html(basename).data('content', file);
    $('#'+id).popover();
    $('#selected_' + id).val(file);
};

iTMS.updateJobs = function() {
    var intId, url = window.location.href.split('?');
    url[0] += '.js';
    url = url.join('?');

    setTimeout(function() {
	$.get(url, function() {
            if($('tr.queued, tr.running').size() > 0)
		iTMS.updateJobs();
	}).fail(function(xhr, status, error) {
	    var message = 'Failed to update job statuses: ';
	    if(xhr.status == 0)
		message += 'cannot connect to server';
	    else
		message += error;

	    alert(message);
	});
    }, 5000);
};

$(document).ready(function() {
    $('#open_file_browser_for_path').fileBrowser({title: 'iTMSTransporter Location'}, function(file) {
	iTMS.fileSelected('path', file);
    });

    $('#open_file_browser_for_package').fileBrowser({title: 'Select Your Package', type: 'directory'}, function(file) {
	iTMS.fileSelected('package', file);
    });

    $('#open_file_browser_for_success').fileBrowser({title: 'Select Success Directory', type: 'directory'}, function(file) {
	iTMS.fileSelected('success', file);
    });

    $('#open_file_browser_for_failure').fileBrowser({title: 'Select Failure Directory', type: 'directory'}, function(file) {
	iTMS.fileSelected('failure', file);
    });

    $('#open_file_browser_for_execute').fileBrowser({title: 'Select Program to Execute', type: 'file'}, function(file) {
	iTMS.fileSelected('execute', file);
    });

    $('#auth-fields div a').click(function(e) {
	e.preventDefault();
	$('#usernames-and-password').toggle();
    });

    $('#clear_search_fields_link').click(function(e) {
	e.preventDefault();
	$(this).parents('form').find('select,input[type!=submit][type!=button][type!=reset]').val('');
    });

    var dateOptions = { dateFormat: 'mm/dd/yy', altFormat: 'yy-mm-dd', changeMonth: true, changeYear: true, maxDate: 0, showOtherMonths: true, selectOtherMonths: true };
    dateOptions['altField'] = '#updated_at_to';
    $('#_updated_at_to').datepicker(dateOptions);

    dateOptions['altField'] = '#updated_at_from';
    $('#_updated_at_from').datepicker(dateOptions);

    $('.js-package-filter').change(function(e) {
	$(this).parent().submit();
    });
});
