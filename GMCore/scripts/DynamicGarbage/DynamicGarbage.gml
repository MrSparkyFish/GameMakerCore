//feather ignore all
 
/** A wrapper struct used by the dynamic garbage collector for automatic cleanup of dynamic resources. Must be added to the `DynamicGarbageCollector` 
 * in order to be tracked.
 * ***
 * Note: The provided `desctructor` function must **not** be bound to the `resourceOwner`. Being bound to the resource owner means
 * there will always be an active reference. Therefore the owner can never be garbage collected and this function will never be called.
 * It will be called using the `dynamicResource` as its only parameter. If additional parameters are required, you'll need to configure
 * wrapper functions accordingly. Lastly, the provided `destructor` function is invoked **after** the `resourceOwner` is garbage collected
 * unless `resourceOwner` is `undefined` or `noone` in which case it will be invoked the next time the garbage collector collects generation 0.
 * @arg {Id.Handle} dynamicResource The handle ID of the dynamic resource that you want to track for automatic garbage collection, ie: `(Id.DsMap, Id.DsList, Id.TimeSource, etc)`
 * @arg {Struct|Id.Instance} resourceOwner The owner of the dynamic resource if the dynamicResource is for an instance or global variable. Set to an empty struct literal if `dynamicResource` is for a local variable.
 * @arg {Function} destructor The function to invoke that will clean up the dynamic resource. The destructor **must** accept the `dynamicResource` as its first argument
 * @arg {Array<Any>} [args] `[=undefined]` Optional array of additional arguments to pass to the destructor
 * @return {Struct.DynamicGarbage} */
function DynamicGarbage(dynamicResource, resourceOwner, destructor, args = undefined) constructor {
	
	///@ignore Count for generating Id's
	static dynamicStructureCount = 0;
	
	///@ignore Generate a new garbage ID for this dynamic data
	garbageId = $"DynamicStructure_{dynamicStructureCount++}";
	
	///@ignore Reference to the item that needs to be destructed by the collector
	handle = dynamicResource;
	
	///@ignore Weak ref to track when the owner of this dynamic resource is removed
	weakRef = weak_ref_create(resourceOwner);	
	
	///@ignore The deconstruct action to execute 
	deconstruct = new Action();
	deconstruct.Bind(destructor, args);
	
	///@ignore Flag to prevent doubling up on destructing
	destroyed = false;
	
	/** Returns `true` if this dynamic struct is tracking the specified resource
	 * @arg {Id.Handle} handle The ref of the resource to check
	 * @return {Bool} */
	static IsTrackingReference = function(handle) {
		return (self.handle == handle);
	}
	
	/** Returns the ID of this DynamicStruct.
	 * @return {String} */
	static GetGarbageId = function() {
		INLINE;
		return garbageId;
	}
	
	/** Returns `true` if the resource owner of this dynamic struct is still alive
	 * @return {Bool} */
	static IsAlive = function() {
		INLINE;
		return (weak_ref_alive(weakRef));
	}
	
	/** Invokes the destructor to free memory
	 * @return {Undefined} */
	static Destroy = function() {
		if (!destroyed) {
			//Try to deconstruct the resource (it may have already been deconstructed externally)
			try {
				deconstruct.Execute(handle);
			}
			destroyed = true;
		}
	}
	
	//Safety checks
	if (DYNAMIC_GARBAGE_SAFETY_CHECKS) {
		//Handle cannot be the same as the owner
		if (resourceOwner == dynamicResource) {
			ThrowInvalidData("DynamicGarbage", $"Supplied dynamic data cannot be the same as the supplied data owner.");
		}
		
		//Destructor function MUST be provided
		if (!is_callable(destructor)) {
			ThrowException("Memory Leak Detected!", $"Destructor is missing for dynamic structure {garbageId}");
		}
		
		//Desctructor cannot be bound to the resource owner
		if (method_get_self(destructor) == resourceOwner) {
			ThrowException("Memory Leak Detected!", $"Destructor provided to dynamic structure {garbageId} cannot be bound to the resource owner.");
		}			
	}
}