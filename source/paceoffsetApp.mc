using Toybox.Application;

class paceoffsetApp extends Application.AppBase {
    var paceOffset;

    function initialize() {
        AppBase.initialize();
        paceOffset = new paceoffsetView();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
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