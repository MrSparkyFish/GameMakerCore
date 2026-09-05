//feather ignore all

/** State: Describes the particular behavior of a `StateChart`. 
 * ***
 * Implements: `IPublisher`, `ISortable`
 * Inherits: `TransitionalState` -> `EnterableState` -> `TransitionTarget`
 * @arg {Any} _id The ID that should be assigned to this `State`
 * @return {Struct.State} */
function State(_id) : TransitionalState(_id) constructor {
	
	///@ignore A child which identifies the initial state for states that have substates
	initial = undefined;
	
	///@ignore The ID of the initial substate of this compound state (valid only when substates are present).
	first = undefined;
	
	
	/** Returns the initial state designator for this `State` or `undefined` if this state doesn't have one.
	 * @return {Struct.InitialState} */
	static GetInitial = function() {
		return initial;
	}
	
	/** Set the `InitialState` directly. It is recommended to use `SetFirst()` instead.
	 * @arg {Struct.InitialState} _initial The initial transition to set for this state. 
	 * @return {Undefined} */
	static SetInitial = function(_initial) {
		first = undefined;
		initial = _initial;
		initial.SetParent(self);
	}	
	
	/** Returns the Id of the 
	 * @return {Any} */
	static GetFirst = function() {
		return first;
	}
	
	/** Use this method to indicate which substate of this `State` should be entered first (if any).
	 * @arg {Any} _id The id of the substate that should be transition to when this state is entered.
	 * @return {Undefined} */
	static SetFirst = function(_id) {
		first = _id;
		
		var _trans = new SimpleTransition();
		_trans.SetNext(_id);
		
		initial = new InitialState();
		initial.SetGenerated();
		initial.SetTransition(_trans);
		initial.SetParent(self);
	}
	
	/** Add the specified `EnterableState` as a child to this state
	 * @arg {Struct.EnterableState} _state The state to add
	 * @return {Undefined} */
	static AddChild = function(_state) {
		///@ignore
		static _parentAddChild = TransitionalState.AddChild;
		_parentAddChild(_state);
	}
	
	/** Returns `true` if this state is atomic. To be considered atomic, the state must not have any children.
	 * @return {Bool} */
	static IsAtomicState = function() {
		return ArrayIsEmpty(children);
	}
	
	/** Returns `true` if this is a compound state. To be considered compound, the state must have at least one substate.
	 * @return {Bool} */
	static IsCompoundState = function() {
		return (!IsAtomicState());
	}
	
	/** Returns `true` if this is a region state (a substate of a `ParallelState`).
	 * @return {Bool} */
	static IsRegion = function() {
		return is_instanceof(GetParent(), ParallelState);
	}
}