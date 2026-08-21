//feather ignore all


/** Returns the singleton `DynamicGarbageCollector`
 * @return {Struct.DynamicGarbageCollector} */
function GC_Get() {
	static singleton = new DynamicGarbageCollector();
	return singleton;
}

/** Allows the garbage collector to invoke a callback when the indicated struct or instance is garbage collected. Most frequently used to track
 * dynamic resources to invoke its associated *_destroy function for automatic cleanup. 
 * ***
 * The provided `desctructor` function must **not** be bound to the `resourceOwner`. The function being bound to the resource owner means
 * there will always be an active reference to it. Therefore the owner can never be garbage collected and this function will never be called.
 * It will be called using the `dynamicResource` as its only parameter. If additional parameters are required, you'll need to configure
 * wrapper functions accordingly. Lastly, the provided `destructor` function is invoked **after** the `resourceOwner` is garbage collected
 * unless `resourceOwner` is `undefined` or `noone` in which case it will be invoked the next time the garbage collector collects generation 0.
 * @arg {Id.Handle} dynamicResource The handle of the dynamic resource that you want to track for automatic garbage collection. Can be set to `undefined` to simply invoke a callback when the resourceOwner is garbage collected
 * @arg {Struct|Id.Instance} resourceOwner The owner of the dynamic resource if the `dynamicResource` is for an **instance** or **global** scope variable. Set to an empty struct literal if `dynamicResource` is for a **local** variable.
 * @arg {Function} destructor The function to invoke that will clean up the dynamic resource.
 * @arg {Array<Any>} [args] Optional array of prebaked data that should be passed to the destructor after `dynamicResource`.
 * @return {Id.Handle} */
function GC_Track(dynamicResource, resourceOwner, destructor, args = undefined) {
	var dynamicStruct = new DynamicStructure(dynamicResource, resourceOwner, destructor, args);
	GC_Get().AddDynamicStructure(dynamicStruct); 
	return dynamicResource;
}

/** Allows you to manually trigger a garbage collection.
 * @arg {Enum.GarbageGeneration} generation The generation to collect
 * @return {Undefined} */
function GC_CollectGarbage(generation) {
	GC_Get().GarbageCollect(generation);
}

/** Returns the total count of how many resources are currently being tracked by the garbage collector (does not include items tracked by GM's garbage collector)
 * @return {Real} */
function GC_GetCollectionCount() {
	return GC_Get().GarbageCount();
}

#region GC Data Structures
	
	/** Creates a DsMap that is automatically tracked for garbage collection
	 * @arg {Bool} [temp] `[=false]` Set `true` to create the DsMap as a temporary local variable.
	 * @return {Id.DsMap} */
	function GC_DsMap(temp = false) {
		var value = ds_map_create();
		var context = (temp) ? {} : self;
		GC_Track(value, context, ds_map_destroy);
		return value;
	}
	
	/** Creates a DsList that is automatically tracked for garbage collection
	 * @arg {Bool} [temp] `[=false]` Set `true` to create the DsList as a temporary local variable.
	 * @return {Id.DsList} */
	function GC_DsList(temp = false) {
		var value = ds_list_create();
		var context = (temp) ? {} : self;
		GC_Track(value, context, ds_list_destroy);
		return value;
	}
	
	/** Creates a DsQueue that is automatically tracked for garbage collection
	 * @arg {Bool} [temp] `[=false]` Set `true` to create the DsQueue as a temporary local variable.
	 * @return {Id.DsQueue} */
	function GC_DsQueue(temp = false) {
		var value = ds_queue_create();
		var context = (temp) ? {} : self;
		GC_Track(value, context, ds_queue_destroy);
		return value;
	}
	
	/** Creates a DsPriority that is automatically tracked for garbage collection
	 * @arg {Bool} [temp] `[=false]` Set `true` to create the DsPriority as a temporary local variable.
	 * @return {Id.DsPriority} */
	function GC_DsPriority(temp = false) {
		var value = ds_priority_create();
		var context = (temp) ? {} : self;
		GC_Track(value, context, ds_priority_destroy);
		return value;
	}
	
	/** Creates a DsStack that is automatically tracked for garbage collection
	 * @arg {Bool} [temp] `[=false]` Set `true` to create the DsStack as a temporary local variable.
	 * @return {Id.DsStack} */
	function GC_DsStack(temp = false) {
		var value = ds_stack_create();
		var context = (temp) ? {} : self;
		GC_Track(value, context, ds_stack_destroy);
		return value;
	}
	
	/** Creates a DsGrid that is automatically tracked for garbage collection
	 * @arg {Bool} [temp] `[=false]` Set `true` to create the DsGrid as a temporary local variable.
	 * @return {Id.DsGrid} */
	function GC_DsGrid(temp = false) {
		var value = ds_priority_create();
		var context = (temp) ? {} : self;
		GC_Track(value, context, ds_grid_destroy);
		return value;
	}
	
	/** Creates a TimeSource that is tracked for automatic garbage collection.
	 * @arg {Id.TimeSource|Constant.TimeSource} parent The parent time source that controls this one. Can be `time_source_global`, `time_source_game`, or a previously created time source.
	 * @arg {Real} period How long the timer will last for
	 * @arg {Function} callback The callback function to invoke when the timer expires
	 * @arg {Array<Any>} [callbackArgs] `[=[]]` Optional array of arguments to pass to the callback when the function expires
	 * @arg {Real} [reps] `[=1]` The number of times the timer will repeat. Specify `-1` to make the timer repeat infinitely.
	 * @arg {Constant.TimeSourceExpiryType} [expiryType] `[=time_source_expire_after]` Determines on which frame the time source will invoke the callback.
	 * @arg {Bool} [temp] `[=false]` Set `true` if the TimeSource is being created as a temporary local variable
	 * @return {Id.TimeSource} */
	function GC_TimeSource(parent, period, units, callback, callbackArgs = [], reps = 1, expiryType = time_source_expire_after, temp = false) {
		var value = time_source_create(parent, period, units, callback, callbackArgs, reps, expiryType);
		var context = (temp) ? {} : self;
		GC_Track(value, context, function(timer) {
			time_source_stop(timer);
			time_source_destroy(timer);
		});
		return value;
	}
	
#endregion


