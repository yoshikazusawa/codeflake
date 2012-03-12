$(function() {
    var codeMirror = CodeMirror.fromTextArea($('#code')[0], {
        mode: $('.nav-tabs .active').text(),
        theme: 'default',
        lineNumbers: true,
        smartIndent: true,
        indentUnit : 4,
        lineWrapping: true,
        onChange: function() { codeMirror.save(); }
    });
    var tabs = $('.nav-tabs li');
    var syntaxMode = $('form .syntax');
    tabs.click(function(evt) {
        var current = $(this);
        var syntax = current.text();

        evt.preventDefault();
        evt.stopPropagation();

        tabs.removeClass('active');
        current.addClass('active');

        codeMirror.setOption('mode', syntax);
        syntaxMode.val(syntax);
    });
});
