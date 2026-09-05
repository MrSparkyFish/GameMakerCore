//feather ignore all

/** StateTransition: Represents the rules and logic that are triggered by events in the system.
 * ***
 * Implements: `IPublisher`, `ISortable`
 * Inherits: `SimpleTransition`
 * @arg {Any} _targetId The ID of the target of this transition.
 * @return {Struct.StateTransition} */
function StateTransition(_targetId) : SimpleTransition(_targetId) constructor {
	
	///@ignore The document order of this transition
	order = undefined;
	
	///@ignore The string representing the events that can trigger this transition. 
	/// A transition that does not specify an event indicates an initial transition which is taken immediately upon entering the source state
	/// All `SimpleTransitions` act this way.
	event = undefined;
	
	///@ignore Optional condition callback that, when provided, must return true in order for this transition to fire
	condition = undefined;
	
	///@ignore Indicates if this transition is wild (matches all events).
	wild = false;
	
	
	/** Returns the element order for this `ISortable`
	 * @return {Real} */
	static GetElementOrder = function() {
		INLINE;
		return order;
	}
	
	/** Set the order for this `ISortable`
	 * @arg {Real} _order The order of this element
	 * @return {Undefined} */
	static SetElementOrder = function(_order) {
		INLINE;
		order = _order;
	}
	
	/** Returns `true` if this transition has no guard condition or if its assigned guard condition evaluates to `true`
	 * @return {Bool} */
	static CheckCondition = function() {
		INLINE;
		return (!is_callable(condition)) ? true : condition();
	}
	
	/** Set the guard condition of this transition
	 * @arg {Function} _condition The boolean callback to set
	 * @return {Undefined} */
	static SetCondition = function(_condition) {
		condition = _condition;
	}
	
	/** Returns the string representing the event that triggers this transition. Returns `undefined` if this transition is eventless or `STATE_WILD_TRANSITION_NAME` if this event is wild.
	 * @return {String} */
	static GetEvent = function() {
		INLINE;
		return event;
	}
	
	/** Set the string that represents the event that triggers this transition.
	 * @arg {String} _event The event that can trigger this transition. Set `undefined` to make this transition eventless or set `STATE_WILD_TRANSITION_NAME` to make this transition wild.
	 * @return {Undefined} */
	static SetEvent = function(_event) {
		INLINE;
		event = _event;
	}
	
	/** Returns `true` if this transition is an eventless (automatic) transition. An eventless transition will attempt to trigger every frame.
	 * @return {Bool} */
	static IsEventless = function() {
		return (is_undefined(event));
	}
	
	/** Returns `true` if this transition is a wild transition. A wild transition will trigger against any event and is useful for catching unhandled events.
	 * @return {Bool} */
	static IsWild = function() {
		return (event == STATE_WILD_TRANSITION_NAME);
	}
	
	/** Returns `true` if this transition can be triggered by the specified event struct.
	 * ***
	 * When an event triggers a transition, the tag for the triggering event is matched against all event tags assigned to this transition including parent 
	 * tags. For example; if this transition is triggered by the tag `"Event.Lightswitch.Flick"` and the triggering event `"Event.Lightswitch"` then this 
	 * transition could potentially be triggered. But if it were the other way around and this transition only has the tag `"Event.Lighswitch"` and the 
	 * triggering event tag is `"Event.Lightswitch.Flick"` then this transition could not be triggered since the triggering event tag doesn't exist in this 
	 * transition or in the ancestry of the transition's tags.
	 * @arg {Struct.Event} [_event] The event to check if any.
	 * @return {Bool} */
	static IsTriggeredByEvent = function(_event = undefined) {
		var _eventless = IsEventless();
		
		
		//An event tag was provided so check if we are triggered by it
		if (!is_undefined(_event)) {
			
			//We arent eventless or wild, so actually check for a tag match
			if (!(_eventless || IsWild())) {
				//Check the tags
				var _eventTag = _event.GetEventTag();
				return (_eventTag.MatchesTag(Tag_RequestTag(event)));
			}
			
			//If we are eventless then we should only match when no event is provided.
			else if (_eventless) {
				return false;
			} 
		}
		
		//If an event wasn't provided then we only match if we are an eventless transition.
		else {
			return _eventless;
		}
	}
	
	/** Returns `true` if this transition can be triggered by the specified event AND passes its guard condition.
	 * @arg {Struct.Event} _event The event we must check against.
	 * @return {Undefined} */
	static IsEnabled = function(_event) {
		//If the event isn't a triggering event return false, otherwise return if our condition is enabled.
		return (IsTriggeredByEvent(_event) && CheckCondition());
	}
}