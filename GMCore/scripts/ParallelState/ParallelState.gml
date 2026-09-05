//feather ignore all
 
/** ParallelState: Wrapper element that encapsulates state regions. When entering or exiting a parallel state, all corresponding active regions are 
 * also entered or exited.
 * ***
 * Implements: `IPublisher`, `ISortable`
 * Inherits: `TransitionalState` -> `EnterableState` -> `TransitionTarget`
 * @arg {Any} _id The ID that should be assigned to this `ParallelState`
 * @return {Struct.ParallelState} */
function ParallelState(_id) : TransitionalState(_id) constructor {
	
	/** A `ParallelState` can never be atomic. Always returns `false`
	 * @return {Bool} */
	static IsAtomicState = function() {
		return false;
	}
	
	/** Add a `TransitionalState` as a region of this parallel
	 * @arg {Struct.TransitionalState} _child The state to add as a region
	 * @return {Undefined} */ 
	static AddChild = function(_child) {
		///@ignore
		static _parentAddChild = TransitionalState.AddChild;
		_parentAddChild(_child);
	}
}