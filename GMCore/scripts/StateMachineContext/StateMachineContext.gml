//feather ignore all

 
/** StateMachineContext: Represents intrinsic `StateMachine` data such as its active state configuration and running status. 
 * @arg {Struct.IEventProcessor} _processor The event processor used to manage the internal event queue.
 * @return {Struct.StateMachineContext} */
function StateMachineContext(_processor) constructor {
	
	///@ignore Indicates if the `chart` has been previously initialized
	initialized = false;	
	
	///@ignore The backing `StateChart` this context uses to track and verify active state configurations.
	chart = undefined;
	
	///@ignore The current "StateConfiguration" which is an encapsulation of the currently active state(s).
	activeStates = new EnterableStateContainer();		
	
	///@ignore Indicates if we are able to actively run state tasks.
	running = false;
	
	///@ignore The processor used for processing internal events raised by `IStateEventHandler`
	internalProcessor = _processor;
	
	///@ignore Indicates if incoming active state configurations should be verified before being assigned to the chart.
	verifyStatesBeforeSetting = true;
	
	///@ignore Map of the last known configurations per HistoryState.
	histories = new CapturedHistoryContainer();
	
	///@ignore The event that is currently executing for this context.
	event = undefined;
	
	///@ignore This delegate is broadcasted everytime a state is entered.
	onStateEnter = new OnStatePassage();
	
	///@ignore This delegate is broadcasted everytime a state is exited.
	onStateExit = new OnStatePassage();
	
	///@ignore This delegate is broadcasted everytime a transition is taken.
	onTransitionTaken = new OnTransitionTaken();	
	
	
	/** Returns info about the current event process
	 * @return {Struct.EventInfo} */
	static GetCurrentEventInfo = function() {
		return event;
	}
	
	/** Sets the currently executing event process
	 * @arg {Struct.EventInfo} eventInfo The event info to set
	 * @return {Undefined} */
	static SetCurrentEvent = function(eventInfo) {
		event = eventInfo;
	}
	
	/** Returns an array of all active states that the assigned `StateChart` currently has.
	 * @return {Array<Struct.EnterableState>} */
	static GetActiveStates = function() {
		return activeStates.GetStates();
	}
	
	/** Returns an array of all atomic states that are currently active in the assigned `StateChart`
	 * @return {Array<Struct.EnterableState>} */
	static GetAtomicStates = function() {
		return activeStates.GetAtomicStates();
	}		
	
	/** Returns the single top level `FinalState` in which the assigned `StateChart` terminated. Otherwise, returns `undefined`
	 * @return {Undefined} */
	static GetFinalState = function() {
		return activeStates.GetTopLevelFinalState();
	}
	
	/** Returns the container of all enterable states currently in active status for this SSC.
	 * @return {Struct.EnterableStateContainer} */
	static GetStateConfiguration = function() {
		return activeStates;
	}
	
	/** Returns `true` if this SSC is actively running.
	 * @return {Bool} */
	static IsRunning = function() {
		return running;
	}	
	
	/** Set if this FSM is actively running or not
	 * @arg {Bool} _running Should this SSC be running?
	 * @return {Undefined} */
	static SetRunning = function(_running) {
		if (!running && _running && activeStates.IsFinal()) {
			StateError("SetRunning", "The state system is in a final state and cannot be set to run again", self);
		}
		running = _running;
	}		
	
	/** Returns `true` if the specified state is in the list of currently active states
	 * @arg {Any} _id The ID of the state to check
	 * @return {Bool} */
	static IsStateActive = function(_id) {
		return activeStates.HasState(chart.GetTarget(_id));
	}
	
	/** Returns `true` if this machine is in a top level final state.
	 * @return {Bool} */
	static IsFinal = function() {
		return activeStates.IsFinal();
	}
	
	/** Set whether or not this context will verify if a new active state configuration is valid or not. Set to `false` for a slight performance boost.
	 * @arg {Bool} _shouldVerify
	 * @return {Undefined} */
	static SetVerifyLegalStateConfiguration = function(_shouldVerify) {
		verifyStatesBeforeSetting = _shouldVerify;
	}
	
	/** Returns `true` if this component should verify incoming state configurations before assigning them to the state machine. If the configuration is not
	 * valid, a `StateError` is thrown.
	 * @return {Bool} */
	static ShouldVerifyLegalStateConfiguration = function() {
		return verifyStatesBeforeSetting;
	}
	
	/** Returns the last known active state configuration for the specified `HistoryState`
	 * @arg {Struct.StateHistory} _history
	 * @return {Array<Struct.EnterableState>} */
	static GetRecordedHistory = function(_history) {
		var _lastConfig = histories.GetHistory(_history);
		if (is_undefined(_lastConfig)) {
			_lastConfig = [];
			histories.SetHistory(_history, _lastConfig);
		}
		return _lastConfig;
	}	
	
	/** Set the last known active state configuration for the specified `HistoryState`
	 * @arg {Struct.HistoryState} _history The history to set
	 * @arg {Array<Struct.EnterableState>} _recording The recorded set of states to set.
	 * @return {Undefined} */
	static SetRecordedHistory = function(_history, _recording) {
		histories.SetHistory(_history, _recording);
	}	
	
	/** Reset the last known active state configuration for the specified `HistoryState`
	 * @arg {Struct.HistoryState} _history The history to reset
	 * @return {Undefined} */
	static ResetRecordedHistory = function(_history) {
		histories.RemoveHistory(_history);
	}
	
	/** Returns the container of history recordings
	 * @return {Struct.CapturedHistoryContainer} */
	static GetHistoryCaptures = function() {
		return histories;
	}		
	
	/** (re)Initializes the state system clearing all histories and current status
	 * @return {Undefined} */
	static Initialize = function() {
		running = false;
		if (is_undefined(chart)) {
			StateError("Initialize", "Attempting to initialize a state system with no state chart.", self);
		}
		
		histories.Clear();
		activeStates.Clear();
		initialized = true;
	}		
	
	/** Set the `StateChart` that provides this context with states and transitions.
	 * Register a concrete `StateChart` to this component. This machine provides the data that describes the behavior of this component and how it
	 * should react to events and transitions.
	 * @arg {Struct.StateChart} _stateChart The `StateChart` to assign
	 * @return {Undefined} */
	static SetStateChart = function(_stateChart) {
		if (!is_instanceof(_stateChart, StateChart)) {
			ThrowInvalidType("SetStateChart", "_stateChart", _stateChart, "StateChart", self);
		}
		chart = _stateChart;
		
		//Setting a new chart changes our configuration so we should re-initialize
		Initialize();
	}			
	
	/** Returns the `StateChart` for this StateMachineContext
	 * @return {Struct.StateChart} */
	static GetStateChart = function() {
		return chart;
	}
	
	/** Returns the `IEventProcessor` responsible for managing the internal event queue.
	 * @return {Struct.IEventProcessor} */
	static GetInternalProcessor = function() {
		return internalProcessor;
	}	
	
	/** Set the processor responsible for managing the internal event queue.
	 * @arg {Struct.IEventProcessor} _processor The processor to set
	 * @return {Undefined} */
	static SetInternalProcessor = function(_processor) {
		internalProcessor = _processor;
	}	
	
	/** Returns the `OnStatePassage` delegate that is broadcasted when states are entered.
	 * @return {Struct.OnStatePassage} */
	static GetOnStateEntered = function() {
		return onStateEnter;
	}
	
	/** Returns the `OnStatePassage` delegate that is broadcasted when states are entered.
	 * @return {Struct.OnStatePassage} */
	static GetOnStateExited = function() {
		return onStateExit;
	}
	
	/** Returns the `OnTransitionTaken` delegate that is broadcasted when states are entered.
	 * @return {Struct.OnTransitionTaken} */
	static GetOnTransitionTaken = function() {
		return onTransitionTaken;
	}
}