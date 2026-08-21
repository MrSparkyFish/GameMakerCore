//feather ignore all

/** Helper struct used to combine tags from different sources without modifying the original containers
 * @return {Struct.TagContainerAggregator} */
function TagContainerAggregator() constructor {
	///@ignore Tags that we captured from our owner and that we want to combine with something else without modifying the container.
	capturedSourceTags = new TagContainer();
	
	///@ignore Tags that we captured from a target and that we want to combine with something else without modifying the container.
	capturedTargetTags = new TagContainer();
	
	///@ignore The combined tags
	cachedAggregator = new TagContainer();
	
	///@ignore True if we need to recalculate the combined tags
	dirty = false;
	
	/** Returns a shallow copy of this container
	 * @return {Struct.TagContainerAggregator} */
	static Clone = function() {
		var container = new TagContainerAggregator();
		container.capturedSourceTags = capturedSourceTags.Clone();
		container.capturedTargetTags = capturedTargetTags.Clone();
		container.cachedAggregator = cachedAggregator.Clone();
		container.dirty = dirty;
	}
	
	/** Returns the tag container containing the combined tags
	 * @return {Struct.TagContainer} */
	static GetAggregatedTags = function() {
		if (dirty) {
			dirty = false;
			cachedAggregator.RemoveAllTags();
			cachedAggregator.AppendTags(capturedSourceTags);
			cachedAggregator.AppendTags(capturedTargetTags);
		}
		return cachedAggregator;
	}
	
	/** Returns the tags that are captured from the owning object of this container
	 * @return {Struct.TagContainer} */
	static GetSourceTags = function() {
		INLINE;
		dirty = true;
		return capturedSourceTags;
	}
	
	/** Returns that tag container captured from the specified target of this container
	 * @return {Struct.TagContainer} */
	static GetTargetTags = function() {
		INLINE;
		dirty = true;
		return capturedTargetTags;		
	}
}