//feather ignore all
 
/** InputOnFocusGained: Represents an input game regained focus event
 * ***
 * Inherits: `MulticastAction`
 * @return {Struct.InputOnFocusGained} */
function InputOnFocusGained() : MulticastAction() constructor {
	/** Add a function to this `MulticastAction`. Returns a data struct containing details about the added callback relative to this multicast action. 
	 * ***
	 * Functions added this way must be context independent or must have already been converted into a method variable. Using this method to add 
	 * a context dependent function will result in the game crashing when the action is fired.
	 * ***
	 * The callback function must accept the following parameters:
	 * * Callbacks do not accept parameters.
	 * @arg {Function} _callback The callback function to add
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Undefined} */
	static Add = function(_callback, _payload = undefined) {
		///@ignore
		static parentAdd = MulticastAction.Add;
		parentAdd(_callback, _payload);
	}
	
	/** Add a function to this `MulticastAction` specifying the scope in which it should be called. Returns a data struct containing details about the 
	 * added callback relative to this multicast action.
	 * ***
	 * This method should be used to add context dependent functions such as static methods declared in constructors or script functions that can 
	 * only be called from specific instances or structs.
	 * ***
	 * The callback function must accept the following parameters:
	 * * Callbacks do not accept parameters.
	 * @arg {Struct|Id.Instance} _context The scope the function should be called in.
	 * @arg {Function} _callback The callback function to add.
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Struct.Action} */
	static AddStatic = function(_context, _callback, _payload = undefined) {
		///@ignore
		static parentAddStatic = MulticastAction.Add;
		parentAddStatic(_context, _callback, _payload);
	}
	
	/** Set an array of function parameters that will be passed to each callback during the execution process. You can use `undefined` to indicate
	 * that each callback in this action takes to function parameters. However, passing any other value that isn't of type `array` will result in the 
	 * game crashing when the action is executed.
	 * @arg {Undefined} _parameters Callbacks to this event should not accept parameters.
	 * @return {Undefined} */
	static SetParameters = function() {
		return;
	}	
}