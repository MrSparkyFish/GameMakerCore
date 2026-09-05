//feather ignore all
 
/** StateEventProcessor: Processes the events sent to a `StateMachine`. The semantics for how events are executed and handled are encapsulated 
 * in implementations of `IStateEventHandler` most notably `StateDefaultExecutionHandler`.
 * ***
 * This executor uses `StateExecutionContext` to manage the currently active states and to provide all the data that a concrete 
 * `IStateEventHandler` can use to handle event executions.
 * ***
 * Implements: `IEventProcessor`
 * @arg {Struct.IStateEventHandler} _eventHandler The concrete implementation to assign this processor.
 * @return {Struct.StateEventProcessor} */
function StateEventProcessor(_eventHandler = new StateDefaultExecutionHandler()) constructor {
	Implement(IEventProcessor);
	
	///@ignore concrete `IStateEventHandler` that guides event execution.
	handler = _eventHandler;
	
	///@ignore The `StateExecutionContext` that the handler can use for event processing.
	executionContext = new StateExecutionContext(self);
	
	///@ignore The list of events that were sent to a `StateMachine`. These are the events that we pass to the handler for execution
	externalEventQueue = [];
	
	
	
	/** Add an external event to this processor. Added events will not be processed until the next `TriggerEvent()` method is invoked.
	 * @arg {Struct.Event} _event The event that will be processed.
	 * @return {Undefined} */
	static AddEvent = function(_event) {
		if (!is_undefined(_event)) {
			array_push(externalEventQueue, _event);
		}
	}
	
	/** Returns the `StateChart` being used for event execution.
	 * @return {Struct.StateChart} */
	static GetStateChart = function() {
		return executionContext.GetStateChart();
	}
	
	/** Set the `StateChart` that should be used for event execution
	 * @arg {Struct.StateChart} _chart The chart to set
	 * @return {Undefined} */
	static SetStateChart = function(_chart) {
		//Resetting the chart means active events no longer line up with corresponding states, so reset the event queue.
		ArrayClear(externalEventQueue);	
		executionContext.SetStateChart(_chart);
	}
	
	/** Initialize the assigned `StateMachine` with the specified active state configuration. This will re-initialize the assigned machine and clear all relevant data.
	 * @arg {Array<String>} _atomicStates An array of state id's to set. The id's MUST belong to atomic states.
	 * @return {Undefined} */
	static SetActiveStates = function(_atomicStates) {
		executionContext.Initialize();
		
		var _states = [];
		var _tt;
		var _len = array_length(_atomicStates);
		for (var i = 0; i < _len; i++) {
			_tt = GetStateChart().GetTarget(_atomicStates[i]);
			
			if (StateIsEnterable(_tt) && _tt.IsAtomicState()) {
				while (!is_undefined(_tt) && !ArrayPushUnique(_states, _tt)) {
					_tt = _tt.GetParent();
				}
			}
			
			else {
				StateError("SetActiveStates", $"State with id {_tt.GetId()} is not atomic");
			}
		}
		
		if (handler.IsLegalStateConfiguration(_states)) {
			_len = array_length(_states);
			for (var i = 0; i < _len; i++) {
				executionContext.GetStateMachineContext().GetStateConfiguration().AddState(_states[i]);
			}
		}
		else {
			StateError("SetActiveStates", $"Illegal state configuration!");
		}
	}
	
	/** Returns a shallow copy of this processor
	 * @return {Struct.StateEventProcessor} */
	static Clone = function() {
		return variable_clone(self, 0);
	}
	
	/** Set whether or not we should verify if a new active state configuration is valid or not. Set to `false` for a slight performance boost.
	 * @arg {Bool} _shouldVerify
	 * @return {Undefined} */
	static SetVerifyLegalStateConfiguration = function(_shouldVerify) {
		executionContext.SetVerifyLegalStateConfiguration(_shouldVerify);
	}
	
	/** Returns `true` if we should verify incoming state configurations before assigning them to the state machine context. If the configuration is not
	 * valid, a `StateError` is thrown.
	 * @return {Bool} */
	static ShouldVerifyLegalStateConfiguration = function() {
		return executionContext.ShouldVerifyLegalStateConfiguration();
	}	
	
	/** Returns `true` if the machine being processed is running.
	 * @return {Bool} */
	static IsRunning = function() {
		return executionContext.IsRunning();
	}
	
	/** Clear all pending events and begin processing the machine.
	 * @return {Undefined} */
	static Start = function() {
		ArrayClear(externalEventQueue);
		handler.InitStep(executionContext);
	}
	
	/** Returns `true` if there is at least 1 event waiting to be processed.
	 * @return {Bool} */
	static HasPendingEvent = function() {
		return (!ArrayIsEmpty(externalEventQueue));
	}
	
	/** Returns the number of events waiting to be processed by this processor.
	 * @return {Real} */
	static EventCount = function() {
		return array_length(externalEventQueue);
	}
	
	/** Processes all pending and incoming events until there are no more pending events.
	 * @return {Undefined} */
	static ProcessEvents = function() {
		
		while (executionContext.IsRunning()) {
			var _event = array_shift(externalEventQueue);
			//event = undefined if no more events are available
			if (is_undefined(_event)) {
				break;
			}
			handler.HandleEvent(_event, executionContext);
		}
	}
	
	/** Primary worker method. Re-evaluates the current status of the executing machine whenever events are triggered.
	 * @arg {Array<Struct.Event>} _events The list of events to process
	 * @return {Undefined} */
	static TriggerEvents = function(_events) {
		if (!is_undefined(_events)) {
			array_foreach(_events, AddEvent);
		}
		ProcessEvents();
	}
	
	/** Processes the specified event. Convenience method for when only one event needs to be processed.
	 * @arg {Struct.Event} _event The event to process
	 * @return {Undefined} */
	static TriggerEvent = function(_event) {
		AddEvent(_event);
		ProcessEvents();
	}
	
	/** Returns the context for the machine being processed.
	 * @return {Struct.StateMachineContext} */
	static GetStateMachineContext = function() {
		return executionContext.GetStateMachineContext();
	}
	
	/** Check if the specified state is in the active state configuration of the currently executing `StateMachineContext`
	 * @arg {String} _id The ID of the state to check for
	 * @return {Undefined} */
	static IsStateActive = function(_id) {
		return executionContext.GetStateMachineContext().IsStateActive(_id);
	}
}