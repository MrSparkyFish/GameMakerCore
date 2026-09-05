//feather ignore all
 
/** FinalState: Represents a final pseudo-state. Final states represent the end of an activity or process started by a state. When a `FinalState` is 
 * entered,  it automatically fires off an event using the tag `[Event.Done.State.id]` where *id* is replaced with the id of the FinalState's parent 
 * (*NOT* the id you put into the `_id` arg).
 * ***
 * Implements: `IPublisher`, `ISortable`
 * Inherits: `EnterableState` -> `TransitionTarget`
 * @arg {Any} _id The ID that should be assigned to this `FinalState`
 * @return {Struct.FinalState} */
function FinalState(_id) : EnterableState(_id) constructor {
	
	/** Returns the parent owner of this `FinalState`
	 * @return {Struct.State} */
	static GetParent = function() {
		///@ignore
		static _parentGetParent = EnterableState.GetParent;
		return _parentGetParent();
	}
	
	/** Set the parent owner of this `FinalState`
	 * @arg {Struct.State} _state The owner of this `FinalState`
	 * @return {Undefined} */
	static SetParent = function(_state) {
		///@ignore
		static _parentSetParent = EnterableState.SetParent;
		_parentSetParent(_state);
		
	}
	
	/** Since a `FinalState` cannot have substates, it must be atomic. Always returns `true`.
	 * @return {Bool} */
	static IsAtomicState = function() {
		return true;
	}
}