//feather ignore all
 
/** Interface for sending events to other objects
 * @return {Struct.IEventDispatcher} */
function IEventDispatcher() {
	
	/** Cancels an event that was previously sent via `SendEvent()`
	 * @arg {String} eventId The ID of the sent event to cancel
	 * @return {Undefined} */
	CancelEvent = function(eventId) {
		ThrowMethodNotImplemented("Cancel");
	}	
	
	/** Generates and sends a new event to a target, typically to an `IEventProcessor`.
	 * @arg {String} eventId The ID of the event being sent
	 * @arg {Any} payload The data to send with the event
	 * @arg {Enum.EventType} [type] The type of event being generated, if applicable.
	 * @return {Undefined} */
	SendEvent = function(eventId, payload, type = undefined) {
		ThrowMethodNotImplemented("Send");
	}
}