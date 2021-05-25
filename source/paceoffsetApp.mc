using Toybox.Application;

class PaceOffsetApp extends Application.AppBase {
    var paceOffset;

    function initialize() {
        AppBase.initialize();
        paceOffset = new PaceOffsetView();
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