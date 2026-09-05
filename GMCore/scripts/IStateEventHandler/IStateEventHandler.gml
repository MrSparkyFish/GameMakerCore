//feather ignore all
 
/** IStateEventHandler: This is the interface which defines how state events and transitions are executed.
 * @return {Struct.IStateEventHandler} */
function IStateEventHandler() {
	
	/** (Re)Initializes the `StateMachine` and destroys any existing states. This step completes the transition of a `StateMachine` into its
	 * initial state as described by its `StateChart`. A `MacroStep` should be called to stabilize the machine before returning. If the machine
	 * is no longer running after transitioning to its initial state, then `FinalStep()` should be called for cleanup before returning.
	 * @arg {Struct.StateExecutionContext} _executionContext Data that we can use to handle the event.	 
	 * @return {Undefined} */
	InitStep = function(_executionContext) {
		ThrowMethodNotImplemented("BeginStep");
	}
	
	/** If the `StateMachine` isn't running, then this method should do nothing. If the specified event is a cancel event, the machine should stop 
	 * running. Otherwise, the event must be set in the `StateSystemContext` and processing the event begins. This method is the primary event 
	 * execution method that is used to handle incoming (external) events.
	 * ***
	 * If the event leads to any transitions, a `TransitionStep` is performed to process them, followed by a `MacroStep` to stabilize the machine. 
	 * If the machine is no longer running after the event is handled, then `FinalStep()` should be called for cleanup before returning.
	 * @arg {Any} _event The event that we need to handle.
	 * @arg {Struct.StateExecutionContext} _executionContext Data that we can use to handle the event.
	 * @return {Undefined} */
	HandleEvent = function(_event, _executionContext) {
		ThrowMethodNotImplemented("Handle");
	}	
	
	/** Transition the specified state system from one state to the next using the provided execution data and context. Collects states that require 
	 * additional post-processing due to the transitioning process.
	 * @arg {Struct.StateExecutionContext} _executionContext The context of the event execution
	 * @arg {Struct.StateEventExecutionData} _executionData Data relevant to the current execution
	 * @arg {Array<Struct.EnterableState>} _statesToInvoke Array where we can store the states that require post processing via `MacroStep()`
	 * @return {Undefined} */
	TransitionStep = function(_executionContext, _executionData, _statesToInvoke) {
		ThrowMethodNotImplemented("Update", self);
	}
	
	/** Some states may require additional post-transition processing in order for the machine to continue receiving events. This method is called to 
	 * handle the post-processing for those states.
	 * @arg {Struct.StateExecutionContext} _executionContext Data that we can use to process internal events and return the machine to a neutral running state.
	 * @arg {Array<Struct.TransitionalState>} _statesToInvoke The list of states with active ITaskRunners
	 * @return {Undefined} */
	MacroStep = function(_executionContext, _statesToInvoke) {
		ThrowMethodNotImplemented("MacroStep");
	}
	
	/** The final step in event execution used to clean up any data. If the machine is still running, this method should do 
	 * nothing. Otherwise, this step should first exit all remaining active states and cancel any activities before handling 
	 * any `donedata` for the last final state.
	 * @arg {Struct.StateExecutionContext} _executionContext The context we need to exit states and cancel activities for
	 * @return {Undefined} */
	FinalStep = function(_executionContext) {
		ThrowMethodNotImplemented("FinalStep");
	}
	
	/** Returns `true` if the specified list of states is a legal configuration.
	 * @arg {Array<Struct.EnterableState>} _states The list of states to check
	 * @return {Bool} */
	IsLegalStateConfiguration = function(_states) {
		ThrowMethodNotImplemented("IsLegalStateConfiguration");
	}
}