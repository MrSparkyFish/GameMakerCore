//Feather ignore all

/** StateChart: Represents a series of states and transitions that define stateful behavior. Responsible for facilitating events and transitions. 
 * ***
 * Implements: `IPublisher`
 * @arg {Any} _initial The ID of the initial starting state of this machine
 * @return {Struct.StateChart} */
function StateChart(_initial = undefined) constructor {
	
	
	///@ignore The publisher id of this chart
	publisherId = undefined;
	
	///@ignore Optional name of this machine. 
	name = undefined;
	
	///@ignore Map of `TransitionTargets` keyed by their ID's
	targets = {};												
	
	///@ignore Transitions the machine to its initial starting state when registered to an SSC. Setup by the StateSystem
	initialTransition = undefined;
	
	///@ignore The ID of the initial state of this machine.
	initial = _initial;
	
	///@ignore The callback that will be invoked when this chart is initialized to a machine for event execution
	onInitialized = new Action();		
	
	///@ignore The list of immediate children of this machine.
	children = [];
	
	
	/** Returns the ID of this publisher. If not set, a new one is randomly generated and assigned before returning.
	 * @return {String} */
	static GetPublisherId = function() {
		publisherId ??= PubSubGeneratePublisherID();
		return publisherId;
	}
	
	/** Set a new publisher ID for this `IPublisher`
	 * @arg {String} _id The id to set
	 * @return {Undefined} */
	static SetPublisherId = function(_id) {
		publisherId = _id; 
	}
	
	/** Returns the list of immediate children of this machine.
	 * @return {Array<Struct.EnterableState>} */
	static GetChildren = function() {
		return children;
	}
	
	/** Add an enterable state as a child of this machine.
	 * @ignore
	 * @arg {Struct.EnterableState} _child The state to add
	 * @return {Undefined} */
	static AddChild = function(_child) {
		array_push(children, _child);
	}
	
	/** Returns the name of this `StateChart`. The default name is the name of the constructor it was created from.
	 * @return {String} */
	static GetName = function() {
		return name;
	}
	
	/** Set a new name for this `StateChart`.
	 * @arg {String} _name The new name to set
	 * @return {Undefined} */
	static SetName = function(_name) {
		name = _name;
	}
	
	/** Returns the specified `TransitionTarget` or `undefined` if the specified target doesn't exist.
	 * @arg {Any} _targetId The id of the target to return
	 * @return {Struct.TransitionTarget} */
	static GetTarget = function(_targetId) {
		return targets[$ _targetId];
	}
	
	/** Add a `TransitionTarget` to this `StateChart`
	 * @ignore
	 * @arg {Struct.TransitionTarget} _target The target to add
	 * @arg {Bool} [_isMachineRoot] `[= false]` Set to `true` if `_target` is an uppermost root level state.
	 * @return {Undefined} */
	static AddTarget = function(_target, _isMachineRoot = false) {
		targets[$ _target.GetId()] = _target;
		
		//If this is a top-level target, it needs to be added as a child of the machine.
		if (_isMachineRoot && StateIsEnterable(_target)) {
			AddChild(_target);
		}
	}
	
	/** Add a new state element to this machine. Convenience method to avoid automatic typecasting.
	 * @arg {Struct.State} _state The state to add to this machine.
	 * @arg {Bool} [_isMachineRoot] `[= false]` Set to `true` if `_target` is an uppermost root level state.
	 * @return {Struct.State} */
	static AddState = function(_state, _isMachineRoot = false) {
		AddTarget(_state, _isMachineRoot);
		return _state;
	}
	
	/** Add a new parallel element to this machine. Convenience method to avoid automatic typecasting.
	 * @arg {Struct.ParallelState} _state The parallel state to add
	 * @arg {Bool} [_isMachineRoot] Should be set to `true` if `_target` is an uppermost root level state.
	 * @return {Struct.ParallelState} */
	static AddParallel = function(_state, _isMachineRoot = false) {
		AddTarget(_state, _isMachineRoot);
		return _state;
	}
	
	/** Add a new final element to this machine. Convenience method to avoid automatic typecasting.
	 * @arg {Struct.FinalState} _state The final state to add
	 * @return {Struct.FinalState} */
	static AddFinal = function(_state) {
		AddTarget(_state);//Final can never be a root
		return _state;
	}		
	
	/** Define a new history element for this machine or existing transitional state. Convenience method to avoid automatic typecasting.
	 * @arg {Struct.HistoryState} _state The id to assign to the history state. Must be unique to this machine!
	 * @return {Struct.HistoryState} */
	static AddHistory = function(_state) {
		AddTarget(_state);//history can never be a root.
		return _state;
	}
	
	/** Returns the id of this machines initial transition target
	 * @return {Any} */
	static GetInitial = function() {
		return initial;
	}
	
	/** Set the starting state of this machine to the target with the specified id.
	 * @arg {Any} _initial The id of the state that is the initial starting state of the machine.
	 * @return {Undefined} */
	static SetInitial = function(_initial) {
		initial = _initial;
	}
	
	/** Returns the initial transition for this `StateChart`. Returns `undefined` if one hasn't been set yet.
	 * @return {Struct.SimpleTransition} */
	static GetInitialTransition = function() {
		return initialTransition;
	}
	
	/** Set the initial transition for this `StateChart` which will transition the machine into its starting state.
	 * @arg {Struct.SimpleTransition} _transition */
	static SetInitialTransition = function(_transition) {
		initialTransition = _transition;
	}
	
	/** Returns the `Action` delegate that will be executed when this `StateChart` is assigned to an instance of `StateSystemComponent`. The `Action` is executed
	* after the machine assigned but before transitioning to it's initial state.
	 * @return {Struct.Action} */
	static GetOnInitialized = function() {
		return onInitialized;
	}
	
	/** Returns the first child of this machine or `undefined` if no children exist.
	 * @return {Struct.EnterableState} */
	static GetFirstChild = function() {
		return array_first(children);
	}
}













