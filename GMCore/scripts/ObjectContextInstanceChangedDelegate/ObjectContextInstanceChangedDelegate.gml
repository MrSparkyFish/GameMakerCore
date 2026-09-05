//feather ignore all
 
/** Callbacks for when the instance id
 * @return {Struct.ObjectContextInstanceChangedDelegate} */
function ObjectContextInstanceChangedDelegate() : MulticastAction() constructor {
	/** Add a function to this `MulticastAction`. Returns the method variable of the added function.
	 * ***
	 * Functions added this way must be context independent or must have already been converted into a method variable. Using this method to add 
	 * a context dependent function will result in the game crashing when the action is fired.
	 * ***
	 * The callback function must accept the following parameters:
	 * * `{Id.Instance}` **previousInstance** The ID of the previous GMObject Instance
	 * * `{Id.Instance}` **newInstance** The ID of the new GMObject Instance
	 * ***
	 * The callback function must return `undefined`
	 * @arg {Function} _callback The callback function to add
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Struct.Action} */
	static Add = function(_callback, _payload = undefined) {
		MulticastAction.Add(_callback, _payload);
	}
	
	/** Add a function to this `MulticastAction` specifying the scope in which it should be called. Returns the method variable of the added function.
	 * ***
	 * This method should be used to add context dependent functions such as static methods declared in constructors or script functions that can 
	 * only be called from specific instances or structs.
	 * ***
	 * The callback function must accept the following parameters:
	 * * `{Id.Instance}` **previousInstance** The ID of the previous GMObject Instance
	 * * `{Id.Instance}` **newInstance** The ID of the new GMObject Instance
	 * ***
	 * The callback function must return `undefined`
	 * @arg {Struct|Id.Instance} _context The scope the function should be called in.
	 * @arg {Function} _callback The callback function to add.
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Struct.Action} */
	static AddStatic = function(_context, _callback, _payload = undefined) {
		MulticastAction.AddStatic(_context, _callback, _payload);
	}
	
	/** Invoke each callback action one at a time and passing any relevant data.
	 * @arg {Id.Instance} previousInstance The ID of the previous GMObject Instance
	 * @arg {Id.Instance} newInstance The ID of the new GMObject Instance
	 * @return {Undefined} */
	static Broadcast = function(previousInstance, newInstance) {
		MulticastAction.Broadcast([previousInstance, newInstance]);
	}	
}