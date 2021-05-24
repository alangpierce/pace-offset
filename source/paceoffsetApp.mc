using Toybox.Application;

class paceoffsetApp extends Application.AppBase {
    var paceOffset;

    function initialize() {
        AppBase.initialize();
        paceOffset = new paceoffsetView();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ paceOffset ];
    }
    
    function onSettingsChanged() {
        paceOffset.refreshTargetPace();
    }
}