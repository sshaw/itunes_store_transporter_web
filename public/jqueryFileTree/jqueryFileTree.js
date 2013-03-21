// A slightly modified version of the jQueryFileTree plugin that allows one to select files or dirctories.
//
// Version 1.01
//
// Cory S.N. LaViska
// A Beautiful Site (http://abeautifulsite.net/)
// 24 March 2008
//
// Visit http://abeautifulsite.net/notebook.php?article=58 for more information
//
(function($) {
    $.fn.fileBrowser = function(o, handler) {
        if( !o ) var o = {};
        if( o.root == undefined ) o.root = '';
        if( o.script == undefined ) o.script = '/browse';
        if( o.title == undefined ) o.title = 'Select a File';
        if( o.expandSpeed == undefined ) o.expandSpeed= 500;
        if( o.collapseSpeed == undefined ) o.collapseSpeed= 500;
        if( o.expandEasing == undefined ) o.expandEasing = null;
        if( o.collapseEasing == undefined ) o.collapseEasing = null;
        if( o.multiFolder == undefined ) o.multiFolder = true;
        if( o.loadMessage == undefined ) o.loadMessage = 'Loading...';

        var q, params = {};
        if( o.type != undefined ) params['type'] = o.type;
        if( o.name != undefined ) params['name'] = o.name;

        q = $.param(params);
        if(q) o.script += '?' + q;

        return this.each(function() {
            // on modal-close we want to remove the selectedFile's 'selected'
            var selectedFile
            ,browser = $('<div class="modal" style="display:none">')
                .append('<div class="modal-header"><a href="#" class="close" data-dismiss="modal">&times;</a><h3 class="title">' + o.title + '</h3>')
                .append('<div class="modal-body listing"><ul class="jqueryFileTree start"><li class="wait">' + o.loadMessage + '<li></ul>')
                .append('<div class="modal-footer"><a href="#" class="btn btn-primary">Select</a><a href="#" class="btn" data-dismiss="modal">Close</a>')

            $(this).click(function(e) {
                e.preventDefault();
                browser.modal('toggle');
            });
	    
            $('.btn-primary', browser).click(function(e) {
                e.preventDefault();
                if(selectedFile && handler) {
                    var file = selectedFile.attr('rel').replace(/\/$/, '');
                    handler(file);
                }

                browser.modal('toggle');
            });

            $('body').append(browser);

            var showTree = function showTree(c, t) {
                $(c).addClass('wait');
                $('.jqueryFileTree.start').remove();
                $.post(o.script, $.extend({ dir: t }, params), function(data) {
                    $(c).find('.start').html('');
                    $(c).removeClass('wait').append(data);
                    if( o.root == t ) $(c).find('UL:hidden').show(); else $(c).find('UL:hidden').slideDown({ duration: o.expandSpeed, easing: o.expandEasing });
                    bindTree(c);
                });
            };

            var bindTree = function(t) {
                $(t).find('LI A').bind('click', function() {
                    var count = ($(this).data('clickcount') || 0) + 1;

                    if(count == 1) {
                        var self = $(this), t = setTimeout(function() {
                            self.data('clickcount', 0);
                            if(selectedFile) selectedFile.removeClass('selected');
                            self.addClass('selected');
                            selectedFile = self;
                        }, 400);

                        $(this).data('clicktimer', t);
                        $(this).data('clickcount', count);
                    }
                    else {
                        clearTimeout($(this).data('clicktimer'));
                        $(this).data('clickcount', 0);

                        // Double click
                        if( $(this).parent().hasClass('directory') ) {
                            if( $(this).parent().hasClass('collapsed') ) {
                                // Expand
                                if( !o.multiFolder ) {
                                    $(this).parent().parent().find('UL').slideUp({ duration: o.collapseSpeed, easing: o.collapseEasing });
                                    $(this).parent().parent().find('LI.directory').removeClass('expanded').addClass('collapsed');
                                }
                                $(this).parent().find('UL').remove(); // cleanup
                                showTree( $(this).parent(), $(this).attr('rel') );
                                $(this).parent().removeClass('collapsed').addClass('expanded');
                            } else {
                                // Collapse
                                $(this).parent().find('UL').slideUp({ duration: o.collapseSpeed, easing: o.collapseEasing });
                                $(this).parent().removeClass('expanded').addClass('collapsed');
                            }
                        }
                    }
		    
                    return false;
                });
            };
	    
            showTree($('.listing', browser), o.root);
        });
    };
})(jQuery);