//feather ignore all
 
/** StateExecutionContext: Represents event execution data that can be used by an `IStateEventHandler` for event execution.
 * ***
 * Implements: `IEventProcessor`
 * @arg {Struct.StateEventProcessor} _processor The processor managing the execution of this context.
 * @return {Struct.StateExecutionContext} */
function StateExecutionContext(_processor) constructor {
	Implement(IEventProcessor);
	
	///@ignore The decoupled intrinsic state machine data. 
	sc = new StateMachineContext(self);
	
	///@ignore The `StateEventProcessor` of this execution context (the processor managing the execution).
	processor = _processor;
	
	///@ignore The external `IEventProcessor` for actions to communicate back on
	externalProcessor = _processor;
	
	///@ignore The list of internal events raised by `IStateEventHandler` during its handling process. These are the events to be handled by its `MacroStep()` function
	internalEventQueue = [];
	
	///@ignore Indicates if the state configuration of a machine should be checked before being set post event handling.
	checkLegalConfiguration = true;
	
	///@ignore Map of `ITaskRunner` ID's keyed by a `Task` Id
	runnerIDs = {};
	
	///@ignore Map of `ITaskRunner` keyed by their unique Id
	taskRunners = {};
	
	
	/** Returns the event processor managing this execution context
	 * @return {Struct.StateEventProcessor} */
	static GetEventProcessor = function() {
		return processor;
	}
	
	/** Returns the `IEventProcessor` that actions can use to communicate back on
	 * @return {Struct.IEventProcessor} */
	static GetExternalProcessor = function() {
		return externalProcessor;
	}
	
	/** Returns true if the `StateMachine` represented by this execution context is still running.
	 * @return {Bool} */
	static IsRunning = function() {
		return sc.IsRunning();
	}
	
	/** Stop running the represented `StateMachine`
	 * @return {Undefined} */
	static StopRunning = function() {
		sc.SetRunning(false);
	}
	
	/** Set whether or not this context will verify if a new active state configuration is valid or not. Set to `false` for a slight performance boost.
	 * @arg {Bool} _shouldVerify
	 * @return {Undefined} */
	static SetVerifyLegalStateConfiguration = function(_shouldVerify) {
		checkLegalConfiguration = _shouldVerify;
	}
	
	/** Returns `true` if this component should verify incoming state configurations before assigning them to the state machine. If the configuration is not
	 * valid, a `StateError` is thrown.
	 * @return {Bool} */
	static ShouldVerifyLegalStateConfiguration = function() {
		return checkLegalConfiguration;
	}
	
	/** Clears the internal event queue and marks the state machine as running.
	 * @return {Undefined} */
	static Initialize = function() {
		ArrayClear(internalEventQueue);
		sc.Initialize();
		sc.SetRunning(true);
	}
	
	/** Returns the `StateChart` that should be used during the event execution process.
	 * @return {Struct.StateChart} */
	static GetStateChart = function() {
		return sc.GetStateChart();
	}
	
	/** Set the `StateChart` that we should provide to the `IStateEventHandler` during event execution.
	 * @arg {Struct.StateChart} _stateChart The chart to set
	 * @return {Undefined} */
	static SetStateChart = function(_stateChart) {
		sc.SetStateChart(_stateChart);
	}	
	
	/** Returns the intrinsic state machine data that should be useding during the event execution process.
	 * @return {Struct.StateMachineContext} */
	static GetStateMachineContext = function() {
		return sc;
	}
	
	/** Returns the event delegate for when a state is entered.
	 * @return {Struct.OnStatePassage} */
	static GetOnStateEntered = function() {
		return sc.GetOnStateEntered();
	}
	
	/** Returns the event delegate for when a state is exited.
	 * @return {Struct.OnStatePassage} */
	static GetOnStateExited = function() {
		return sc.GetOnStateExited();
	}
	
	/** Returns the event delegate for when a transition is taken
	 * @return {Struct.OnTransitionTaken} */
	static GetOnTransitionTaken = function() {
		return sc.GetOnTransitionTaken();
	}
	
	/** Adds an event to this processor
	 * @arg {Struct.Event} _event The event to add
	 * @return {Undefined} */ 
	static AddEvent = function(_event) {
		array_push(internalEventQueue, _event);
	}
	
	/** Returns the next internal event from the queue. Returns `undefined` if no events are available.
	 * @return {Struct.Event} */
	static NextInternalEvent = function() {
		return array_shift(internalEventQueue);
	}
	
	/** Returns `true` if there is at least 1 pending internal event
	 * @return {Bool} */
	static HasPendingInternalEvent = function() {
		return (!ArrayIsEmpty(internalEventQueue));
	}
	
	/** Remove a previously active `ITaskRunner` which must have already been canceled.
	 * @arg {Struct.Task} _task The task whose runner we want removed. 
	 * @return {Undefined} */
	static RemoveTaskRunner = function(_task) {
		StructTryRemoveMember(taskRunners, _task.GetId());
	}
	
	/** Returns the `ITaskRunner` that is registered to the specified task or `undefined` if no runner has been set for the task.
	 * @arg {Struct.Task} _task The task to get the runner for
	 * @return {Struct.ITaskRunner} */
	static GetTaskRunner = function(_task) {
		var _taskId = _task.GetId();
		if (is_undefined(_taskId)) {
			StateError("GetTaskRunner", "Task does not have a valid ID");
		}
		
		var runnerId = runnerIDs[$ _taskId];
		if (is_undefined(runnerId)) {
			StateError("GetTaskRunner", $"An ITaskRunner has not been registered for task with ID {_taskId}");
		}
		return taskRunners[$ runnerId];
	}
	
	/** Register an `ITaskRunner` to the specified `Task`
	 * @arg {Struct.Task} _task The `Task` to register the runner with
	 * @arg {Struct.ITaskRunner} _taskRunner The runner to register
	 * @return {Undefined} */
	static RegisterTaskRunner = function(_task, _taskRunner) {
		var _runnerId = _taskRunner.GetTaskRunnerId();
		if (is_undefined(_runnerId)) {
			StateError("RegisterTaskRunner", $"ITaskRunner does not have a valid ID");
		}
		
		var _taskId = _task.GetId();
		if (is_undefined(_taskId)) {
			StateError("RegistierTaskRunner", "Task does not have a valid ID");
		}
		
		runnerIDs[$ _taskId] = _runnerId;
		taskRunners[$ _runnerId] = _taskRunner;
	}
	
	/** Cancel the `ITaskRunner` associated with the specified `Task` and remove it from this context
	 * @arg {Struct.Task} _task The `Task` to cancel
	 * @return {Undefined} */
	static CancelTaskRunner = function(_task) {
		var _runnerId = runnerIDs[$ _task.GetId()];
		if (!is_undefined(_runnerId)) {
			try {
				GetTaskRunner().EndRun();
			}
			catch (error) {
				var event = new Event();
				event.SetEventTag(Tag_RequestTag($"TaskRunner.{_runnerId}.Failed.EndRun"));
				event.SetEventType(EventType.error);
				AddEvent(event);
			}
			RemoveTaskRunner(_task);
		}
	}
}