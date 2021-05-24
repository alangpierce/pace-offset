using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;

class paceoffsetView extends WatchUi.SimpleDataField {
    var targetPaceMinutesPerMile;

    function initialize() {
        SimpleDataField.initialize();
        refreshTargetPace();
    }
    
    function refreshTargetPace() {
        targetPaceMinutesPerMile = Application.Properties.getValue("targetPaceMinutesPerMile");
        if (targetPaceMinutesPerMile == null) {
            targetPaceMinutesPerMile = 10.0;
        }
        label = "" + targetPaceMinutesPerMile.format("%g") + "min/mi Offset";
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
        
        var targetPaceMsPerM = targetPaceMinutesPerMile * 60 * 1000 / 1609.34;
        var expectedTimeMs = targetPaceMsPerM * elapsedDistanceM;
        var paceOffsetMs = currentTimeMs - expectedTimeMs;
        var paceOffsetSeconds = paceOffsetMs / 1000;
        var paceOffsetDuration = new Time.Duration(paceOffsetSeconds);
        return paceOffsetDuration;
    }
}
