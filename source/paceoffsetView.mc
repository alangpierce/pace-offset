using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;

class paceoffsetView extends WatchUi.SimpleDataField {
    function initialize() {
        SimpleDataField.initialize();
        label = "" + getTargetPaceMinutesPerMile().format("%.2f") + "min/mi Pace Offset";
    }
    
    function getTargetPaceMinutesPerMile() {
        var result = Application.getApp().getProperty("targetPaceMinutesPerMile");
        if (result != null) {
            return result;
        }
        return 10.0;
    }

    function compute(info) {
        if (info.elapsedDistance == null || info.timerTime == null) {
            return "--";
        }
        
//        var targetPaceMinutesPerMile = 12.0;
        var targetPaceMinutesPerMile = getTargetPaceMinutesPerMile();
        if (targetPaceMinutesPerMile == null) {
            targetPaceMinutesPerMile = 10.0;
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
