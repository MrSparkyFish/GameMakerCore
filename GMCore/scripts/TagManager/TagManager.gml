//feather ignore all
 
/** Stores a reference to all the tags that exist in the game and distributes them to requesting objects. This way we don't have multiple copies of the same tag and tags can be shared among objects.
 * @return {Struct.TagManager} */
function TagManager() constructor {
	///@ignore Where we store all the defined TagNode. Keyed by The full name of the node.
	tagNodes = {};
	///@ignore Where we store cached queries. 
	tagQuery = {};
	///@ignore Helps us fix tag strings when creating new nodes.
	static fixedInvalidString = new String();
	
	/** Looks for the specified tag node. If one doesn't exit one is created
	 * @arg {String} fullTag The name of the full tag
	 * @arg {String} [delimiter] The delimiter used in the tag. Defaults to `"."`
	 * @arg {String} [devComment] Optional dev comment to set
	 * @return {Struct.TagNode} */
	static FindOrCreateNode = function(fullTag, delimiter = ".", devComment = undefined) {
		if (!IsValidTagString(fullTag, delimiter, fixedInvalidString)) {
			fullTag = fixedInvalidString.GetString();
		}		
		tagNodes[$ fullTag] ??= new TagNode(StringSplice(fullTag, string_last_pos(".", fullTag), true), fullTag);
		return tagNodes[$ fullTag];
	}
	
	/** Returns the named tag from the dictionary or `undefined` if the tag cannot be found.
	 * @arg {String} tagName The name of the tag to return
	 * @return {Struct.TagSpecifier} */
	static RequestTag = function(tagName) {
		return FindOrCreateNode(tagName).GetCompleteTag();
	}
	
	/** Populates the container with all the children of the specified tag node
	 * @arg {Struct.TagContainer} container The container to populate
	 * @arg {Struct.TagNode} node The node to populate the container with
	 * @arg {Bool} deep Set `true` if the container should only include all generations of the node's children. False if it should only include the first.
	 * @return {Undefined} */
	static AddChildrenTags = function(container, node, deep) {
		var children = node.GetChildTagNodes();
		var len = array_length(children);
		
		//Add all the children
		for (var i = 0, child; i < len; i++) {
			child = children[i];
			container.AddTag(child.GetCompleteTag());
			
			//Recursively add all children if requested
			if (deep) {
				AddChildrenTags(container, child, deep);
			}
		}
	}
	
	/** Add a new unique tag query that can be retrieved and reused later
	 * @arg {Struct.TagQuery} _query The query to add
	 * @arg {String} _queryName The name to give the query
	 * @return {Undefined} */
	static CacheQuery = function(_query, _queryName) {
		StructSetMemberUnique(tagQuery, _queryName, _query);
	}
	
	/** Returns the tag query with the provided name. Returns `undefined` if one doesn't exist.
	 * @arg {String} _queryName The name of the query
	 * @return {Struct.TagQuery} */
	static GetCachedQuery = function(_queryName) {
		return StructTryGetMember(tagQuery, _queryName);
	}
	
	/** Populates the specified array with all the tags that are the parents of the passed in tag. Returns `true` if at least 1 tag was added to the array.
	 * @arg {Struct.TagSpecifier} tag The tag to get parents for
	 * @arg {Array<Struct.TagSpecifier>} uniqueParentTags The array of parent tag names to populate.
	 * @return {Bool} */
	static ExtractParentTags = function(tag, uniqueParentTags) {
		var oldSize = array_length(uniqueParentTags);
		var node = FindTagNode(tag);
		
		//Adding the parents to the array.
		if (!is_undefined(node)) {
			var singleContainer = node.GetSingleTagContainer();
			var parents = singleContainer.GetParents();
			ArrayAddAll(uniqueParentTags, parents);
			array_unique_ext(uniqueParentTags);
		}
		
		//If there isn't a node, then the tag is invalid. We can extract parents now in case they get registered later
		else {
			tag.ParseParentTags(uniqueParentTags);
		}
		
		return (array_length(uniqueParentTags) != oldSize);
	}
	
	/** Returns the direct parent of the specified tag or `undefined` if no parent exists.
	 * @arg {Struct.TagSpecifier} tag The tag to get the parent for
	 * @return {Struct.TagSpecifier} */
	static RequestDirectTagParent = function(tag) {
		var node = FindTagNode(tag);
		if (!is_undefined(node)) {
			var parent = node.GetParentTagNode();
			if (!is_undefined(parent)) {
				return parent.GetCompleteTag();
			}			
		}
		return tag;
	}	
	
	/** Returns a `TagContainer` with the supplied tag and all of its parents added explicitly, or an empty container if that failed.
	 * @arg {Struct.TagSpecifier} tag The tag to get parents of
	 * @return {Struct.TagContainer} */
	static RequestTagParents = function(tag) {
		return GetSingleTagContainer(tag).GetTagParents();
	}
	
	/** Returns a `TagContainer` containing all the tags that are children of the specified tag. Doesn't include the original tag.
	 * @arg {Struct.TagSpecifier} tag The tag to get children from
	 * @return {Struct.TagContainer} */
	static RequestTagChildren = function(tag) {
		var container = new TagContainer();
		var node = FindTagNode(tag);
		
		if (!is_undefined(node)) {
			AddChildrenTags(container, node);
		}
		return container;
	}
	
	/** Populates the specified container with all defined tags as explicitly added tags.
	 * @arg {Struct.TagContainer} tagContainer The container of tags to populate
	 * @return {Undefined} */
	static RequestAllTags = function(tagContainer) {
		/// @arg {String} name
		/// @arg {Struct.TagNode} value,
		/// @arg {Struct.TagContainer} container
		var pred = function(name, value, container) {
			container.AddTagFast(value.GetCompleteTag());
		}
		StructForAllMembers(tagNodes, pred, [tagContainer]);
	}
	
	/** Returns the tagNode associated with the specified tag or `undefined` if the node doesn't exist
	 * @arg {Struct.TagSpecifier} tag The tag to get the node for
	 * @return {Struct.TagNode} */
	static FindTagNode = function(tag) {
		INLINE;
		return tagNodes[$ tag.GetName()];
	}
	
	/** Populates the specified array with all the tags that are ancestors of the specified tag
	 * @arg {Struct.TagSpecifier>} tag The tag to get parents from
	 * @arg {Array<Struct.TagSpecifier>} outTags The array to populate
	 * @return {Undefined} */
	static GetTagAncestors = function(tag, outTags) {
		var parent = RequestDirectTagParent(tag);
		while (!is_undefined(parent)) {
			array_push(outTags, parent);
			parent = RequestDirectTagParent(parent);
		}
	}
	
	/** Returns how closly related two tags are. Higher values indicate closer matching tags. 0 indicates no relationship.
	 * @arg {Struct.TagSpecifier} tagOne 
	 * @arg {Struct.TagSpecifier} tagTwo
	 * @return {Real} */
	static TagsMatchDepth = function(tagOne, tagTwo) {
		var tags1 = [];
		var tags2 = []; 
		GetTagAncestors(tagOne, tags1);
		GetTagAncestors(tagTwo, tags2);
		
		//Compare in reverse
		var d = 0;
		for (var i = array_length(tags1) - 1, j = array_length(tags2) - 1; (i >= 0) && (j >= 0); i--) {
			if (tags1[i].GetName() == tags2[j--].GetName()) {
				d++;
			}
			else {
				break;
			}
		}
		return d;
	}	
	
	/** Returns the number of tag nodes in this manager
	 * @return {Real} */
	static GetNumberOfNodes = function() {
		return struct_names_count(tagNodes);
	}
	
	/** Returns a tag container with only the specified tag in it.
	 * @arg {Struct.TagSpecifier} tag The tag to get a container of
	 * @return {Struct.TagContainer} */
	static GetSingleTagContainer = function(tag) {
		var node = FindTagNode(tag.GetName());
		if (!is_undefined(node)) {
			return node.GetSingleTagContainer().Clone();
		}
		//If the node doesn't exist, one should've been created for it. In case that didn't happen, log a message.
		if (TAG_LOG_WARNING) {
			LogWarning(ExceptionMessage("GetSingleTagContainer", $"Passed invalid tag {self}. Returning empty container."));
		}
		//Returning an empty container because the tag should be invalid.
		return new TagContainer();
	}
	
	/** Returns `true` if the specified string is a valid tag string. Attempts to fix invalid strings if able.
	 * @arg {String} tagString The full delimited string used for the tag name
	 * @arg {String} delimiter The delimiter used by the tag
	 * @arg {Struct.String} [outFixedString] Optional String struct that will hold the output fixed string. 
	 * @return {Bool} */
	static IsValidTagString = function(tagString, delimiter, outFixedString = undefined) {
		var isValid = true;
		var fixedString = tagString;
		
		//Trim the edges for lingering white space and delimiters
		var trimmed = string_trim(fixedString, [" ", delimiter]);
		if (string_length(trimmed) != string_length(fixedString)) {
			if (TAG_LOG_WARNING) {
				LogWarning(ExceptionMessage("IsValidTagString", "Tag should not begin or end with leading space or delimiter characters."));
			}
			isValid = false;
			fixedString = trimmed;
		}
		
		//Set the fixed output string if able
		var check = outFixedString;
		if (is_instanceof(check, String)) {
			outFixedString.SetString(fixedString);
		}
		
		return isValid;
	}	
}