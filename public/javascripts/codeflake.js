$(function() {
    var tabs = $('.syntax-tab li');
    var ace  = window.ace;

    var editor = ace.edit('editor');
    var syntaxMode = $('form .syntax');
    var body = $('#flake-body');

    $('form').on('submit', function() {
        body.html(editor.getValue());
    });
    
    tabs.click(function(evt) {
        var current = $(this);
        var syntax = current.text();

        evt.preventDefault();
        evt.stopPropagation();

        tabs.removeClass('active');
        current.addClass('active');

        syntaxMode.val(syntax);
    });
});
