using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;

class PaceOffsetView extends WatchUi.SimpleDataField {
    var targetPaceMsPerM;

    function initialize() {
        SimpleDataField.initialize();
        refreshTargetPace();
    }
    
    function refreshTargetPace() {
        var targetPace = Application.Properties.getValue("targetPace");
        if (targetPace != null) {
            targetPace = targetPace.toFloat();
        }
        var targetPaceUnits = Application.Properties.getValue("targetPaceUnits");
        if (targetPaceUnits != null && targetPaceUnits == 2) {
            // Minutes per kilometer
	        if (targetPace == null) {
	            targetPace = 6.0;
	        }
            targetPaceMsPerM = targetPace.toFloat() * 60.0 * 1000.0 / 1000.0;
            label = "" + targetPace.format("%g") + "min/km Offset";
        } else {
            // Minutes per mile
	        if (targetPace == null) {
	            targetPace = 10.0;
	        }
            targetPaceMsPerM = targetPace.toFloat() * 60.0 * 1000.0 / 1609.34;
            label = "" + targetPace.format("%g") + "min/mi Offset";
        }
    }

    function compute(info) {
        var elapsedDistanceM = 0.0;
        if (info.elapsedDistance != null) {
            elapsedDistanceM = info.elapsedDistance;
        }
        var currentTimeMs = 0.0;
        if (info.timerTime != null) {
            currentTimeMs = info.timerTime.toFloat();
        }
        var expectedTimeMs = targetPaceMsPerM * elapsedDistanceM;
        var paceOffsetMs = currentTimeMs - expectedTimeMs;
        var paceOffsetSeconds = paceOffsetMs / 1000;
        var paceOffsetDuration = new Time.Duration(paceOffsetSeconds);
        return paceOffsetDuration;
    }
}
