//feather ignore all
 
/** Abstract class that acts as the bridge between GMObjects and Struct objects
 * @arg {Id.Instance} instance The id of the instance this context represents.
 * @return {Struct.ObjectContext} */
function ObjectContext(instance) constructor {
	
	/// The Specific Id.Instance that physically represents this context.
	gmInstanceId = instance;
	
	///@ignore Callbacks for when we change the ID of this context.
	onInstanceIdChanged = new ObjectContextInstanceChangedDelegate();
	
	/** Returns `true` if the GM instance assigned to this context still exists within the room.
	 * @return {Bool} */
	static IsValid = function() {
		return instance_exists(gmInstanceId);
	}
	
	/** Returns the `id` of this instance
	 * @return {Id.Instance} */
	static GetInstanceId = function() {
		INLINE;
		return gmInstanceId;
	}
	
	/** Set the instance id of the GMObject assigned to this context.
	 * @return {Undefined} */
	static SetInstanceId = function(instance) {
		INLINE;
		var oldId = gmInstanceId;
		gmInstanceId = instance;
		GetOnInstanceIdChanged().Broadcast(oldId, instance);
	}
	
	/** Returns the callback multicast action that is invoked whenever the GMObject instance assigned to this context is changed
	 * @return {Struct.ObjectContextInstanceChangedDelegate} */
	static GetOnInstanceIdChanged = function() {
		INLINE;
		return onInstanceIdChanged;
	}
}