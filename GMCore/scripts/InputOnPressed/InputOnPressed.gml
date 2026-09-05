//feather ignore all
 
/** Used to register callbacks for when an input button is pressed
 * @return {Struct.InputOnPressed} */
function InputOnPressed() : MulticastAction() constructor {
	/** Add a function to this `MulticastAction`.
	 * ***
	 * Functions added this way must be context independent or must have already been converted into a method variable. Using this method to add 
	 * a context dependent function will result in the game crashing when the action is fired.
	 * ***
	 * The callback function must accept the following parameters:
	 * * `{Enum.Input_Verb}` **verb** The input verb ID that was pressed.
	 * ***
	 * The callback function must return `undefined`	 
	 * @arg {Function} _callback The callback function to add
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Undefined} */
	static Add = function(_callback, _payload = undefined) {
		///@ignore
		static parentAdd = MulticastAction.Add;
		parentAdd(_callback, _payload);
	}
	
	/** Add a function to this `MulticastAction` specifying the scope in which it should be called.
	 * ***
	 * This method should be used to add context dependent functions such as static methods declared in constructors or script functions that can 
	 * only be called from specific instances or structs.
	 * ***
	 * The callback function must accept the following parameters:
	 * * `{Enum.Input_Verb}` **verb** The input verb ID that was pressed.
	 * ***
	 * The callback function must return `undefined`	 
	 * @arg {Struct|Id.Instance} _context The scope the function should be called in.
	 * @arg {Function} _callback The callback function to add.
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Struct.Action} */
	static AddStatic = function(_context, _callback, _payload = undefined) {
		///@ignore
		static parentAddStatic = MulticastAction.Add;
		parentAddStatic(_context, _callback, _payload);
	}
	
	/** Invoke each callback function one at a time and passing any relevant data. Passed data overrides any data set using the `SetParameters()`.
	 * @arg {Enum.Input_Verb} verb The input verb ID that was pressed.
	 * @return {Undefined} */
	static Broadcast = function(verb) {
		///@ignore
		static parentBroadcast = MulticastAction.Broadcast;
		parentBroadcast([verb]);
	}		
}