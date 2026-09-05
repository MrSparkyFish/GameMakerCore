//feather ignore all
 
/** TransitionTarget: An abstract base class that can serve as a target of a `StateTransition` such as a `State` or `Parallel`
 * ***
 * Implements: `IPublisher`
 * @arg {Any} [_id] The ID that should be assigned to this `TransitionTarget`
 * @return {Struct.TransitionTarget} */
function TransitionTarget(_id = undefined) constructor {
	
	///@ignore The id that is unique to the `StateChart`
	observableId = undefined;
	
	///@ignore The identifier for this transition target used by other parts of the system.
	id = _id;					
	
	///@ignore Immediate parent of this state. May be undefined if the parent is the state machine root
	parent = undefined;		
	
	///@ignore Array of `EnterableStates` that are my ancestors.
	ancestors = [];	
	
	
	/** Returns the observable ID of this `TransitionTarget`.
	 * @return {Real} */
	static GetPublisherId = function() {
		return observableId;
	}
	
	/** Set the unique observable ID for this `TransitionTarget`. 
	 * @arg {Real} _id The `PubSub` to set.
	 * @return {Undefined} */
	static SetPublisherId = function(_id) {
		observableId = _id;
	}
	
	/** Get the ID of this transition target. May be `undefined`
	 * @return {Any} */
	static GetId = function() {
		return id;
	}
	
	/** Set the ID for this transition target.
	 * @arg {Any} _id The ID to assign
	 * @return {Undefined} */
	static SetId = function(_id) {
		id = _id;
	}
	
	/** Returns how many ancestors this `TransitionTarget` has
	 * @return {Real} */
	static GetNumberOfAncestors = function() {
		return array_length(ancestors);
	}
	
	/** Returns the ancestor held at the specified index
	 * @arg {Real} _index The ancestor to get
	 * @return {Struct.EnterableState} */
	static GetAncestor = function(_index) {
		return ancestors[_index];
	}
	
	/** Return the parent `EnterableState`. May be `undefined` if this target is at the `StateChart` level
	 * @return {Struct.EnterableState} */
	static GetParent = function() {
		return parent;
	}
	
	/** Returns `true` if this target is a root target (at the `StateChart` level)
	 * @return {Bool} */
	static IsRoot = function() {
		return is_undefined(GetParent());
	}
	
	/** Set the parent of this `TransitionTarget` 
	 * @arg {Struct.EnterableState} _newParent The parent to set
	 * @return {Undefined} */
	static SetParent = function(_newParent) {
		if (is_undefined(_newParent)) {
			ThrowInvalidType("SetParent", "_newParent", _newParent, "EnterableState");
		}
		
		if (_newParent == self) {
			StateError("SetParent", "Cannot set parent to self", self);
		}
		
		//Update the parent only if its new otherwise we're wasting time.
		if (parent != _newParent) {
			parent = _newParent;
			
			//Update my ancestor hierarchy to fit our new parent.
			UpdateDescendantAncestors();
		}
	}
	
	/** Updates the ancestors for all the descendants of this `TransitionTarget`
	 * @return {Undefined} */
	static UpdateDescendantAncestors = function() {
		//Copy my parent's hierarchy into my hierarchy then add our new parent. 
		//Faster to use clone over array_copy in this case since we need a shallow copy of the whole array
		var _parentAncestors = (!is_undefined(parent)) ? parent.ancestors : [];
		ancestors = variable_clone(_parentAncestors, 0);
		array_push(ancestors, parent);
	}
	
	/** Returns `true` if the calling `TransitionTarget` is a descendant of the specified parent.
	 * @arg {Struct.TransitionTarget} _parent The `TransitionTarget` to check as the parent
	 * @return {Bool} */
	static IsDescendantOf = function(_parent) {
		var _myNum = GetNumberOfAncestors();
		var _parentNum = _parent.GetNumberOfAncestors();
		return ((_myNum > _parentNum) && (GetAncestor(_parentNum) == parent));
	}
}