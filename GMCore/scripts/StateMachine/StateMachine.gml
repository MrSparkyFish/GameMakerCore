//feather ignore all

/** StateMachine: Abstract class that provides a practical example of how you can implement a concrete `StateMachine`. Other implementations of 
 * a state machine are possible and encouraged.
 * @arg {Struct.StateChart} _stateChart The chart the machine uses to delegate events.
 * @return {Struct.StateMachineContext} */
function StateMachine(_stateChart) constructor {
	
	///@ignore Optional property for the name of this machine
	name = undefined;
	
	///@ignore StateChart used by this machine for event processing.
	chart = _stateChart;
	
	///@ignore The instance specific StateEventProcessor that will execute the events sent to this machine.
	engine = new StateEventProcessor();
	engine.SetStateChart(chart);
	engine.Start();
	
	/** Returns the name of this machine or `undefined` if no name is set.
	 * @return {String} */
	static GetName = function() {
		INLINE;
		return name;
	}
	
	/** Set the name of this machine
	 * @arg {String} _name The name to set
	 * @return {Undefined} */
	static SetName = function(_name) {
		INLINE;
		name = _name;
	}
	
	/** Reset this `StateMachine`. Returns `true` if the reset was successful.
	 * @return {Bool} */
	static ResetMachine = function() {
		INLINE;
		engine.Start();
	}
	
	/** Returns the event processor driving the lifecycle of this machine.
	 * @return {Struct.StateEventProcessor} */
	static GetEventProcessor = function() {
		return engine;
	}
	
	/** Returns the `StateMachineContext` currently assigned to this `StateMachine`. This context represents the internal data and the execution status of this machine.
	 * @return {Struct.StateMachineContext} */
	static GetMachineContext = function() {
		return engine.GetStateMachineContext();
	}
	
	/** Fire an event on this `StateMachine`. Returns `true` if the machine has reached a final state configuration.
	 * @arg {String} _eventName The name of the event to trigger
	 * @return {Bool} */
	static TriggerEvent = function(_eventName) {
		var event = new Event();
		event.SetEventTag(Tag_RequestTag(_eventName));
		engine.TriggerEvent(event);
		return engine.GetStateMachineContext().IsFinal();
	}
	
}