//feather ignore all
 
/** Abstract base class that acts as a wrapper for callback functions/methods. Provides a couple simple methods to make it easier to set/get/execute callbacks with prebaked data. Subclass to create more customized callbacks.
 * @deprecated
 * @ignore
 * @arg {Function} callback The callback function to assign.
 * @return {Struct.Callback} */
function Callback(callback = ReturnUndefined) constructor {
	
	///@ignore The function that will be invoked
	self.callback = callback;
	
	/** Returns the scope the callback function is bound to. Returns `undefined` if the callback is context independent
	 * @return {Struct|Id.Instance|Undefined} */
	static GetBoundContext = function() {
		return method_get_self(callback);
	};
	
	/** Returns the currently bound callback method.
	 * @return {Function} */
	static GetBoundCallback = function() {
		INLINE;
		return callback;
	}
	
	/** Set the function or method this callback will execute.
	 * @arg {Function} func The function or method to set for this callback
	 * @return {Undefined} */
	static SetBoundCallback = function(func) {
		INLINE;
		callback = func;
	}
	
	/** Removes the function assigned to this callback and sets a generic `undefined` one instead. 
	 * @return {Undefined} */
	static Reset = function() {
		INLINE;
		//Reset the action to default empty state.
		callback = ReturnUndefined;
	}	
	
	/** Returns true if there's a callable function assigned to this `Callback`
	 * @return {Bool} */	
	static IsValid = function() {
		return (is_callable(callback) && (callback != ReturnUndefined));
	}
	
	/** Invoke the callback held by this delegate passing it the specified function arguments.
	 * @arg {Array<Any>} [data] Optional array of data to pass
	 * @return {Any} */
	static Execute = function(data = undefined) {
		return method_call(callback, data)
	}
}