//feather ignore all
 
// How frequently the collector will check dynamic structs for deconstruction where 1 = every frame, 2 = every other frame, etc.
#macro DYNAMIC_GARBAGE_COLLECTION_PERIOD 1

// The number of times a dynamic structure will be checked before increasing its age
#macro DYNAMIC_GARBAGE_AGE_THRESHOLD 5

// If true `DynamicResource` will perform saftey checks during its construction. Set to `false` for a slight performance boost.
#macro DYNAMIC_GARBAGE_SAFETY_CHECKS true

/// Represents the number of available garbage generations. Can be expanded to fit needs so long as the enum value never exceeds .persist
enum GarbageGeneration {
	gen0,
	gen1, 
	gen2,
	gen3,
	persist		//Indicates the max index in trackedStructures. This generation is never garbage collected and only exists so the number of generations can be expanded
}