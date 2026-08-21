//feather ignore all

//Hidden so only the TagManager can use.
/** Represents a hierarchical string that can be used as a kind of label or identifier. `TagSpecifiers` are automatically converted into their full tag 
 * name when used in any operation expecting a `String` data type. Tags should be delimited by a period `"."` symbol.
 * ***
 * Implements: `IString`
 * @ignore
 * @arg {String} tagName The name that will be assigned to this tag.
 * @return {Struct.TagSpecifier} */
function TagSpecifier(tagName = undefined) constructor {
	
	#region Internal data
		
		///@ignore
		self.name = tagName;									//The full tag path represented by this Tag
		
	#endregion
	
	/** Overwrite the toString method so we can use name tags as struct keys.
	 * @ignore
	 * @return {String} */
	static toString = function() {
		INLINE;
		return GetName();
	};		
	
	/** Returns a new `TagContainer` containing only this tag.
	 * @return {Struct.TagContainer} */
	static GetSingleTagContainer = function() {
		return TagManager_Get().GetSingleTagContainer(self);
	}
	
	/** Returns the complete name for the Tag including delimiters
	 * @return {String} */
	static GetName = function() {
		INLINE;
		return name;
	}
	
	/** Returns the single leaf name of this specifier
	 * @return {String} */
	static GetLeafName = function() {
		return StringSplice(GetName(), string_last_pos(".", GetName()), true);
	}
	
	/** Returns the parent Tag of this Tag or `undefined` if a parent isn't set. Calling on `"x.y"` will return `"x"` while calling on `"x"` will return 
	 * `undefined`
	 * @return {Struct.TagSpecifier} */
	static GetParent = function() {
		return TagManager_Get().RequestDirectTagParent(self);
		//return parent;
	}
	
	/** Return `true` if this tag's name is valid
	 * @return {Bool} */
	static IsValid = function() {
		return Tag_IsValidTagString(name);
	}
	
	/** Returns a tag container containing this tag and all of its parents as explicitly added tags
	 * @return {Struct.TagContainer} */	
	static GetParentContainer = function() {
		return TagManager_Get().RequestTagParents(self);
	}
	
	/** Returns a new `TagContainer` containing this tag and all of its child tags as explicitly added tags
	 * @return {Struct.TagContainer} */
	static GetChildContainer = function() {
		var _container = TagManager_Get().RequestTagChildren(self);
		_container.AddTag(self);
		return _container;
	}
	
	/** Returns the number of how many parents another tag shares with this tag. Returns `0` if no parents are shared.
	 * @arg {Struct.TagSpecifier} tag The tag to check depth with
	 * @return {Real} */
	static MatchesDepth = function(tag) {
		return TagManager_Get().TagsMatchDepth(self, tag);
	}
	
	/** Returns `true` if this tag or any of the parents of this tag matches the argument tag (ie: Tag "A.B" return true when checking if it matches Tag "A". 
	 * However, Tag "A" would return false when checking if it matches Tag "A.B")
	 * @arg {Struct.TagSpecifier} tag The tag to match against	
	 * @return {Bool} */
	static MatchesTag = function(tag) {
		var node = TagManager_Get().FindTagNode(self);
		if (!is_undefined(node)) {
			return node.GetSingleTagContainer().HasTag(tag);
		}
		else {
			if (TAG_LOG_WARNING) {
				LogWarning(ExceptionMessage("MatchesTag", $"Invalid tag name {tag.GetName()}"));
			}
			return false;
		}
	}
	
	/** Returns if this tag exactly matches the provided tag. (Ie: Tag "A.B" does not match against tag "A", but 
	 * @arg {Struct.TagSpecifier} tag
	 * @return {Bool} */
	static MatchesTagExact = function(tag) {
		INLINE;
		return (name == tag.name);
	}
	
	/** Returns if this tag matches a tag from the specified container
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Bool} */
	static MatchesAnyTag = function(tagContainer) {
		var node = TagManager_Get().FindTagNode(self);
		if (!is_undefined(node)) {
			return node.GetSingleTagContainer().HasAnyTag(tagContainer);
		}
		else {
			if (TAG_LOG_WARNING) {
				LogWarning(ExceptionMessage("MatchesAnyTag", $"Invalid tag {GetName()}. Cannot check for match."));
			}
			return false;
		}
	}
	
	/** Returns if this tag matches a tag or tag parent from the specified container
	 * @arg {Struct.TagContainer} tagContainer
	 * @return {Bool} */
	static MatchesAnyTagExact = function(tagContainer) {
		return tagContainer.HasTagExact(self);
	}
	
	/** Parse this tag and add each of its parent's tag names to the specified array.
	 * @arg {Array<Struct.TagSpecifier>} uniqueParentTags The array to populate
	 * @return {Undefined} */
	static ParseParentTags = function(uniqueParentTags) {
		//Push in same order as the node parentTags which is immediate parent first.
		//(ie; "Tag.Specifier.Example" should be split and pushed to the array as [Tag.Specifier] then [Tag])
		var tagName = GetName();
		var dotIndex = string_last_pos(".", tagName);
		while (dotIndex != 0) {
			tagName = StringSplice(tagName, dotIndex, false);
			ArrayPushUnique(uniqueParentTags, Tag_RequestTag(tagName));
			dotIndex = string_last_pos(".", tagName);
		}
	}
}