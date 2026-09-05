//feather ignore all

/** Represents a callback with prebaked callback parameters. When executed, the action passes the callback the prebaked payload defined at binding time.
 * @return {Struct.Action} */
function Action() constructor {
	
	#region Internal 
		///@ignore Empty payload for when the callback requires no input or if a payload cannot be set/detected.	
		static emptyPayload = [];	
		
		///@ignore Prebaked event data to pass to the callback
		payload = emptyPayload;	
		
		///@ignore Wrapper for manipulating callbacks
		callback = ReturnUndefined;	
		
		/** Internal helper to bind a function/method to this callback action using its currently bound context with optional data to pass to it's execution.
		 * @ignore
		 * @arg {Function} _function The callback function to assign to this `Action`
		 * @arg {Struct|Id.Instance|Undefined} _context The scope the method will be called in. Use `undefined` for the current self scope
		 * @arg {Array<Any>} [_parameters] Optional array of data to pass to the callback during its execution. 
		 * @return {Struct.Action} */
		static BindInternal = function(_function, _context = undefined, _parameters = undefined) {
			//Update the callback first. If this doesn't get updated, then we want previous params to stick around.
			if (!is_callable(_function)) {
				if (ACTION_LOG_WARNING) {
					LogWarning(ExceptionMessage("BindInternal", $"Function {_function} is not callable and cannot be bound"));
				}
			}
			else {
				//Assign the callback as a method to be executed in the specified context
				try {
					callback = (method(_context, _function));
				}
				catch(error) {
					ActionError("BindInternal", $"Invalid method context {_context}. Must be `undefined` or of type `Struct` or `Id.Instance`.");
				}
				
				//Update the payload only if we have new parameters to set. Otherwise keep the current prebake params
				if (is_array(_parameters)) {
					payload = _parameters;
				}
			}		
			return self;
		}	
		
	#endregion
	
	/** Bind a function to this callback action using its currently bound context with optional data to pass to it's execution. Use this
	 * method to bind anon functions and non-static method variables such as those defined in constructors or GMObject instances.
	 * ***
	 * Functions added this way must be context independent or must have already been converted into a method variable. Using this method to add 
	 * a context dependent function will result in the game crashing when the action is fired.
	 * ***
	 * The callback function must accept the following parameters in addition to the prebaked payload:
	 * * `{N/A}`
	 * ***
	 * The callback function can return `Any` data type.
	 * @arg {Function} _function The callback function to assign to this `Action`
	 * @arg {Array<Any>} [_parameters] `[=undefined]` Optional array of additional function parameters to prebake. Prebake data is attached to the end of the required parameters passed to `Execute()`.
	 * @return {Struct.Action} */
	static Bind = function(_function, _parameters = undefined) {
		return BindInternal(_function, undefined, _parameters);
	}
	
	/** Bind a function to this callback action with optional data to pass to it's execution. Use this method to set the target of your callback
	 * to an instance or a struct to ensure it's called using the correct scope. This is the prefered binding method for binding global script
	 * functions and static method variables. 
	 * ***
	 * This method should be used to add context dependent functions such as static methods declared in constructors or script functions that can 
	 * only be called from specific instances or structs.
	 * ***
	 * The callback function must accept the following parameters in addition to the prebaked payload:
	 * * `{N/A}`
	 * ***
	 * The callback function can return `Any` data type.
	 * @arg {Struct|Id.Instance} _context The context to bind.
	 * @arg {Function} _function The function to bind
	 * @arg {Array<Any>} [_parameters] Optional array of additional function parameters to prebake. Prebake data is attached to the end of the required parameters passed to `Execute()`.
	 * @return {Struct.Action} */
	static BindStatic = function(_context, _function, _parameters = undefined) {
		return BindInternal(_function, _context, _parameters);
	}
	
	/** Invokes the stored callback function using the prebaked payload setup during binding. Any prebake data is attached to the end of the parameters passed to this method.
	 * @arg {Array<Any>} [data] Optional array of data to pass to the bound callback function. 
	 * @return {Any} */
	static Execute = function(data = undefined) {
		try {
			return method_call(callback, (is_array(data)) ? array_concat(data, payload) : payload);
		}
		//Throw an error if something went wrong with the execution.
		ActionError("Execute", "Unable to execute bound callback. Callback, payload, or context may not be valid." + "\n Error Details" +  $"{error}");
	}
	
	/** Returns the currently bound callback method.
	 * @return {Function} */
	static GetCallback = function() {
		INLINE;
		return callback;
	}
	
	/** Returns true if there's a valid `Callback` assigned to this `Action`
	 * @return {Bool} */
	static IsBound = function() {
		return (is_callable(callback) && (callback != ReturnUndefined));
	}
	
	/** Removes the callback function from this action.
	 * @return {Undefined} */
	static Unbind = function() {
		payload = emptyPayload;
		callback = ReturnUndefined;
	}
	
	/** Returns the context set for this `Action` which will be a reference to a `struct` or an `instance` of a GMObject. Can also return `undefined` if no 
	 * context was specified or if no callback is defined. 
	 * @return {Struct|Id.Instance|Undefined} */
	static GetContext = function() {
		return method_get_self(callback);
	}		
}