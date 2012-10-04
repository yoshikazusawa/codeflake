$(function() {
    var tabs = $('.nav-tabs li');
    var ace  = window.ace;

    ace.edit('editor');
    var syntaxMode = $('form .syntax');
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
