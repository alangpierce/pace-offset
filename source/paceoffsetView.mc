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
        label = "" + targetPaceMinutesPerMile.format("%.1f") + "min/mi Pace Offset";
    }

    function compute(info) {
        if (info.elapsedDistance == null || info.timerTime == null) {
            return "--";
        }
        var targetPaceMsPerM = targetPaceMinutesPerMile * 60 * 1000 / 1609.34;
        var elapsedDistanceM = info.elapsedDistance;
        var expectedTimeMs = targetPaceMsPerM * elapsedDistanceM;
        var currentTimeMs = info.timerTime.toFloat();
        var paceOffsetMs = currentTimeMs - expectedTimeMs;
        var paceOffsetSeconds = paceOffsetMs / 1000;
        var paceOffsetDuration = new Time.Duration(paceOffsetSeconds);
        return paceOffsetDuration;
    }
}
