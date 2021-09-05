using Toybox.Activity;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Math;
using Toybox.WatchUi;
using Toybox.Time;
import Toybox.Test;

function assertEqual(expected, actual) {
    Test.assertEqualMessage(expected, actual, "Expected: " + expected + ", Actual: " + actual);
}

const MINUTES_PER_MILE = 1;
const MINUTES_PER_KM = 2;

const KM = 1000;
const MILES = 1609.34;
const MINUTES = 60 * 1000;

function makeView(targetPace, units) {
    Application.Properties.setValue("targetPace", targetPace);
    Application.Properties.setValue("targetPaceUnits", units);
    var view = new PaceOffsetView();
    view.refreshTargetPace();
    return view;
}

function computeRoundedOffset(view, distanceMeters, timeMs) {
    var info = new Activity.Info();
    info.elapsedDistance = distanceMeters;
    info.timerTime = timeMs;
    var offset = view.compute(info);
    return Math.round(offset.value());
}

(:test)
function testMilesAheadOfPace(logger) {
    // Finishing a 5k at a 10:30 min/mi pace takes 32:37, so finishing after
    // 32 minutes means we're 37 seconds ahead of pace.
    var view = makeView("10:30", MINUTES_PER_MILE);
    assertEqual("10:30min/mi Offset", view.label);
    assertEqual(-37.0, computeRoundedOffset(view, 5 * KM, 32 * MINUTES));
    return true;
}

(:test)
function testMilesBehindPace(logger) {
    // Finishing a half marathon at a 9 min/mi pace takes about 1:58, so
    // finishing in 2 hours puts you about 2 minutes behind pace.
    var view = makeView("9", MINUTES_PER_MILE);
    assertEqual("9min/mi Offset", view.label);
    assertEqual(121.0, computeRoundedOffset(view, 13.11 * MILES, 120 * MINUTES));
    return true;
}

(:test)
function testKilometers(logger) {
    // Finishing a 10k at a 5:30 min/km pace takes exactly 55 minutes, so
    // finishing in 54 minutes means we're 60 seconds ahead of pace.
    var view = makeView("5:30", MINUTES_PER_KM);
    assertEqual("5:30min/km Offset", view.label);
    assertEqual(-60.0, computeRoundedOffset(view, 10 * KM, 54 * MINUTES));
    return true;
}

(:test)
function testFormatsSingleDigitSeconds(logger) {
    var view = makeView("9.0833", MINUTES_PER_MILE);
    assertEqual("9:05min/mi Offset", view.label);
    return true;
}

(:test)
function testAllowsCommaDecimalSeparator(logger) {
    var view = makeView("10,5", MINUTES_PER_MILE);
    assertEqual("10:30min/mi Offset", view.label);
    return true;
}

(:test)
function testAllowsFractionalSeconds(logger) {
    var view = makeView("10:20.75", MINUTES_PER_MILE);
    assertEqual("10:21min/mi Offset", view.label);
    return true;
}

(:test)
function testAllowsFractionalSecondsWithComma(logger) {
    var view = makeView("10:20,75", MINUTES_PER_MILE);
    assertEqual("10:21min/mi Offset", view.label);
    return true;
}


(:test)
function testStripsWhitespace(logger) {
    var view = makeView(" 10 : 30 ", MINUTES_PER_MILE);
    assertEqual("10:30min/mi Offset", view.label);
    return true;
}

(:test)
function testNumericValue(logger) {
    // Device testing suggests that it always stores settings a strings, but
    // local testing tools seem to use floats, so test floats as well. 
    var view = makeView(10.5, MINUTES_PER_MILE);
    assertEqual(view.label, "10:30min/mi Offset");
    assertEqual(23.0, computeRoundedOffset(view, 5 * KM, 33 * MINUTES));
    return true;
}

(:test)
function testShowsZeroBeforeActivityStarts(logger) { 
    var view = makeView("10.5", MINUTES_PER_MILE);
    assertEqual(0.0, computeRoundedOffset(view, null, null));
    return true;
}

(:test)
function testInvalidPaceMiles(logger) {
    // If we can't properly interpret the pace, we should fall back to a
    // 10min/mi pace.
    var view = makeView("hello", MINUTES_PER_MILE);
    assertEqual("10min/mi Offset", view.label);
    assertEqual(-30.0, computeRoundedOffset(view, 1 * MILES, 9.5 * MINUTES));
    return true;
}

(:test)
function testInvalidPaceKilometers(logger) {
    // If we can't properly interpret the pace, we should fall back to a
    // 6min/km pace.
    var view = makeView("hello", MINUTES_PER_KM);
    assertEqual("6min/km Offset", view.label);
    assertEqual(30.0, computeRoundedOffset(view, 1 * KM, 6.5 * MINUTES));
    return true;
}
