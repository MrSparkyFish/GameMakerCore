//feather ignore all

/** Throw a Tag related exception
 * @arg {String} _func The function that threw the error
 * @arg {String} _description Explanation for why the error was thrown
 * @arg {Struct|Id.Instance} _scope The scope that the function was called in. `[=self]`
 * @return {Undefined} */
function TagError(_func, _description, _scope = undefined) {
	var _title = "Tag Error!";
	var _desc = ExceptionMessage(_scope, _func, _description);
	ThrowException(_title, _desc);
}


#region TagManager
	
	/** Returns the singleton tag manager
	 * @return {Struct.TagManager} */
	function TagManager_Get() {
		static singleton = new TagManager();
		return singleton;
	}
	
#endregion	


#region Tag
	
	/** Returns the `TagSpecifier` associated with the given string. 
	 * @arg {String} tagName The full name of the tag including `"."` delimiters.
	 * @return {Struct.TagSpecifier} */
	function Tag_RequestTag(tagName) {
		return TagManager_Get().RequestTag(tagName);
	}
	
	/** Returns the direct parent tag for the specified tag string or `undefined` if no tag can be found.
	 * @arg {String} tagName The name of the tag to get the parent for
	 * @return {Struct.TagSpecifier} */
	function Tag_RequestDirectParent(tagName) {
		return TagManager_Get().RequestDirectTagParent(tagName);
	}
	
	/** Returns `true` if the specified name is a valid tag name
	 * @arg {String} tagName The name to check
	 * @return {Bool} */
	function Tag_IsValidTagString(tagName) {
		INLINE;
		return (is_string(tagName) && (tagName != ""));
	}	
	
	/** Returns an empty tag which can be used as a placeholder
	 * @return {Struct.TagSpecifier} */
	function Tag_EmptyTag() {
		INLINE;
		return new TagSpecifier();
	}
	
	/** Returns an array of strings that is this tag's name split into individual parts
	 * @arg {String} tagName The tag name to split
	 * @return {Array<String>} */	
	function Tag_SplitName(tagName) {
		return string_split(tagName, ".", true);
	}
	
#endregion


#region TagContainer
	/** Creates a new `TagContainer` from the specified array of tags
	 * @arg {Array<Struct.TagSpecifier>} tags The tags that the returned container should have as explicitly added tags.
	 * @return {Struct.TagContainer} */
	function TagContainer_CreateFromArray(tags) {
		var result = new TagContainer();
		result.AddTagArray(tags);
		return result;
	}	
	
#endregion


#region TagQuery
	
	/** Builds a new `TagQuery` with the specified root expression and optional dev comment
	 * @arg {Struct.TagQueryExpression} rootExpr The root expression used to build the query
	 * @arg {String} [description] Optional description of this query. Useful for debugging.
	 * @return {Undefined} */
	function TagQuery_CreateQuery(rootExpr, description = undefined) {
		var q = new TagQuery();
		q.Build(rootExpr, description);
		return q;
	}
	
	/** Creates a new `TagQuery` for matching all the tags in the specified container
	 * @arg {Struct.TagContainer} tagContainer The container to make a query out of
	 * @return {Struct.TagQuery} */
	function TagQuery_CreateAllTagsMatch(tagContainer) {
		var _e = new TagQueryExpression();
		return TagQuery_CreateQuery(_e.AllTagsMatch().AddTags(tagContainer));
	}
	
	/** Creates a new `TagQuery` for matching any of the tags in the specified container
	 * @arg {Struct.TagContainer} tagContainer The container to make a query out of
	 * @return {Struct.TagQuery} */
	function TagQuery_CreateAnyTagsMatch(tagContainer) {
		var _e = new TagQueryExpression();
		return TagQuery_CreateQuery(_e.AnyTagsMatch().AddTags(tagContainer));		
	}
	
	/** Creates a new `TagQuery` for exactly matching all of the tags in the specified container
	 * @arg {Struct.TagContainer} tagContainer The container to make a query out of
	 * @return {Struct.TagQuery} */	
	function TagQuery_CreateAllTagsExactMatch(tagContainer) {
		var _e = new TagQueryExpression();
		return TagQuery_CreateQuery(_e.AllTagsMatchExact().AddTags(tagContainer));
	}
	
	/** Creates a new `TagQuery` for exaclty matching any of the tags in the specified container
	 * @arg {Struct.TagContainer} tagContainer The container to make a query out of
	 * @return {Struct.TagQuery} */	
	function TagQuery_CreateAnyTagsExactMatch(tagContainer) {
		var _e = new TagQueryExpression();
		return TagQuery_CreateQuery(_e.AnyTagsMatchExact().AddTags(tagContainer));		
	}
	
	/** Creates a new `TagQuery` for matching none of the tags in the specified container
	 * @arg {Struct.TagContainer} tagContainer The container to make a query out of
	 * @return {Struct.TagQuery} */
	function TagQuery_CreateNoTagsMatch(tagContainer) {
		var _e = new TagQueryExpression();
		return TagQuery_CreateQuery(_e.NoTagsMatch().AddTags(tagContainer));			
	}
	
	/** Creates a new `TagQuery` for matching the specified tag.
	 * @arg {Struct.TagSpecifier} _tag The tag to make a query out of
	 * @return {Struct.TagQuery} */
	function TagQuery_CreateTagMatches(_tag) {
		var _e = new TagQueryExpression();
		return TagQuery_CreateQuery(_e.AllTagsMatch().AddTag(_tag));			
	}
	
	/** Returns true if the specified variable holds a valid non-empty query.
	 * @arg {Struct.TagQuery} tagQuery The variable to check
	 * @return {Undefined} */
	function TagQuery_CanQueryMatch(tagQuery) {
		if (is_instanceof(tagQuery, TagQuery)) {
			return tagQuery.IsEmpty();
		}
		return false;
	}	
	
	/** Cache a reference to a query with the tag manager so you can use it at a later time without needing to rebuild it or search for it.
	 * @arg {Struct.TagQuery} _query The query to cache
	 * @arg {String} _queryName The name of the query. This is the name you will pass to `TagGetCachedQuery()` when you need to retrieve the query.
	 * @return {Undefined} */
	function TagQuery_CacheQuery(_query, _queryName) {
		TagManager_Get().CacheQuery(_queryName, _query);
	}
	
	/** Returns a reference to a query previously cached with `TagChacheQuery`. Assignes and returns an empty query with the provided name doesn't exist (changing the empty query henceforth changes its cache as well).
	 * @arg {String} _queryName The name of the query to try and return
	 * @return {Struct.TagQuery} */
	function TagQuery_GetCachedQuery(_queryName) {
		return TagManager_Get().GetCachedQuery(_queryName);
	}
#endregion