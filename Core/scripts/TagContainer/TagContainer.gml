//feather ignore all

/** TagContainer: Stores and manages the tags that are applied to an object.
 * @return {Struct.TagContainer} */
function TagContainer() constructor {
	
	///@ignore Holds the explicitly added tags
	self.tags = [];		
	
	///@ignore Holds parents of explicitly added tags for faster parent checks. These tags are the implicitly added tags and not counted as a part of the container.
	self.parents = [];									
	
	/** Returns a copy of this TagContainer
	 * @return {Struct.TagContainer} */
	static Clone = function() {
		return variable_clone(self, 0);
	}
	
	/** Adds a `TagSpecifier` to this container
	 * @arg {Struct.TagSpecifier} tag The tag to add
	 * @return {Undefined} */
	static AddTag = function(tag) {
		if (ArrayPushUnique(GetTags(), tag)) {
			tag.ParseParentTags(parents);
		}	
	}
	
	/** Quick version of `AddTag()`. Doesn't check for uniqueness.
	 * @arg {Struct.TagSpecifier} tag
	 * @return {Undefined} */
	static AddTagFast = function(tag) {
		array_push(GetTags(), tag);
		tag.ParseParentTags(parents);		
	}
	
	/** Adds a tag to this container and removes any direct parents. Wont add if the child already exists. Returns `true` if the tag was added
	 * @arg {Struct.TagSpecifier} tag The tag to add
	 * @return {Bool} */
	static AddLeafTag = function(tag) {
		if (HasTagExact(tag)) {
			return true;
		}
		
		if (HasTag(tag)) {
			return false;
		}
		
		var parents = [];
		if (TagManager_Get().ExtractParentTags(tag, parents)) {
			var len = array_length(parents);
			for (var i = 0, pTag; i < len; i++) {
				pTag = parents[i];
				if (HasTagExact(pTag)) {
					RemoveTag(pTag);
				}
			}			
		}
		AddTag(tag);
		return true;
	}
	
	/** Adds an array of tags to this container as explicitly added tags
	 * @arg {Array<Struct.TagSpecifier>} _array 
	 * @return {Struct.TagContainer} */ 
	static AddTagArray = function(_array) {
		self.tags = _array;
		FillTagParents();
	}
	
	/** Adds a tag to this container using its string identifier
	 * @arg {String} tag The tag to add
	 * @return {Struct.TagContainer} */
	static AddTagFromString = function(tag) {
		if (!Tag_IsValidTagString(tag)) {
			TagError("AddTagFromString", $"Invalid Tag name detected! Tag name [{tag}] is not of type string or is an empty string.");
		}
		return AddTag(Tag_RequestTag(tag));
	}
	
	/** Appends the matching tags from 2 other containers into this container
	 * @arg {Struct.TagContainer} containerA
	 * @arg {Struct.TagContainer} containerB
	 * @return {Undefined} */
	static AppendMatchingTags = function(containerA, containerB) {
		//Append the matching tags.
		var tagsA = containerA.GetTags();
		var len = array_length(tagsA);
		for (var i = 0, tag; i < len; i++) {
			tag = tagsA[i];
			if (tag.MatchesAnyTag(containerB)) {
				AddTag(tag);
			}
		}
	}
	
	/** Adds tags from one container into this container. This is the union of one container with this one.
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Undefined} */
	static AppendTags = function(tagContainer) {
		tags = array_union(GetTags(), tagContainer.GetTags());
		parents = array_union(GetParents(), tagContainer.GetParents());
	}
	
	/** Returns a filtered version of this container. Returns all tags that match any of the tags in the other container (expanding parents).
	 * @arg {Struct.TagContainer} tagContainer The tags to match against
	 * @return {Struct.TagContainer} */
	static Filter = function(tagContainer) {
		var result = new TagContainer();
		var len = array_length(tags);
		
		for (var i = 0, tag; i < len; i++) {
			tag = GetTags()[i];
			if (tag.MatchesAnyTag(tagContainer)) {
				result.AddTagFast(tag);
			}
		}
	}
	
	/** Returns a filtered version of this container. Returns all tags that match exactly one of the tags in the other container
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Struct.TagContainer} */
	static FilterExact = function(tagContainer) {
		var result = new TagContainer();
		result.tags = array_intersection(GetTags(), tagContainer.GetTags());
		return result;
	}	
	
	/** Implicitly adds all the parents for all the tags in this container.
	 * @return {Undefined} */
	static FillTagParents = function() {
		array_resize(GetParents(), 0);
		var len = array_length(GetTags());
		if (len > 0) {
			var manager = TagManager_Get();
			for (var i = 0; i < len; i++) {
				manager.ExtractParentTags(GetTags()[i], GetParents());
			}
		}
	}
	
	/** Returns an array of the explicitly added tags
	 * @return {Array<Struct.TagSpecifier>} */
	static GetTags = function() {
		INLINE;
		return tags;
	}
	
	/** Returns an array of all the parent tags in this container
	 * @return {Array<Struct.TagSpecifier>} */
	static GetParents = function() {
		INLINE;
		return parents;
	}
	
	/** Returns a new `TagContainer` that contains this container's tags and tag parents as explicitly added tags
	 * @return {Struct.TagContainer} */
	static GetTagParents = function() {
		var result = new TagContainer();
		result.tags = array_union(GetTags(), GetParents());
		return result;
	}
	
	/** Returns the tag at the specified index or `undefined` if no tag exists
	 * @arg {Real} index The index of the tag to get
	 * @return {Struct.TagSpecifier} */
	static GetTagAt = function(index) {
		return ArrayTryGetElement(GetTags(), index, undefined);
	}
	
	/** Checks if the specified Tag is in this container.
	 * ***
	 * For example, if this container has tag "A" and you check for tag "A.B" this function would return false.
	 * @arg {Struct.TagSpecifier} tag The Tag to check for
	 * @return {Bool} */	
	static HasTagExact = function(tag) {
		return array_contains(GetTags(), tag);
	}	
	
	/** Recursively checks if the specified Tag or any of its parents are in this container. 
	 * ***
	 * For example, if this container has tag "A" and you check for tag "A.B", this function would return true.
	 * @arg {Struct.TagSpecifier} tag The Tag to check for
	 * @return {Bool} */
	static HasTag = function(tag) {
		return (array_contains(GetTags(), tag) || array_contains(GetParents(), tag));
	}
	
	/** Checks if this container has all the tags of another container.
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Bool} */
	static HasAllTagsExact = function(tagContainer) {
		return ArrayContainsAllValues(tags, tagContainer.GetTags());
	}
	
	/** Checks if this container has all of the tags in the specified container also checking against parents.
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Bool} */
	static HasAllTags = function(tagContainer) {
		//Better optimization to access the container only once
		var tags = tagContainer.GetTags();
		var len = array_length(tags);
		//Check each opposing tag to see if this container has it or one of its parents
		for (var i = 0; i < len; i++) {
			if (!HasTag(tags[i])) {
				return false;
			}
		}
		return true;
	}	
	
	/** Checks if this container has any of the tags found in another container
	 * @arg {Struct.TagContainer} tagContainer The TagContainer to check against
	 * @return {Bool} */
	static HasAnyTagExact = function(tagContainer) {
		return ArrayContainsAnyValue(GetTags(), tagContainer.GetTags());
	}		
	
	/** Checks if this container has any of the tags found in another container. Also checks against parents.
	 * @arg {Struct.TagContainer} tagContainer The TagContainer to check against
	 * @return {Bool} */	
	static HasAnyTag = function(tagContainer) {
		var tagsToCheck = tagContainer.GetTags();
		if (ArrayContainsAnyValue(GetTags(), tagsToCheck) || ArrayContainsAnyValue(GetParents(), tagsToCheck)) {
			return true;
		}
		return false;
	}
	
	/** Returns `true` if this TagContainer doesn't contain any tags
	 * @return {Bool} */
	static IsEmpty = function() {
		INLINE;
		return (array_length(GetTags()) <= 0);
	}
	
	/** Returns `true` if this container matches the given `TagQuery`
	 * @arg {Struct.TagQuery} _query The query to check for a match.
	 * @return {Bool} */
	static MatchesQuery = function(_query) {
		return _query.Matches(self);
	}
	
	/** Removes the specified Tag from this container
	 * @arg {Struct.TagSpecifier} tag The Tag to remove
	 * @arg {Bool} deferParentTags True if we should skip calling `FillParentTags()`. Better for performance but must be handled by calling code separately.
	 * @return {Undefined} */
	static RemoveTag = function(tag, deferParentTags = false) {
		//Remove the tag from the child array and remove its parents.
		var removed = ArrayRemove(GetTags(), tag)
		if (removed) {
			
			if (!deferParentTags) {
				//There could be other tags providing the same parent tag, so recalculate parents.
				FillTagParents();
			}
			
		}
		return removed;
	}
	
	/** Removes all tags found in the argument container from this container
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Undefined} */
	static RemoveTags = function(tagContainer) {
		var numberRemoved = 0;
		var tagsToRemove = tagContainer.GetTags();
		var len = array_length(tagsToRemove);
		for (var i = 0; i < len; i++) {
			numberRemoved += ArrayRemove(GetTags(), tagsToRemove[i]);
		}
		//Only redo parent tags if we actually removed anything
		if (numberRemoved > 0) {
			FillTagParents();
		}
	}
	
	/** Removes all tags from this container emptying it completely.
	 * @return {Undefined} */
	static RemoveAllTags = function() {
		array_resize(GetTags(), 0);
		array_resize(GetParents(), 0);
	}
	
	/** Returns `true` if this container is effectively equal to another container
	 * @arg {Struct.TagContainer} tagContainer The other container of tags to check
	 * @return {Bool} */
	static Equals = function(tagContainer) {
		return (ArrayEqualsArray(GetTags(), tagContainer.GetTags()) && ArrayEqualsArray(GetParents(), tagContainer.GetParents()));
	}
	
	/** Returns the number of tags that have been explicitly added to this container.
	 * @return {Real} */
	static NumberOfTags = function() {
		return array_length(GetTags());
	}
}







