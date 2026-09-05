//feather ignore all

/** OnStatePassage: Generic callback delegate for whenever a state is entered or exited
 * ***
 * Inherits: `MulticastAction`
 * @return {Struct.OnStatePassage} */
function OnStatePassage() : MulticastAction() constructor {
	
	/** Add a callback function to this `OnStatePassage` callback delegate. If the added function is scope dependent, use `AddStatic()` instead. The 
	 * supplied callback should accept the below arguments:
	 * * `{Struct.EnterableState}` *_state* The EnterableState where the passage occured.
	 * @arg {Function} _callback The callback function to add
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Undefined} */
	static Add = function(_callback, _payload = undefined) {
		///@ignore
		static parentAdd = MulticastAction.Add;
		parentAdd(_callback, _payload);
	}
	
	/** Add a callback function to this `OnStatePassage` callback delegate. The supplied callback should accept the below arguments:
	 * * `{Struct.EnterableState}` *_state* The EnterableState where the passage occured.
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
	 * @arg {Struct.EnterableState} enterableState The EnterableState where the passage occured.
	 * @return {Undefined} */
	static Broadcast = function(enterableState) {
		///@ignore
		static parentBroadcast = MulticastAction.Broadcast;
		parentBroadcast([enterableState]);
	}	
	
}