/** TagRequirements: Represents a container of required tags used for checking Tag conditionals
 * @arg {Struct.TagRequirements} */
function TagRequirements() constructor {
	///@ignore None of these tags are allowed to be present
	ignored = new TagContainer();
	
	///@ignore All of these tags are required to be present
	required = new TagContainer();
	
	///@ignore Enables us to build a more complex query that can't otherwise be expressed with `ignore` and `required`
	query = new TagQuery();
	
	/** Returns the query that must match for the requirements to be passed.
	 * @return {Struct.TagQuery} */
	static GetQuery = function() {
		INLINE;
		return query;
	}
	
	/** Add a tag to be ignored
	 * @arg {Struct.TagSpecifier} _tag
	 * @return {Undefined} */
	static AddIgnoredTag = function(_tag) {
		ignored.AddTag(_tag);
	}
	
	/** Add a tag to be required
	 * @arg {Struct.TagSpecifier} _tag
	 * @return {Undefined} */
	static AddRequiredTag = function(_tag) {
		required.AddTag(_tag);
	}
	
	/** Returns the container of tags that must not be present for the check to return true;
	 * @return {Struct.TagContainer} */
	static GetIgnoredTags = function() {
		INLINE;
		return ignored;
	}
	
	/** Returns the container of tags required for the check to return true.
	 * @return {Struct.TagContainer} */
	static GetRequiredTags = function() {
		INLINE;
		return required;
	}
	
	/** Returns true if the argument TagContainer has all of the required tags and none of the ignored tags
	 * @arg {Struct.TagContainer} _tagContainer The container to check
	 * @return {Bool} */
	static MeetsRequirements = function(_tagContainer) {
		var hasRequired = _tagContainer.HasAllTags(required);
		var hasIgnored = _tagContainer.HasAnyTag(ignored);
		var passesQuery = (query.IsEmpty() || query.Matches(_tagContainer));
		return (hasRequired && (!hasIgnored) && passesQuery);
	}
	
	/** Returns `true` if there are no tags in this container
	 * @return {Bool} */
	static IsEmpty = function() {
		return (ignored.IsEmpty() && required.IsEmpty() && query.IsEmpty());
	}
	
	/** Converts the ignored and required tags into an equivalent `TagQuery`
	 * @return {Struct.TagQuery} */
	static ToQuery = function() {
		
	}
	
}