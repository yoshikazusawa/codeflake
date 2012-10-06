$(function() {
    var tabs = $('.syntax-tab li');
    var ace  = window.ace;

    var editor = ace.edit('editor');
    var syntaxMode = $('form .syntax');
    var body = $('#flake-body');

    $('form').on('submit', function() {
        body.html(editor.getValue());
    });
    
    editor.getSession().setMode('ace/mode/' + syntaxMode.val());
    editor.setTheme('ace/theme/textmate');
    editor.setShowPrintMargin(false);

    tabs.click(function(evt) {
        var current = $(this);
        var syntax = current.text();

        evt.preventDefault();
        evt.stopPropagation();

        tabs.removeClass('active');
        current.addClass('active');
        editor.getSession().setMode('ace/mode/' + syntax);

        syntaxMode.val(syntax);
    });
});
