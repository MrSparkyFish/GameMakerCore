//feather ignore all
 
/** This interface is used to bridge the gap between a parent executor and types of invocable tasks by defining the possible interactions between 
 * them. 
 * ***
 * A `Task` must first register a concrete `ITaskRunner` with the appropriate parent *"executor"* (the object that will initiate this runner). The 
 * communication link between the parent executor and the invoked `Task` is an asynchronous bi-directional events pipe. All events triggered on 
 * the parent executor get forwarded to the invoked `Task`. The processing semantics for these events depend on their target and therefore vary 
 * per  implementation of this interface. The invoked `Task` must fire a "done" event when it concludes and may not fire any additional events
 * after it.
 * ***
 * The general lifecycle of an `ITaskRunner` can be outlined as follows:
 * * Instantiation of the runner
 * * Initiation of the runner via the `StartRun()` method 
 * * Zero or more bi-directional event triggering
 * * Termination of the runner via `EndRun()`
 * ***
 * All events triggered on the parent executor get forwarded to the invoked task. The processing semantics for these events depends on the 
 * targeted `Task` and therefore vary per implementation of this interface
 * ***
 * Implements 
 * @return {Struct.ITaskRunner} */
function ITaskRunner() {
	//Provides the `SendEvent()` method that you can use to send events from the parent executor of this ITaskRunner to the Task
	//Provides the `CancelEvent()` method that you can use to cancel events sent to the Task.
	IEventDispatcher();
	
	/** Returns this `ITaskRunner` ID.
	 * @return {String} */ 
	GetTaskRunnerId = function() {
		ThrowMethodNotImplemented("GetInvokeId");
	}
	
	/** Set the ID of this `ITaskRunner`. The ID should be provided by the parent executor.
	 * @arg {String} id The ID to set
	 * @return {Undefined} */
	SetTaskRunnerId = function(id) {
		ThrowMethodNotImplemented("SetInvokeId");
	}
	
	/** Sets the parent object of this `ITaskRunner` through which this runner is initiated.
	 * @arg {Struct.ObjectContext} executor The object that initiates this runner.
	 * @return {Undefined} */
	SetParentExecutor = function(executor) {
		ThrowMethodNotImplemented("SetParentExecutor");
	}
	
	/** Returns the `IEventProcessor` that you can use to send events back to the parent executor of this `ITaskRunner`. Use `SendEvent()` to send 
	 * events from the parent executor to the `Task`.
	 * @return {Struct.IEventProcessor} */
	GetChildProcessor = function() {
		ThrowMethodNotImplemented("GetChildProcessor");
	}
	
	/** Begins running this `ITaskRunner`.
	 * @arg {Any} data Any additional data that this runner requires for the task
	 * @return {Undefined} */
	StartRun = function(data) {
		ThrowMethodNotImplemented("Invoke");
	}
	
	/** Stops running this `ITaskRunner` and performs any necessary cleanup.
	 * @return {Undefined} */
	EndRun = function() {
		ThrowMethodNotImplemented("EndRun");
	}
}