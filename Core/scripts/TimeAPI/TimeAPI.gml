//feather ignore all

/** Converts a number of seconds to a number of frames
 * @arg {Real} _seconds
 * @return {Real} */
function Time_ConvertSecondsToFPS(_seconds) {
	return _seconds/GAMESPEED_FPS;
}

/** Convert a number of frames to a number of seconds
 * @arg {Real} _frames
 * @return {Undefined} */
function Time_ConvertFPSToSeconds(_frames) {
	return GAMESPEED_FPS * _frames;
}

/** Returns the specified `TimeSource` object. If a timesource doesn't exist, one is created and returned.
 * @arg {String} [_timesourceId] The id of the timesource to return
 * @return {Struct.TimeSource} */
function Time_GetTimesource(_timesourceId) {
	///@ignore
	static timesources = {};
	timesources[$ _timesourceId] ??= new TimeSource();
	return timesources[$ _timesourceId];
}

/** Ticks the specified `IClock` object. Useful for passing into functions like `array_foreach`
 * @arg {Struct.IClock} clock The clock object to tick
 * @return {Undefined} */
function Time_TickClock(clock) {
	clock.Tick();
}