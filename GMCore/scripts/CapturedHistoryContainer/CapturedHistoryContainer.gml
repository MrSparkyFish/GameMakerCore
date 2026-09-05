//feather ignore all
 
/** CapturedHistoryContainer: Stores recorded active state history. 
 * @return {Struct.CapturedHistoryContainer} */
function CapturedHistoryContainer() constructor {
	
	///@ignore Map of state configurations captured during the exit state process keyed by the Id's of the history states used for the capture.
	histories = {};
	
	/** Set the recorded states for the specified history state
	 * @arg {Struct.HistoryState} _history The history to set the recording for
	 * @arg {Array<Struct.EnterableState>} _recording The list of recorded states
	 * @return {Undefined} */
	static SetHistory = function(_history, _recording) {
		histories[$ _history.GetId()] = _recording;
	}
	
	/** Empties the recorded states for the specified history.
	 * @arg {Struct.HistoryState} _history
	 * @return {Undefined} */	
	static RemoveHistory = function(_history) {
		StructTryRemoveMember(histories, _history.GetId());
	}
	
	/** Returns the history capture associated with the specified history. Returns `undefined` if no history has been set.
	 * @arg {Struct.HistoryState} _history
	 * @return {Array<Struct.EnterableState>} */
	static GetHistory = function(_history) {
		return histories[$ _history.GetId()];
	}
	
	/** Resets the specified history
	 * @return {Undefined} */
	static Clear = function() {
		StructClear(histories);
	}
	
	
}