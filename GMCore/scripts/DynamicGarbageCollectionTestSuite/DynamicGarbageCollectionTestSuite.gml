//feather ignore all
 
/** Unit tests for the `DynamicGarbageCollection` sub-module
 * @return {Struct.DynamicGarbageCollectionTestSuite} */
function DynamicGarbageCollectionTestSuite() : TestSuite() constructor {
	
	theory = [
		[GC_DsMap(true), ds_type_map],
		[GC_DsList(true, ds_type_list)],
		[GC_DsQueue(true), ds_type_queue],
		[GC_DsPriority(true), ds_type_priority],
		[GC_DsStack(true), ds_type_stack],
		[GC_DsGrid(true), ds_type_grid]
	]
	
	#region API Function Tests
		
		AddFact("GC_Track", function() {
			var map = ds_map_create();
			var val = GC_Track(map, {}, ds_map_destroy);
			AssertEquals(val, map, "Tracking a resource should return the tracked resources handle");
		});
		
		AddTheory("GC Collects Resources", theory, function(resource, type) {
			var exists = ds_exists(resource, type);
			AssertIsFalse(exists, "The created dynamic structure was not properly destroyed by the DynamicGarbageCollector")
		})
		
	#endregion
	
	
}