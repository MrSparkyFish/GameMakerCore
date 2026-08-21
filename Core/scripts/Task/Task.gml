//feather ignore all
 
/** Abstract class that represents the extrinsic data of an asynchronous task. A `Task` initiates the action of a concrete `ITaskRunner` which 
 * contains the actual execution logic for the task.
 * ***
 * Implements: `IAction`
 * @return {Struct.Task} */
function Task() constructor {
	
	///@ignore The identifier for this task.
	taskId = undefined;
	
	///@ignore The task type that is being invoked.
	type = undefined;
	
	///@ignore The optional URL for an external service
	source = undefined
	
	///@ignore True if events should be forwarded to the invoked process when received
	autoForward = true;
	
	///@ignore The owner of this Task
	owner = undefined;
	
	
	/** Returns the ID of this task
	 * @return {String} */
	static GetId = function() {
		INLINE;
		return taskId;
	}
	
	/** Set the ID of this task
	 * @arg {String} _id The ID to set
	 * @return {Undefined} */
	static SetId = function(_id) {
		if (!is_string(_id)) {
			ThrowInvalidType("SetId", "_id", _id, "String");
		}
		taskId = _id;
	}
	
	/** Returns the task type or `undefined` if no type has been set.
	 * @return {String} */
	static GetType = function() {
		INLINE;
		return type;
	}
	
	/** Set the task type. Useful for implementing varied task execution processes.
	 * @arg {String} _type The type to set
	 * @return {Undefined} */
	static SetType = function(_type) {
		type = _type;
	}
	
	/** Returns the source URL for an external service or `undefined` if no source URL has been set
	 * @return {String} */
	static GetSourceURL = function() {
		INLINE;
		return source;
	}
	
	/** Set the source URL for an external service
	 * @arg {String} _source The source URL to set
	 * @return {Undefined} */
	static SetSourceURL = function(_source) {
		source = _source;
	}
	
	/** Returns `true` if this task auto forwards events to external processes
	 * @return {Bool} */
	static GetAutoForward = function() {
		INLINE;
		return autoForward;
	}
	
	/** Set if this task should auto forward events to external processes. This property is `true` by default.
	 * @arg {Bool} _forward Whether or not auto forward should be on
	 * @return {Undefined} */
	static SetAutoForward = function(_forward) {
		autoForward = _forward;
	}
	
	/** Returns the owner of this task
	 * @return {Struct.ObjectContext} */
	static GetOwner = function() {
		INLINE;
		return owner;
	}
	
	/** Set the owner of this task
	 * @arg {Struct.ObjectContext} _owner The owner to set
	 * @return {Undefined} */
	static SetOwner = function(_owner) {
		owner = _owner;
	}
	
	/** This method is called when this `Task` is ended or is no longer able to keep running (the owner has ended, the runner has ended, etc).
	 * @return {Undefined} */
	static TaskEnded = function() {
		ThrowMethodNotImplemented("TaskEnded");
	}
	
	/** This method should execute any necessary boilerplate code, then use the `executionContext` to facilitate the execution of a concrete `ITaskRunner`.
	 * @arg {Struct} executionContext A struct that provides the data needed for the execution of this `Task`.
	 * @return {Undefined} */
	static Execute = function(executionContext) {
		ThrowMethodNotImplemented("Execute");
	}
}