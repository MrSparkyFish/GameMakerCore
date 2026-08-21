//feather ignore all


/** Singleton object that manages automatic garbage collection for tracked dynamic resources and structures
 * @return {Struct.DynamicGarbageCollector} */
function DynamicGarbageCollector() constructor {
	
	///@ignore List of all the dynamic structures this collector is tracking
	trackedStructures = {};//array_create(GarbageGeneration.persist, []);
	
	///@ignore Total number of garbage in this collector
	garbageCount = 0;
	
	///@ignore Map of the number of times a DynamicStruct has been checked for deconstruction in its current age group keyed by its garbageId
	passoverCountMap = {};
	
	///@ignore Timer that executes GC. Set as a static var so that no matter how many of these structs are made, there can only ever be one time source
	static timeSource = time_source_create(time_source_global, DYNAMIC_GARBAGE_COLLECTION_PERIOD, time_source_units_frames, function() {
		INLINE;
		GarbageCollect();
	}, [], -1);
	
	/** Adds the specified dynamic structure to this garbage collector so it can be tracked and cleaned up automatically.
	 * @arg {Struct.DynamicStructure} structure The dynamic structure to add
	 * @return {Undefined} */
	static AddDynamicStructure = function(structure) {
		//Add the structure
		array_push(GetGeneration(GarbageGeneration.gen0), structure);
		garbageCount++;
		
		//Get its ID and add it to the passover map
		var garbageId = structure.GetGarbageId();
		passoverCountMap[$ garbageId] = 0;
		structure.garbageId = garbageId;
		
		//Make sure that collection is running
		GarbageCollectionStart();
	}
	
	/** Returns the array of tracked dynamic structs for the specified generation of garbage collection. Returns `undefined` if no array is found.
	 * Internal helper for type casting the return array.
	 * @ignore
	 * @arg {Real} generationIndex The index of the generation to return
	 * @return {Array<Struct.DynamicStructure>} */
	static GetGeneration = function(generationIndex) {
		INLINE;
		trackedStructures[$ generationIndex] ??= [];
		return trackedStructures[$ generationIndex];
	}
	
	/** Primary worker method. Makes a pass through the current generation of garbage collection and cleans up tracked dynamic resources
	 * @arg {Real} [gen] Optional generation to collect for manual collection.
	 * @return {Undefined} */
	static GarbageCollect = function(gen = undefined) {
		//Its possible for these variables to change over time so we can't cache them.
		var current = (MathIsBetweenEquals(gen, GarbageGeneration.gen0, GarbageGeneration.persist)) ? gen : gc_get_stats().generation_collected;
		var targetTime = gc_get_target_frame_time();
		var time = get_timer();
		
		//currentGen should only range from 0-3, but may be higher if GM changes in the future, so add safety checks 
		var generation = GetGeneration(current);
		
		//Iterate through all dynamic structs and check which ones need to be removed
		var len = array_length(generation) - 1;
		for (var i = len, count, garbage, gId; i >= 0; i--) {
			garbage = generation[i];
			gId = garbage.GetGarbageId();
			
			//If its dead, deconstruct it and remove it from the collector
			if (!garbage.IsAlive) {
				garbage.Destroy();
				array_delete(generation, i, 1);
				struct_remove(passoverCountMap, gId);
				garbageCount--;
			}
			//If its not dead, figure out if we should increase its age
			else {
				var handle = garbage.GetGarbageId();
				if (current != GarbageGeneration.persist) {
					
					//We can increase age so remove it from the current gen and add it to the next one
					if (passoverCountMap[$ gId] >= DYNAMIC_GARBAGE_AGE_THRESHOLD) {
						//Reset passover count
						passoverCountMap[$ gId] = 0;
						
						//Add to the next generation and remove from the current one
						array_push(GetGeneration(current + 1), garbage);
						array_delete(generation, i, 1);
					}
					//we cant increase age, so increase passover count and keep it in the current gen
					else {
						passoverCountMap[$ gId]++;
					}
				}
			}
			
			//Have we exceeded the amount of time allotted for collection?
			if ((get_timer() - time) >= targetTime) {
				break;
			}
		}
		
		//Turn off collection if there's no garbage left to collect
		if (garbageCount == 0) {
			GarbageCollectionStop();
		}
	}
	
	/** Start running garbage collection. GC can be stopped by calling `GarbageCollectionStop()`. 
	 * @return {Undefined} */
	static GarbageCollectionStart = function() {
		if (time_source_get_state(timeSource) == time_source_state_stopped) {
			time_source_start(timeSource);
		}
	}
	
	/** Prevent's this manager from running garbage collection until `GarbageCollectionStart()` is called.
	 * @return {Undefined} */
	static GarbageCollectionStop = function() {
		if (time_source_get_state(timeSource) == time_source_state_active) {
			time_source_stop(timeSource);
		}
	}
	
	/** Returns the number of dynamic structures being tracked by the collector
	 * @return {Real} */
	static GarbageCount = function() {
		return garbageCount;
	}
}




