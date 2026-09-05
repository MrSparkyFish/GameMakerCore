//feather ignore all
 
/** The interface for objects that are able to 
 * @return {Struct.ITagsOwner} */
function ITagsOwner() {
	
	/** Returns a tag container that contains all the tags owned by this `ITagsOwner`. Use this method when you want to directly modify the tags.
	 * Typically used for initializing and boiler plate. Its recommended to use `GetOwnedTagsPopulated()` if you need to dynamically modify the 
	 * tags owned by this object.
	 * @return {Struct.TagContainer} */
	GetOwnedTags = function() {
		ThrowMethodNotImplemented("GetOwnedTags");
	}
	
	/** Removes all tags from the specified tag container then populates it with all the tags owned by this `ITagsOwner`. Use this method to dynamically 
	 * modify the tags owned by this object without directly modifying the origianl set of owned tags.
	 * @arg {Struct.TagContainer} outTags The container to empty and populate.
	 * @return {Undefined} */
	GetOwnedTagsPopulated = function(outTags) {
		ThrowMethodNotImplemented("GetOwnedTags");
	}
	
	/** Returns true if the object owns the specified tag (expands to tag parents of the object)
	 * @arg {Struct.TagSpecifier} tagToCheck The tag to look for
	 * @return {Bool} */
	HasMatchingTag = function(tagToCheck) {
		ThrowMethodNotImplemented("HasMatchingTag");
	}
	
	/** Returns true if the object owns all the tags in the specified container (expands to tag parents of the object)
	 * @arg {Struct.TagSpecifier} tagToCheck The tag to look for
	 * @return {Bool} */	
	HasAllMatchingTags = function(tagsToCheck) {
		ThrowMethodNotImplemented("HasAllMatchingTags");
	}
	
	/** Returns true if the object owns at least one tag in the specified container (expands to tag parents of the object)
	 * @arg {Struct.TagSpecifier} tagToCheck The tag to look for
	 * @return {Bool} */		
	HasAnyMatchingTags = function(tagsToCheck) {
		ThrowMethodNotImplemented("HasAnyMatchingTags");
	}
	
}