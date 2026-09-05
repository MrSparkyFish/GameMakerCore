//feather ignore all
 
/** InitialState: A pseudo-state that encapsulates a transition that should be taken immediately after it's parent state is entered. The encapsulated 
 * transition should NOT include executable content.
 * @return {Struct.InitialState} */
function InitialState() constructor {
	
	///@ignore Conditionless transition that will always be taken as soon as the state is entered
	transition = undefined;				
	
	///@ignore Owner of this initial
	parent = undefined;
	
	///@ignore Indicates if this initial was auto created from a state ref
	generated = false;
	
	/** Returns the state that owns this `InitialState`
	 * @return {Struct.State} */
	static GetParent = function() {
		return parent;
	}
	
	/** Sets the parent owner of this `InitialState` and updates the transition's source state (if one is defined).
	 * @arg {Struct.State} _parent The state to set as the owning state
	 * @return {Undefined} */
	static SetParent = function(_parent) {
		parent = _parent;
		if (!is_undefined(transition)) {
			transition.SetParent(parent);
		}
	}
	
	/** Returns the initial transition held by this initial state indicator. Returns `undefined` if one hasn't been set yet.
	 * @return {Struct.SimpleTransition} */
	static GetTransition = function() {
		return transition;
	}
	
	/** Set the initial transition. The source state of the transition is automatically updated.
	 * @arg {Struct.SimpleTransition} _transition The transition to set.
	 * @return {Undefined} */
	static SetTransition = function(_transition) {
		transition = _transition;
		transition.SetParent(GetParent());
	}
	
	/** Returns `true` if this initial was auto generated from a state ref rather than specified directly
	 * @return {Bool} */
	static IsGenerated = function() {
		return generated;
	}
	
	/** Marks this initial as being auto genereated
	 * @return {Undefined} */
	static SetGenerated = function() {
		generated = true;
	}
}