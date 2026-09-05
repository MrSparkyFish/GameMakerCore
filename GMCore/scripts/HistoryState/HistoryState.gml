//feather ignore all
 
/** HistoryState: Represents a history pseudo-state. Since this is a data asset only, history state simply indicates what active states should be 
 * recorded from it's owning parent's configuration. It cannot store the recorded active states. 
 * ***
 * Implements: `IPublisher`
 * Inherits: `TransitionTarget`
 * @arg {Any} _id The ID that should be assigned to this `HistoryState`
 * @arg {Struct.TransitionalState} _parent The `TransitionalState` that is the owner of this history.
 * @return {Struct.HistoryState} */
function HistoryState(_id, _parent) : TransitionTarget(_id) constructor {
	
	
	///@ignore Whether or not this is a shallow or deep history
	isDeep = false;	
	
	///@ignore A conditionless `SimpleTransition` representing the default history state and indicates the state 
	/// to transition to if the parent state has never been entered before
	transition = undefined;
	
	//History requires a parent state.
	SetParent(_parent);
	
	
	/** Returns the transition the history uses to restore state configurations when its recording is empty.
	 * @return {Struct.SimpleTransition} */
	static GetTransition = function() {
		return transition;
	}
	
	/** Set the default transition the history should take if its unable to be restored.
	 * @arg {Struct.SimpleTransition} _transition The transition to set
	 * @return {Undefined} */
	static SetTransition = function(_transition) {
		var _parent = GetParent();
		if (is_undefined(_parent)) {
			StateError("SetTransition", "History transition cannot be set before defining the history's parent");
		}
		transition = _transition;
		transition.SetParent(_parent);
	}
	
	/** Returns `true` if this is a deep history state
	 * @return {Bool} */
	static IsDeep = function() {
		return isDeep;
	}
	
	/** Marks this history as a "deep" history. History is shallow by default.
	 * @return {Undefined} */
	static SetDeepHistory = function() {
		isDeep = true;
	}
	
	/** Returns the parent `TransitionalState` of this history (either a State or Parallel)
	 * @ignore
	 * @return {Struct.TransitionalState} */
	static GetParent = function() {
		///@ignore
		static _transitionalGetParent = TransitionalState.GetParent;
		return _transitionalGetParent();
	}
	
	/** Set the parent of this state
	 * @arg {Struct.TransionalState} _parent The parent to set
	 * @return {Undefined} */
	static SetParent = function(_parent) {
		///@ignore
		static _parentSetParent = TransitionTarget.SetParent;
		_parentSetParent(_parent);
	}
}