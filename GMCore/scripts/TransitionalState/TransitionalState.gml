//feather ignore all
 
/** TransitionalState: Abstract base class for elements that can perform stateful behavior and be transitioned out of, such as State or Parallel.
 * ***
 * Implements:`ISortable`
 * Inherits: `EnterableState` -> `TransitionTarget`
 * @arg {Any} _id The ID that should be assigned to this `TransitionalState`
 * @return {Struct.TransitionalState} */
function TransitionalState(_id) : EnterableState(_id) constructor {
	Implement(ISortable);
	
	///@ignore list of outgoing transitions from this state. Should be in document order
	transitions = [];
	
	///@ignore List of history states owned by a given state (applies to non-leaf states).
	history = [];
	
	///@ignore List of children that this state has
	children = [];
	
	///@ignore List of tasks for this state. Each task defines a different async process that should be invoked immediately after the 
	/// onEnter action. Transitions become candidates only after the invoked process has been completed. 
	tasks = new TaskContainer();
	
	
	/** Returns the container of tasks that you can use to manipulate the tasks that are available to this state.
	 * @return {Struct.TaskContainer} */
	static GetTasks = function() {
		return tasks;
	}
	
	/** Updates the ancestors for this `TransitionalState`, all of its children, and any history it might have.
	 * @return {Undefined} */
	static UpdateDescendantAncestors = function() {
		///@ignore 
		static _parentUpdateAncestors = EnterableState.UpdateDescendantAncestors;
		_parentUpdateAncestors();
		
		//Update my history ancestors
		var _history;
		for (var i = 0; i < array_length(history); i++) {
			_history = history[i];
			_history.UpdateDescendantAncestors();
		}
		
		//Update the ancestors of my children
		var _child;
		for (var j = 0; j < array_length(children); j++) {
			_child = children[j];
			_child.UpdateDescendantAncestors();
		}
	}
	
	/** Returns the parent of this `TransitionalState`
	 * @return {Struct.TransitionalState} */
	static GetParent = function() {
		///@ignore 
		static _enterableGetParent = EnterableState.GetParent;	
		return _enterableGetParent();
	}
	
	/** Set the parent of this `TransitionalState`. Does NOT add this state as a child of the parent. To add a child, use `AddChild()` instead (which will 
	 * also update the parent assignment).
	 * @arg {Struct.TransitionalState} _parent The parent to set for this state.
	 * @return {Undefined} */
	static SetParent = function(_parent) {
		///@ignore
		static _enterableSetParent = EnterableState.SetParent;
		return _enterableSetParent(_parent);
	}
	
	/** Get the ancestor of this `TransitoinalState` at the specified index
	 * @arg {Real} _level The level (index) of the ancestor to get where 0 returns the root ancestor.
	 * @return {Struct.TransitionalState} */
	static GetAncestor = function(_level) {
		///@ignore
		static _enterableGetAncestor = EnterableState.GetAncestor;
		return _enterableGetAncestor(_level);
	}
	
	/** Returns all transitions enabled by this state
	 * @return {Array<Struct.StateTransition>} */
	static GetTransitions = function() {
		return transitions;
	}
	
	/** Add a transition to the array of outgoing transitions for this state
	 * @arg {Struct.StateTransition} _transition The transition to add
	 * @return {Undefined} */
	static AddTransition = function(_transition) {
		array_push(transitions, _transition);
		_transition.SetParent(self);
	}
	
	/** Returns `true` if this state has any history pseudo-states
	 * @return {Bool} */
	static HasHistory = function() {
		return (array_length(history) > 0);
	}
	
	/** Returns the array of history substates assigned to this state
	 * @return {Array<Struct.HistoryState>} */
	static GetHistory = function() {
		return history;
	}
	
	/** Returns all `EnterableState` children assigned to this state
	 * @return {Array<Struct.EnterableState>} */
	static GetChildren = function() {
		return children;
	}
	
	/** Add the specified `EnterableState` as a child of this state
	 * @ignore
	 * @arg {Struct.EnterableState} _state The state to add
	 * @return {Undefined} */
	static AddChild = function(_state) {
		array_push(children, _state);
		_state.SetParent(self);
	}
	
	/** Add a History state as a substate of this one
	 * @arg {Struct.HistoryState} _history The history state to add
	 * @return {Undefined} */
	static AddHistory = function(_history) {
		array_push(history, _history);
		_history.SetParent(self);
	}
	
	/** Add a `State` object as a substate to this `TransitionalState`. Wrapper for `AddChild` so we can avoid automatic typecasting
	 * @arg {Struct.State} _state The state to add as a substate
	 * @return {Undefined} */
	static AddState = function(_state) {
		AddChild(_state);
	}
	
	/** Add a `ParallelState` object as a substate to this `TransitionalState`. Wrapper for `AddChild` so we can avoid automatic typecasting
	 * @arg {Struct.ParallelState} _parallel The state to add as a substate
	 * @return {Undefined} */	
	static AddParallel = function(_parallel) {
		AddChild(_parallel);		
	}
	
	/** Add a `FinalState` object as a substate to this `TransitionalState`. Wrapper for `AddChild` so we can avoid automatic typecasting
	 * @arg {Struct.FinalState} _final The state to add as a substate
	 * @return {Undefined} */	
	static AddFinal = function(_final) {
		AddChild(_final);		
	}
	
	/** Creates and add a targetless transition to this state keyed by an event string.
	 * @arg {String} _event The name of the event that triggers the callback.
	 * @arg {Function} _callback The callback function to trigger
	 * @return {Undefined} */ 
	static AddEvent = function(_event, _callback) {
		var _trans = new StateTransition();
		_trans.SetType(State_TransitionType.internal);
		_trans.GetOnTransition().Bind(_callback);
		_trans.SetEvent(Tag_RequestTag(_event));
		AddTransition(_trans)
	}	
	
	/** Inherits the callback functions from the specified map of functions.
	 * @arg {Struct} _events A map of callback functions. Member names may be delimited using a period. For example, `{"Event.Door.Open" : function(){}}` is a valid event struct.
	 * @return {Undefined} */
	static DefineEvents = function(_events) {
		//An event should only be inherited if I don't already provide a definition for it.
		struct_foreach(_events, AddEvent);
	}
}