//feather ignore all
 
/** IEventProcessor: Defines the interface for establishing event processes.
 * @return {Struct.IEventProcessor} */
function IEventProcessor() {
	
	/** Adds an event to this processor
	 * @arg {Struct.Event} event The event to add
	 * @return {Undefined} */ 
	AddEvent = function(event) {
		ThrowMethodNotImplemented("AddEvent", self);
	}
}