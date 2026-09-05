//feather ignore all

/** SimpleTransition: Represents the simplest form of transition. A `SimpleTransition` will always attempt to execute whenever its parent state is 
 * entered.
 * ***
 * Implements: `IObserveable`
 * @arg {Any} _targetId The ID of the target of this transition.
 * @return {Struct.SimpleTransition} */
function SimpleTransition(_targetId = undefined) constructor {
	
	//Transition types determines whether the source state is exited in transitions whose target state is a descendant of the source
	enum State_TransitionType {
		external,							//Source state is exited
		internal 							//Source state is not exited
	}
	
	///@ignore The id we use for subbing to state 
	observableId = undefined;
	
	///@ignore Determines how to handle source states
	type = State_TransitionType.external;
	
	///@ignore Holds a ref to the `TransitionalState` domain of this transition
	transitionDomain = undefined;
	
	///@ignore Flag that tells us if the above transitionDomain is undefined because it was the 
	/// state machine itself (to distinguish from the inital value)
	machineTransitionDomain = false;
	
	///@ignore Derived effective transition type.
	typeInternal = undefined;
	
	///@ignore Optional property that specified the new states or parallels to transition to. If multiple states
	/// are specified then they must all belong to the regions of the same parallel. Additionally, each target
	/// must be a unique target.
	targets = [];
	
	///@ignore The state owning this transition
	parent = undefined;
	
	///@ignore The callback method that will be executed when this transition is taken
	onTransition = new Action();
	
	///@ignore The next transition target ID
	next = _targetId;
	
	/** Check if the specified state is a compound state. Used internally only.
	 * @ignore
	 * @arg {Struct.TransitionalState} _transitionalState The state to check
	 * @return {Undefined} */
	static IsCompoundStateParent = function(_transitionalState) {
		var _state = _transitionalState;
		return ((!is_undefined(_transitionalState)) && StateIsState(_state) && _state.IsCompoundState());
	}
	
	/** Returns the action delegate that is invoked when this transition is taken. You can use this delegate to add bind a callback and callback data to this transition.
	 * @return {Struct.Action} */
	static GetOnTransition = function() {
		return onTransition;
	}
	
	/** Returns the id of this observable
	 * @return {Real} */
	static GetObservableId = function() {
		return observableId;
	}
	
	/** Set the observable id for this observable. Mulst be unique within the state machine
	 * @arg {Real} _id The id to set.
	 * @return {Undefined} */
	static SetObservableId = function(_id) {
		observableId = _id;
	} 
	
	/** Returns the parent (source) state of this transition.
	 * @return {Struct.TransitionalState} */
	static GetParent = function() {
		return parent;
	}
	
	/** Set the parent (source) state for this transition.
	 * @arg {Struct.TransitionalState} _parent The parent to set
	 * @return {Undefined} */
	static SetParent = function(_parent) {
		parent = _parent;
	}
	
	/** Returns `true` if the type if this transition is `internal` or `false` if the transition is external
	 * @return {Bool} */
	static GetType = function() {
		return type;
	}
	
	/** Set the type of this transition
	 * @arg {Enum.State_TransitionType} _type The type to set
	 * @return {Undefined} */
	static SetType = function(_type) {
		type = _type;
	}
	
	/** Returns `true` if the evaluated type of this transition is "internal". A transition is only evaluated as internal if:
	 * * Its specific type is `internal` AND
	 * * Its source state is compound AND
	 * * All of its target states are proper descendants of its source
	 * @return {Bool} */
	static IsTypeInternal = function() {
		if (is_undefined(typeInternal)) {
			
			//Checking first two required conditions
			var _sourceState = GetParent();
			typeInternal = ((State_TransitionType.internal == type) && IsCompoundStateParent(_sourceState));
			
			//If we're internal, verify all our target states are descendants of our source state
			var _len = array_length(targets);
			if (typeInternal && (_len > 0)) {
				var _targets = GetTargets();
				for (var i = 0; i < _len; i++) {
					
					//If at least one target isn't a descendant, then we can't be an internal transition. 
					if (!targets[i].IsDescendantOf(_sourceState)) {
						typeInternal = false;
						break;
					}
				}
			}
		}
		return typeInternal;
	}
	
	/** Returns the domain of this transition. If this transition is target-less OR if its domain is the state machine itself, `undefined` will be returned.
	 * As such, this method is only useful when this transition has targets. 
	 * ***
	 * If this transition does have targets, then the domain is the compound state in which:
	 * * All states exited or entered by this transition are descendants of it
	 * * No descendant of it has this property
	 * ***
	 * If No such compound state parent exists that fulfills the above conditions, then the domain effectively becomes the state machine itself which is 
	 * not of type `TransitionalState` (causing the `undefined` return described above).
	 * @return {Struct.TransitionalState} */
	static GetTransitionDomain = function() {
		//Check if we need to re-find the domain.
		var _tDomain = transitionDomain;
		if (is_undefined(_tDomain) && (array_length(targets) > 0) && (!machineTransitionDomain)) {
			//Finding the transition domain.
			var _parent = GetParent();
			if (!is_undefined(_parent)) {
				//If we're internal, then the domain is just our source
				if (IsTypeInternal()) {
					transitionDomain = _parent;
				}
				//Otherwise find the Least Common Compound Ancestor (LCCA)
				else {
					var _numAncestor = _parent.GetNumberOfAncestors();
					var _ancestor;
					
					//Check each target to see if its a descendant of my source or any any of my sources ancestors
					//The last entry of my ancestors is my immediate source, checking in reverse is more likely to find a match sooner
					for (var i = _numAncestor - 1; i >= 0; i--) {
						//Get the current iteration state's ancestor
						_ancestor = _parent.GetAncestor(i);
						
						//LCCA must be compound
						if (IsCompoundStateParent(_ancestor)) {
							//Assume all my targets are descendants of this ancestor
							var _allDescendants = true;
							
							var _tTarget, _getNumAncestors, _count;
							var _numTarg = GetNumberOfTargets();
							for (var j = 0; j < _numTarg; j++) {
								//Get the current iteration target and number of target ancestors
								_tTarget = GetTarget(j);
								_count = _tTarget.GetNumberOfAncestors();
								
								//Check conditions that determine if the current target is a descendant of the current ancestor
								if (i >= _count) {
									i = _count;
									_allDescendants = false;
									break;
								}
								if (_tTarget.GetAncestor(i) != _ancestor) {
									_allDescendants = false;
									break;
								}
							}
							
							//Update the domain
							if (_allDescendants) {
								transitionDomain = _ancestor;
							}
							
						}
						
					}
				}
				
				//update our return value then update the flag if domain is at the state machine level
				_tDomain = transitionDomain;
				if (is_undefined(_tDomain)) {
					machineTransitionDomain = true;
				}
			}
		}
		return _tDomain;
	}
	
	/** Returns all targeted `TransitionTargets`
	 * @return {Array<Struct.TransitionTarget>} */
	static GetTargets = function() {
		return targets;
	}
	
	/** Returns the target at the specified index.
	 * @arg {Real} _index The index of the target to get
	 * @return {Struct.TransitionTarget} */
	static GetTarget = function(_index) {
		return targets[_index];
	}
	
	/** Returns the number of targets targeted by this transition
	 * @return {Real} */
	static GetNumberOfTargets = function() {
		return array_length(targets);
	} 
	
	/** Returns the ID of the `TransitionTarget` explicity targeted by this transition
	 * @return {Any} */
	static GetNext = function() {
		return next;
	}
	
	/** Set the `TransitionTarget` that this transition should explicity target.
	 * @arg {Any} _id The ID of the target to set
	 * @return {Undefined} */
	static SetNext = function(_id) {
		next = _id;
	}
}
