function loadFrame(iframe) {
    var $iframe = $(iframe);
    if (1 === $iframe.length) {
        // Avoid flicker when reloading, by cloning into a new iframe instead of reloading the src
        var $iframeReloaded = $iframe.clone(true, true);
        $iframeReloaded.one('load', (function ($iframe, $iframeReloaded) {
            return function () {
                $iframeReloaded.show().attr('height', '0').attr('height', ($iframeReloaded.get(0).contentWindow.document.body.scrollHeight * 1.001) + 'px');
                $iframe.remove();
            };
        }($iframe, $iframeReloaded)));
        $iframeReloaded.hide().insertBefore($iframe);
    }
}
$(document).ready(function () {
    $('iframe').hide();
    var $tabs = $('a[data-toggle="tab"]');
    $tabs.on('click', function (event) {
        var tab = $(event.target).attr('href').replace('#', '');
        if (tab !== window.location.hash.replace('#', '')) {
            window.location.hash = tab;
        }
        loadFrame($('#' + tab).find('iframe'));
    });
    $(window).on('hashchange', function () {
        var hash = window.location.hash.replace('#', '');
        if ('' === hash) {
            $tabs.first().trigger('click');
        } else {
            $tabs.filter('[href="#' + hash + '"]').trigger('click');
        }
    }).trigger('hashchange');
});