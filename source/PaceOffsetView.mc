using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;

class PaceOffsetView extends WatchUi.SimpleDataField {
    var targetPaceMsPerM;

    function initialize() {
        SimpleDataField.initialize();
        refreshTargetPace();
    }
    
    /**
     * Parse the given target pace from the app settings. It may be a string,
     * a float, or null, and this function always returns a float representing
     * a (possibly-fractional) number of minutes.
     *
     * Returns null if we failed to parse, in which case we fall back to a
     * default pace.
     *
     * Examples:
     * "10" -> 10.0
     * "10:30" -> 10.5
     * "10.5" -> 10.5
     * "10,5" -> 10.5
     * "10:20.5" -> 10.34167
     * 10.5 -> 10.5
     * null -> null
     */
    function parseTargetPace(targetPaceInput) {
        if (targetPaceInput == null) {
            return null;
        }
        if (!(targetPaceInput instanceof String)) {
            return targetPaceInput.toFloat();
        }
        var colonIndex = targetPaceInput.find(":");
        if (colonIndex == null) {
            return parseNumber(targetPaceInput);
        } else {
            var minutesInput = targetPaceInput.substring(0, colonIndex);
            var secondsInput = targetPaceInput.substring(colonIndex + 1, targetPaceInput.length());
            return parseNumber(minutesInput) + parseNumber(secondsInput) / 60.0;
        }
    }
    
    /**
     * Parse a decimal number to a float in an i18n-friendly way.
     *
     * The built-in toFloat function doesn't seem to handle comma decimal
     * separators, so we want to work around that fact.
     *
     * One approach could be to implement our own number parser, but that
     * seems a bit challenging especially accounting for whitespace trimming,
     * etc.
     *
     * Another approach is to canonicalize from comma to dot, then call toFloat
     * on that. This probably would work, but could break in the future if the
     * SDK is updated to be i18n-aware.
     *
     * Instead, we convert to both forms, comma and dot, and run toFloat on
     * both. Because this is a running pace, we expect the number to be
     * positive, so we can take the max of the two parsed values to get the
     * value that properly accounted for the decimal place.
     */
    function parseNumber(numberStr) {
        var commaIndex = numberStr.find(",");
        var dotIndex = numberStr.find(".");
        var decimalSeparatorIndex = dotIndex != null ? dotIndex : commaIndex;
        
        if (decimalSeparatorIndex == null) {
            return numberStr.toFloat();
        } else {
            var beforeDecimalStr = numberStr.substring(0, decimalSeparatorIndex);
            var afterDecimalStr = numberStr.substring(decimalSeparatorIndex + 1, numberStr.length());
            
            var dotNumber = beforeDecimalStr + "." + afterDecimalStr;
            var commaNumber = beforeDecimalStr + "," + afterDecimalStr;
            
            var dotFloat = dotNumber.toFloat();
            var commaFloat = dotNumber.toFloat();
            if (dotFloat == null) {
                return commaFloat;
            }
            if (commaFloat == null) {
                return dotFloat;
            }
            return dotFloat > commaFloat ? dotFloat : commaFloat;
        }
    }
    
    /**
     * Show a user-friendly string for the given pace in minutes.
     *
     * We round to the nearest second (even though the underlying calculations
     * are more precise) and display a plain integer if possible, and if not, we
     * show mm:ss format.
     */
    function formatTargetPace(targetPace) {
        var targetPaceSeconds = Math.round(targetPace * 60).toNumber();
        var minutesComponent = targetPaceSeconds / 60;
        var secondsComponent = targetPaceSeconds % 60;
        if (secondsComponent == 0) {
            return minutesComponent.format("%d");
        } else {
            return minutesComponent.format("%d") + ":" + secondsComponent.format("%02d");
        }
    }
    
    /**
     * Read the target pace setting value and calculate the internal setting
     * and label.
     *
     * This is called explicitly at initialization time and whenever there is
     * a change to the data field settings. On settings change, we still
     * overwrite the "label" field, but the current SimpleDataField
     * implementation does not pick up the updated label.
     */
    function refreshTargetPace() {
        var targetPaceInput = Application.Properties.getValue("targetPace");
        var targetPace = parseTargetPace(targetPaceInput);
        var targetPaceUnits = Application.Properties.getValue("targetPaceUnits");
        if (targetPaceUnits != null && targetPaceUnits == 2) {
            // Minutes per kilometer
	        if (targetPace == null) {
	            targetPace = 6.0;
	        }
            targetPaceMsPerM = targetPace * 60.0 * 1000.0 / 1000.0;
            label = formatTargetPace(targetPace) + "min/km Offset";
        } else {
            // Minutes per mile
	        if (targetPace == null) {
	            targetPace = 10.0;
	        }
            targetPaceMsPerM = targetPace * 60.0 * 1000.0 / 1609.34;
            label = formatTargetPace(targetPace) + "min/mi Offset";
        }
    }

    /**
     * Calculate the pace offset to show on the screen.
     *
     * This is automatically called from the framework.
     */
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
