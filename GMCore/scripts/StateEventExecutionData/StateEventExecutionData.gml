//feather ignore all

/** StateEventExecutionData: Encapsulates the data that `IStateEventHandler` can use for event handling and represents a single logical unit of progression in the handling process.
 * @arg {Struct.Event} [_triggeringEvent] The event that triggered the execution.
 * @return {Struct.StateEventExecutionData} */
function StateEventExecutionData(_triggeringEvent = undefined) constructor {
	
	///@ignore The event that triggered the transition
	triggeringEvent = _triggeringEvent;
	
	///@ignore Unique list of all states that were exited by the transition.
	exitSet = [];
	
	///@ignore Unique list of all states that were entered by the transition.
	enterSet = [];
	
	///@ignore List of states that are required to be entered
	defaultEntrySet = [];
	
	///@ignore List of history transitions that are required to be taken
	defaultHistoryTransitions = {};
	
	///@ignore Map of newly recorded histories as a result of exiting states. Used to update the context's history map
	newHistories = new CapturedHistoryContainer();
	
	///@ignore List of all the transitions that are going to be taken during the execution process
	transitionList = [];
	
	
	/** Returns the complete list of states that were entered during the execution
	 * @return {Array<Struct.EnterableState>} */
	static GetEnterSet = function() {
		return enterSet;
	}
	
	/** Add an `EnterableState` to the set of states that need to be entered during execution
	 * @arg {Struct.EnterableState} _state The state to add
	 * @return {Undefined} */
	static AddStateToEnter = function(_state) {
		ArrayPushUnique(enterSet, _state);
	}
	
	/** Returns the complete list of states that were entered during the execution by default
	 * @return {Array<Struct.EnterableState>} */
	static GetDefaultEnterSet = function() {
		return defaultEntrySet;
	}
	
	/** Add an `EnterableState` to the set of default states that need to be entered during execution
	 * @arg {Struct.EnterableState} _state The state to add
	 * @return {Undefined} */
	static AddDefaultStateToEnter = function(_state) {
		ArrayPushUnique(defaultEntrySet, _state);
	}	
	
	/** Returns the history transition previously marked by `AddDefaultHistoryTransition()` for the specified `TransitionalState`. Returns `undefined` if the 
	 * state has no marked history transition.
	 * @arg {Struct.TransitionalState} _state The state to get the marked default transition for
	 * @return {Struct.SimpleTransition} */
	static GetDefaultHistoryTransitions = function(_state) {
		return defaultHistoryTransitions[$ _state.GetId()];
	}
	
	/** Indicate that the default transition for the specified `HistoryState` needs to be taken during the execution process.
	 * @arg {Struct.HistoryState} _history The history with the default transition that needs to be taken
	 * @return {Undefined} */
	static AddDefaultHistoryTransition = function(_history) {
		defaultHistoryTransitions[$ _history.GetParent().GetId()] = _history.GetTransition();
	}	
	
	/** Returns the container where newly recorded histories are stored.
	 * @return {Struct.CapturedHistoryContainer} */
	static GetHistoryCaptures = function() {
		return newHistories;
	}
	
	/** Returns the complete list of states that were exited during the execution.
	 * @return {Array<Struct.EnterableState>} */
	static GetExitSet = function() {
		return exitSet;
	}
	
	/** Add an `EnterableState` to the set of states that need to be exited during execution
	 * @arg {Struct.EnterableState} _state The state to add
	 * @return {Undefined} */
	static AddStateToExit = function(_state) {
		ArrayPushUnique(exitSet, _state);
	}	
	
	/** Returns the event that triggered the execution or `undefined` if no event triggered the execution.
	 * @return {Struct.Event} */
	static GetEvent = function() {
		return triggeringEvent;
	}
	
	/** Returns the list of all transitions that were taking during the execution.
	 * @return {Array<Struct.SimpleTransition>} */
	static GetTransitionList = function() {
		return transitionList;
	}
	
	/** Add a transition to the list of transitions that should be taken during execution
	 * @arg {Struct.SimpleTransition} _transition The transition to add
	 * @return {Undefined} */
	static AddTransition = function(_transition) {
		array_push(transitionList, _transition);
	}
	
	/** Clears all data from the this execution. Used to ensure all data is reset before trying to process a new execution.
	 * @return {Undefined} */
	static Clear = function() {
		ArrayClear(exitSet);
		ArrayClear(enterSet);
		ArrayClear(defaultEntrySet);
		StructClear(defaultHistoryTransitions);
		newHistories.Clear();
	}
	
	/** Creates a deep copy of this execution data.
	 * @return {Struct.StateEventExecutionData} */
	static Clone = function() {
		return variable_clone(self);
	}
}