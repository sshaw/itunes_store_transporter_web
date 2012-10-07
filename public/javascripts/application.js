iTMS = {};
iTMS.QUEUED = 'queued';
iTMS.RUNNING = 'running';

iTMS.fileSelected = function(id, file) { 
    var basename = '/', match = file.match(/([^/]+)\/?$/);
    if(match) basename = match[1];

    $('#'+id).html(basename).attr('data-content', file);
    $('#'+id).popover();
    $('#selected_' + id).val(file);
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

    $('#auth-fields div a').click(function(e) { 
	e.preventDefault();
	$('#usernames-and-password').toggle();
    });
});
