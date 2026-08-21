//feather ignore all

#macro EVENT_TYPE_SPECIFIER_INTERNAL "internal"
#macro EVENT_TYPE_SPECIFIER_EXTERNAL "external"
#macro EVENT_TYPE_SPECIFIER_PLATFORM "platform"

/** Contains information about an event's execution process. Can be useful for debugging
 * @arg {String} eventId The Id or name of the event
 * @arg {Any} eventPayload The data the sender of the event chose to include with the event.
 * @arg {Enum.EventType} [eventType] The type of event that was raised if type is available
 * @arg {Constant.EVENT_TYPE_SPECIFIER*} [typeSpecifier] Additional specifier to indicate where the event is sourced from
 * @arg {String} [eventSourceId] The ID of the event sender if available
 * @arg {String} [externalOriginId] The ID of the external process the event came from if available.
 * @return {Struct.EventInfo} */
function EventInfo(eventId, eventPayload, eventType = undefined, typeSpecifier = undefined, eventSourceId = undefined, externalOriginId = undefined) constructor {
	
	///@ignore The name or Id of the event
	id = eventId;
	
	///@ignore The type of the event if available
	type = eventType;
	
	///@ignore The type specifier to provide further details about the source of this event.
	eventTypeSpecifier = typeSpecifier;
	
	///@ignore Whatever data the sending entity chose to include with the event
	payload = eventPayload;
	
	///@ignore Optional Id that tells us who the sender of the event is
	sourceId = eventSourceId;
	
	///@ignore Optional id that tells us what external process/service this event came from
	externalOrigin = externalOriginId;
	
	
	/** Returns the Id of the event that was sent.
	 * @return {String} */
	static GetEventId = function() {
		return id;
	}
	
	/** Returns the type of event that was raised or `undefined` if not available
	 * @return {Constant.EventType} */
	static GetEventType = function() {
		return type;
	}
	
	/** Returns the data the sender of the event included with it
	 * @return {Any} */
	static GetEventPayload = function() {
		return payload;
	}
	
	/** Returns the Id of the sender of this event or `undefined` if not available
	 * @return {String} */
	static GetEventSourceId = function() {
		return sourceId;
	}
	
	/** Returns the id of the external process/service where the event came from  or `undefined` if not available
	 * @return {String} */
	static GetEventExternalOriginId = function() {
		return externalOrigin;
	}
	
	/** Returns the type specifier of this event or `undefined` if not available
	 * @return {String} */
	static GetEventTypeSpecifier = function() {
		return eventTypeSpecifier;
	}
	
}