//feather ignore all

/** TagContainerInherited: Used to more easily combine tags from different sources.
 * @return {Struct.TagContainerInherited} */
function TagContainerInherited() constructor {
	///@ignore Tags that I have in addition to tags my parent has.
	addedTags = new TagContainer();				
		
	///@ignore Tags that should be removed (but only if my parent had them)
	removedTags = new TagContainer();				
	
	///@ignore Tags that I inherited and tags that I added minus the tags that I removed.
	combinedTags = new TagContainer();	
	
	/** Returns the container of combined tags
	 * @return {Struct.TagContainer} */
	static GetCombinedTags = function() {
		INLINE;
		return combinedTags;
	}			
	
	/** Adds a tag that will appear in addition to the tags inherited from a parent
	 * @arg {Struct.TagSpecifier} tag
	 * @return {Undefined} */
	static AddTag = function(tag) {
		removedTags.RemoveTag(tag);
		addedTags.AddTag(tag);
		combinedTags.AddTag(tag);
	}
	
	/** Adds all the tags from the specified tag container
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Undefined} */
	static AddTags = function(tagContainer) {
		removedTags.RemoveTags(tagContainer);
		addedTags.AppendTags(tagContainer);
		combinedTags.AppendTags(tagContainer);
	}
	
	/** Remove a tag from this inheritance
	 * @arg {Struct.TagSpecifier} tag
	 * @return {Undefined} */
	static RemoveTag = function(tag) {
		removedTags.AddTag(tag);
		addedTags.RemoveTag(tag);
		combinedTags.RemoveTag(tag);
	}	
	
	/** Remove the specified tags from this inheritance
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Undefined} */
	static RemoveTags = function(tagContainer) {
		removedTags.AppendTags(tagContainer);
		addedTags.RemoveTags(tagContainer);
		combinedTags.RemoveTags(tagContainer);
	}
	
	/** Apply my combined tags to the passed in tag container.
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Undefined} */
	static ApplyTo = function(tagContainer) {
		if (tagContainer.IsEmpty() && (!combinedTags.IsEmpty())) {
			tagContainer.AppendTags(combinedTags);
		}
		
		else {
			var removesThatApply = removedTags.Filter(tagContainer);
			var removeOverridesAdd = addedTags.FilterExact(removedTags);
			removesThatApply.AppendTags(removeOverridesAdd);
			tagContainer.AppendTags(addedTags);
			tagContainer.RemoveTags(removesThatApply);
		}
		//tagContainer.RemoveTags(removedTags);
		//tagContainer.AppendTags(addedTags);
	}
	
	/** Inherit tags from the specified parent container.
	 * @arg {Struct.TagContainerInherited} _parent
	 * @return {Undefined} */
	static UpdateInheritance = function(_parent) {
		//Make sure we have a fresh start
		combinedTags.RemoveAllTags();
		
		//Re-add tags from the parent except for the ones that should be removed
		var parentCombined = _parent.combinedTags;
		var len = parentCombined.NumberOfTags();
		for (var i = 0, tag; i < len; i++) {
			tag = parentCombined.GetTagAt(i);
			if (!tag.MatchesAnyTag(removedTags)) {
				combinedTags.AddTag(tag);
			}
		}
		
		//Add our own tags
		len = addedTags.NumberOfTags();
		for (var i = 0, tag; i < len; i++) {
			tag = addedTags.GetTagAt(i);
			if (!removedTags.HasTagExact(tag)) {
				combinedTags.AddTag(tag);
			}
		}
		
		////Add parent tags to my tags
		//addedTags.AppendTags(_parent.combinedTags);
		//
		////Update my combined tags which is the final set of tags for this inheritance
		//ApplyTo(combinedTags);
	}
}