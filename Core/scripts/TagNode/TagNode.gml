//feather ignore all

/** Represents intrinsic tag data. `TagSpecifier` is the outward expression of a node
 * @arg {String} tagName The name of the individual tag (ie: "Fireball")
 * @arg {String} fullTag The full dot separated name (ie: "Ability.Skill.Fireball")
 * @arg {String} devComment
 * @return {Struct.TagNode} */
function TagNode(tagName, fullTag, devComment = undefined) constructor {
	/// Raw name of this node at its current rank in the tree. Use this name when checking for node descendants from a parent node.
	self.tag = tagName;
	
	/// The complete tag is in .tags[0] and parents are in .parents
	self.completeTagWithParents = new TagContainer();
	
	/// Array of tags that are the descendants of this one.
	self.childNodes = [];
	
	/// The parent node of this node
	self.parentNode = undefined;
	
	/// Optional dev comment indicating the usage of tags in this node. Useful for debugging.
	self.devComment = devComment;
	
	//Figure out if we should have a parent or if we're a root node.
	var parentName = string_replace(fullTag, $".{tagName}", "");
	if (!is_undefined(parentName) && (parentName != "") && (parentName != tagName)) {
		//Set our parent and add ourselves as its child
		parentNode = TagManager_Get().FindOrCreateNode(parentName);
		array_push(parentNode.childNodes, self);
	}
	
	
	//Manually build our tag container. Its faster since it bypasses safety checks
	//add our full tag as explicit.
	array_push(completeTagWithParents.GetTags(), new TagSpecifier(fullTag));
	
	//add each of our parents as implicit
	if(!is_undefined(parentNode)) {
		var myParents = completeTagWithParents.GetParents()
		array_push(myParents, parentNode.GetSingleTagContainer().GetTags()[0]);
		ArrayAddAll(myParents, parentNode.GetSingleTagContainer().GetParents());
		array_unique_ext(myParents);
	}
	
	
	
	/** Returns the complete tag for this node
	 * @return {Struct.TagSpecifier} */
	static GetCompleteTag = function() {
		INLINE
		return completeTagWithParents.GetTags()[0];
	}
	
	/** Returns the full tag name represented by this node.
	 * @return {String} */
	static GetCompleteTagName = function() {
		INLINE
		return GetCompleteTag().GetName();
	}
	
	/** Returns the simple name of this tag node (the name of where it's at in the tree)
	 * @return {String} */
	static GetSimpleTagName = function() {
		INLINE
		return tag;
	}
	
	/** Returns an array of this nodes children
	 * @return {Array<Struct.TagNode>} */
	static GetChildTagNodes = function() {
		INLINE
		return childNodes;
	}
	
	/** Returns the parent of this node or `undefined` if this node is the root.
	 * @return {Struct.TagNode} */
	static GetParentTagNode = function() {
		INLINE
		return parentNode;
	}
	
	/** Returns the dev comment or `undefined` if one isn't set. Useful for debugging
	 * @return {String} */
	static GetDevComment = function() {
		INLINE
		return devComment;
	}
	
	/** Returns a `TagContainer` with only this tag.
	 * @return {Struct.TagContainer} */
	static GetSingleTagContainer = function() {
		return completeTagWithParents;
	}
}