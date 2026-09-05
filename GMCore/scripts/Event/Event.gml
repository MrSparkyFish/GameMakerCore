//feather ignore all

//Generic event types. This list can be added to as needed, 
//but its generic default values shouldn't be changed
//Also, these are generic eventType descriptions, they can be interpreted 
//in which ever way is needed.
enum EventType {
	call,					//Notifies the that a callback/function was invoked
	change,					//Notifies that internal data was changed/modified
	signal,					//Notifies an event from an external application/notification
	time,					//Notifies the presence of a timed-out process
	error,					//Notifies the presence of an error 
	cancel,					//Notifies the premature termination of a process.
	done					//Notifies the termination of a process
}
 
/** Represents an abstract event.
 * @return {Struct.Event} */
function Event() constructor {
	
	///@ignore The name of this event.
	tag = undefined
	
	///@ignore The data for the event
	payload = undefined;
	
	///@ignore Optional variable to allow for varied event interpretation. 
	eventType = undefined;
	
	
	/** Returns the id of this `Event`
	 * @return {Struct.TagSpecifier} */
	static GetEventTag = function() {
		INLINE;
		return tag;
	}
	
	/** Set the tag that identifies this event
	 * @arg {Struct.TagSpecifier} tag The tag to set for this event.
	 * @return {Undefined} */
	static SetEventTag = function(tag) {
		INLINE;
		self.tag = tag;
	}
	
	/** Returns the payload set for this event. Returns `undefined` if no payload is available.
	 * @return {Any} */
	static GetEventPayload = function() {
		INLINE;
		return payload;
	}
	
	/** Set the payload of data this event carries
	 * @arg {Any} data The data to set
	 * @return {Undefined} */ 
	static SetEventPayload = function(data) {
		INLINE;
		payload = data;
	}
	
	/** Returns the event eventType. Returns `undefined` if no eventType is available. 
	 * @return {Constant.EventType} */
	static GetEventType = function() {
		INLINE;
		return eventType;
	}
	
	/** Set what kind of event is being represented. See `Enum.EventType` for more info
	 * @arg {Enum.EventType} type The eventType to set
	 * @return {Undefined} */
	static SetEventType = function(type) {
		INLINE;
		eventType = eventType
	}
}