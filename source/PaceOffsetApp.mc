using Toybox.Application;

class PaceOffsetApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new PaceOffsetView() ];
    }
}