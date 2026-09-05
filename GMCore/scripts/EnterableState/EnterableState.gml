//feather ignore all
 
/** EnterableState: Abstract class for elements that can be entered by the state system such as State, Parallel, or Final.
 * ***
 * Implements: `IPublisher`, `ISortable`
 * Inherits: `TransitionTarget`
 * @arg {Any} _id The ID that should be assigned to this `EnterableState`
 * @return {Struct.EnterableState} */
function EnterableState(_id) : TransitionTarget(_id) constructor {
	
	enum EnterableStateEvent {
		onEnter,
		onExit
	}
	
	///@ignore Used to sort states by "document order"
	order = 0;								
	
	///@ignore Delegate to invoke when entering the state
	onEnter = new Action();					
	
	///@ignore Delegate to invoke when exiting the state
	onExit = new Action();	
	
	///@ignore Indicates if "Event.Enter.State.Id" event will be raised after executing the onEnter action
	raiseEnter = false;
	
	///@ignore Indicates if "Event.Exit.State.Id" event will be raised after executing the onExit action.
	raiseExit = false;
	
	/** Returns `true` if this state raises an "Event.Enter.State.Id" event after executing the onEnter action.
	 * @return {Bool} */
	static GetRaiseOnEnter = function() {
		return raiseEnter;
	}
	
	/** Set if this state should raise an "Event.Enter.State.Id" event after executing the onEnter action
	 * @arg {Bool} _raise Set `true` to raise the event. 
	 * @return {Undefined} */
	static SetRaiseOnEnter = function(_raise) {
		raiseEnter = _raise;
	}
	
	/** Returns `true` if this state raises an "Event.Exit.State.Id" event after executing the onExit action.
	 * @return {Bool} */	
	static GetRaiseOnExit = function() {
		return raiseExit;
	}
	
	/** Set if this state should raise an "Event.Exit.State.Id" event after executing the onExit action
	 * @arg {Bool} _raise Set `true` to raise the event. 
	 * @return {Undefined} */	
	static SetRaiseOnExit = function(_raise) {
		raiseExit = _raise;
	}
	
	/** Returns the order in which this state was added (for sorting states by document order).
	 * @return {Real} */
	static GetElementOrder = function() {
		return order;
	}
	
	/** Set the document order of this state
	 * @arg {Real} _order
	 * @return {Undefined} */
	static SetElementOrder = function(_order) {
		order = _order;
	}
	
	/** Set the callback delegate that will be executed when this state is entered
	 * @arg {Struct.Action} _action The delegate to set
	 * @return {Undefined} */
	static SetOnEnter = function(_action) {
		onEnter = _action;
	}
	
	/** Set the callback delegate that will be executed when this state is entered
	 * @arg {Struct.Action} _action The callback to set
	 * @return {Undefined} */
	static SetOnExit = function(_action) {
		onEnter = _action;
	}
	
	/** Returns the callback delegate that will be invoked when this state is entered.
	 * @return {Struct.Action} */
	static GetOnEnter = function() {
		return onEnter;
	}
	
	/** Returns the callback delegate that will be invoked when this state is exited.
	 * @return {Struct.Action} */
	static GetOnExit = function() {
		return onExit;
	}
	
	/** Returns `true` if this is an atomic state. An atomic state is a state of type "final" or a state that has no children.
	 * @return {Bool} */
	static IsAtomicState = function() {
		ThrowMethodNotImplemented("IsAtomicState", self);
	}
	
}