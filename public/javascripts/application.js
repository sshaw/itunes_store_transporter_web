iTMS = {};
iTMS.QUEUED = 'queued';
iTMS.RUNNING = 'running';

iTMS.basename = function(file) {
    // good enough...
    var match = file.match(/([^/]+)\/?$/);
    return match[1] || '/';
};

iTMS.fileSelected = function(id, file) { 
    $('#'+id).html(iTMS.basename(file)).attr('data-content', file);
    $('#'+id).popover();
    $('#selected_' + id).val(file);
};

iTMS.jobStatus = function(id, callback) {
    $.get('/jobs/' + id + '/status', {}, callback, 'json');
};

iTMS.tailJobLog = function(id, offset, callback) {
    $.get('/jobs/' + id + '/output', {offset: offset}, callback);
};
