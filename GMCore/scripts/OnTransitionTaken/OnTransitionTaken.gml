//feather ignore all
 
/** OnTransitionTaken: Callback delegate that is executed whenever a `StateTransition` is taken
 * @return {Struct.OnTransitionTaken} */
function OnTransitionTaken() : MulticastAction() constructor {
	
	/** Add a callback function to this `OnStatePassage` callback delegate. If the added function is scope dependent, use `AddStatic()` instead. The 
	 * supplied callback should accept the below arguments:
	 * * `{Struct.TransitionTarget}` **_from** -> The target to transition away from
	 * * `{Struct.TransitionTarget}` **_to** -> The target to transition into
	 * * `{Struct.SimpleTransition}` **_transition** -> The transition that was taken
	 * * `{Struct.TagSpecifier}` **_event** -> The tag representing the event that caused the transition to occur.
	 * @arg {Function} _callback The callback function to add
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Undefined} */
	static Add = function(_callback, _payload = undefined) {
		///@ignore
		static parentAdd = MulticastAction.Add;
		parentAdd(_callback, _payload);
	}
	
	/** Add a callback function to this `OnStatePassage` callback delegate. The supplied callback should accept the below arguments:
	 * * `{Struct.TransitionTarget}` **_from** -> The target to transition away from
	 * * `{Struct.TransitionTarget}` **_to** -> The target to transition into
	 * * `{Struct.SimpleTransition}` **_transition** -> The transition that was taken
	 * * `{Struct.TagSpecifier}` **_event** -> The tag representing the event that caused the transition to occur.
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
	 * @arg {Struct.TransitionTarget} _from The target to transition away from
	 * @arg {Struct.TransitionTarget} _to The target to transition into
	 * @arg {Struct.StateTransition} _transition The transition that was taken
	 * @arg {Struct.TagSpecifier} _event The tag representing the event that caused the transition to occur.
	 * @return {Undefined} */
	static Broadcast = function(_from, _to, _transition, _event) {
		///@ignore
		static parentBroadcast = MulticastAction.Broadcast;
		parentBroadcast([_from, _to, _transition, _event]);
	}	
}