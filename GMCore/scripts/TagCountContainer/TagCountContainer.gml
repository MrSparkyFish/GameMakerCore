//feather ignore all


enum TagCountEvent {
	onCountChanged,
	onNewOrRemoved
}


/** Helper struct for `TagCountContainer`. Tracks an explicit tag and count.
 * @ignore
 * @arg {Struct.TagSpecifier} tag
 * @arg {Real} [count]
 * @return {Struct.TagCountItem} */
function TagCountItem(tag, count = 1) constructor {
	self.tag = tag;
	self.count = count;
}

/** Helper struct that encapsulates the two types of events for tags in a `TagCountContainer`
 * @ignore
 * @return {Struct.TagCountEvents} */
function TagCountEvents() constructor {
	/// Callbacks for when a specific tag count is changed
	onTagCountChanged = new TagCountChanged();
	
	/// Callbacks for when a specific tag is added or remvoed from this container
	onNewOrRemoved = new TagCountChanged();	
}


/** Data struct that helps track how many different effects/effect sources are applying a particular tag to an ASC.
 * @return {Struct.TagCountContainer} */
function TagCountContainer() constructor {
	Implement(ITagsOwner);
	
	///@ignore List of explicit tags and their count
	items = [];
	
	///@ignore Callbacks for when any tag is added or removed from this container
	onAnyTagChanged = new TagCountChanged();
	
	///@ignore Map of tag to active count of that tag
	tagCountMap = {};
	
	///@ignore Map of TagCountEvents keyed by tags.
	tagEventMap = {};
	
	///@ignore container of tags that were explicitly added
	explicitTags = new TagContainer();
	
	/** Fills in parent tags for the explicit tags list
	 * @return {Undefined} */
	static FillTagParents = function() {
		explicitTags.FillTagParents();
	}
	
	/** Returns the `TagCountItem` associated with the specified tag or `undefined` if one can't be found
	 * @ignore
	 * @arg {Struct.TagSpecifier} tag The tag to get the count item for
	 * @arg {Struct.Float} outIndex The index where the item was found
	 * @return {Struct.TagCountItem} */
	static FindTagCountItem = function(tag, index = undefined) {
		///@ignore
		static data = {
			tag : undefined,
			///@arg {Struct.TagCountItem} element
			///@arg {Real} index
			///@ignore
			///@return {Bool} */
			findCountItemPred : function(element, index) {
				return (element.tag.MatchesTagExact(tag));
			}
		}
		
		
		data.tag = tag;
		var idx = array_find_index(items, data.findCountItemPred);
		
		//Get our index where it was found
		if (!is_undefined(index)) {
			index.SetValue(idx);
		}
		
		//Return the item
		if (idx != 0) {
			return items[idx];
		}
	}
	
	/** Returns the `TagCountEvents` associated with the specified tag. If one does not exist, one is created and assigned.
	 * @ignore
	 * @arg {Struct.TagSpecifier} tag The tag to get the event delegates for
	 * @return {Struct.TagCountEvents} */
	static FindOrAddTagCountEvents = function(tag) {
		tagEventMap[$ tag] ??= new TagCountEvents();
		return tagEventMap[$ tag];
	}
	
	/** Returns the number of times the specified tag appears in this container
	 * @arg {Struct.TagSpecifier} tag The tag to get the count of
	 * @return {Real} */
	static GetTagCount = function(tag) {
		INLINE;
		var count = tagCountMap[$ tag];
		return is_undefined(count) ? 0 : count;
	}	
	
	/** Returns how many times the exact specified tag has been added to this container (ignoring parents).
	 * @arg {Struct.TagSpecifier} tag The tag to look for
	 * @return {Real} */
	static GetExplicitTagCount = function(tag) {
		INLINE;
		var item = FindTagCountItem(tag);
		return (!is_undefined(item)) ? item.count : 0;
	}
	
	/** Returns the `TagCountEvents` associated with the specified tag or `undefined` if one doesn't exist.
	 * @arg {Struct.TagSpecifier} tag The tag to get the events for
	 * @return {Struct.TagCountEvents} */
	static GetEventDelegateForTag = function(tag) {
		INLINE;
		return tagEventMap[$ tag];
	}
	
	/** Returns the container of explicit tags
	 * @return {Struct.TagContainer} */
	static GetExplicitTags = function() {
		INLINE;
		return explicitTags;
	}
	
	/** Returns the callback delegate for when any tag is added to, or removed from, this container. 
	 * @return {Struct.TagCountChanged} */
	static GetOnAnyTagAddedOrRemoved = function() {
		INLINE;
		return onAnyTagChanged;
	}
	
	/** Finalizes the new tag count for the specified tag and populates an array with the actions that need to execute in response to the event.
	 * @arg {Struct.TagSpecifier} tag The tag to update
	 * @arg {Real} countDelta The new count
	 * @arg {Struct.MulticastAction} delegate The multicast action delegate to populate with deffered callbacks
	 * @return {Bool} */
	static GatherTagChangeDelegates = function(tag, countDelta, delegate) {
		var tagAndParents = tag.GetParentContainer();
		var createdSignificantChange = false;
		var allTags = tagAndParents.GetTags();
		var len = tagAndParents.NumberOfTags();
		
		for (var i = 0, currentTag; i < len; i++) {
			currentTag = allTags[i];
			
			var oldCount = GetTagCount(currentTag);
			var newTagCount = max(oldCount + countDelta, 0);
			tagCountMap[$ currentTag] = newTagCount;
			
			//A change is significant if a tag was added or removed
			var significantChange = (oldCount == 0 || newTagCount == 0);
			createdSignificantChange |= significantChange;
			
			//Adding the callbacks for if any new tag was added/removed
			if (significantChange) {
				delegate.AddStatic(onAnyTagChanged, onAnyTagChanged.Broadcast, [currentTag, newTagCount]);
			}
			
			//Adding the callbacks for when this specific tag is changed
			var events = GetEventDelegateForTag(currentTag);
			if (!is_undefined(events)) {
				delegate.AddStatic(events.onTagCountChanged, events.onTagCountChanged.Broadcast, [currentTag, newTagCount]);
				
				//Adding callbacks for when this specific tag is added or removed.
				if (significantChange) {
					delegate.AddStatic(events.onNewOrRemoved, events.onNewOrRemoved.Broadcast, [currentTag, newTagCount]);
				}
			}
		}
		
		return createdSignificantChange;
	}		
	
	/** Returns `true` if this count container has a tag that matches the provided one.
	 * @arg {Struct.TagSpecifier} tag The tag to check
	 * @return {Bool} */
	static HasMatchingTag = function(tag) {
		INLINE;
		return (GetTagCount(tag) > 0);
	}
	
	/** Returns `true` if this count container has a matching tag for each tag in the opposing container.
	 * @arg {Struct.TagContainer} tags The tags to check
	 * @return {Bool} */
	static HasAllMatchingTags = function(tags) {
		INLINE;
		var len = tags.NumberOfTags();
		if (len != 0) {
			var tagsToCheck = tags.GetTags();
			for (var i = 0; i < len; i++) {
				if (GetTagCount(tagsToCheck[i]) <= 0) {
					return false;
				}
			}			
		}
		return true;
	}
	
	/** Returns `true` if this count container has at least 1 tag that matches a tag in the opposing container.
	 * @arg {Struct.TagContainer} tags The tags to check
	 * @return {Bool} */	
	static HasAnyMatchingTags = function(tags) {
		INLINE;
		var len = tags.NumberOfTags();
		if (len != 0) {
			var tagsToCheck = tags.GetTags();
			for (var i = 0; i < len; i++) {
				if (GetTagCount(tagsToCheck[i]) > 0) {
					return true;
				}
			}			
		}
		return false;		
	}
	
	/** Broadcast that the count for the specified tag has been changed.
	 * @arg {Struct.TagSpecifier} tag The tag whose count has changed
	 * @return {Undefined} */
	static NotifyStackCountChange = function(tag) {
		var tagsAndParents = tag.GetParentContainer();
		var tags = tagsAndParents.GetTags();
		var len = tagsAndParents.NumberOfTags();
		
		//Broadcast the count changed event for the specific tag and its parents.
		for (var i = 0, currentTag, events; i < len; i++) {
			currentTag = tags[i]; 
			events = FindOrAddTagCountEvents(currentTag);
			
			//Don't do work if we don't have a delegate.
			if (!is_undefined(events)) {
				events.onTagCountChanged.Broadcast(currentTag, GetTagCount(currentTag));
			}
		}
	}
	
	/** Returns the event delegate for registering callbacks for when the specified tag's count is changed or the tag is added/removed.
	 * @arg {Struct.TagSpecifier} tag The tag to register callbacks to
	 * @arg {Enum.TagCountEvent} eventType The type of count event to return
	 * @return {Struct.TagCountChanged} */
	static GetTagEventDelegate = function(tag, eventType = TagCountEvent.onNewOrRemoved) {
		var event = FindOrAddTagCountEvents(tag);
		if (eventType == TagCountEvent.onNewOrRemoved) {
			return event.onNewOrRemoved;
		}
		return event.onTagCountChanged
	}
	
	/** Returns the event delegate where you can register generic callbacks for whenever any tags' count is changed or any tag is added/removed.
	 * @return {Struct.TagCountChanged} */
	static GetGenericTagEventDelegate = function() {
		return onAnyTagChanged;
	}
	
	/** Reset this container to its default empty state optionally keeping any registered callbacks
	 * @arg {Bool} [resetCallbacks] `[=true]` Set true to remove all registered callbacks. Set false to keep them.
	 * @return {Undefined} */ 
	static Reset = function(resetCallbacks = true) {
		StructClear(tagCountMap);
		if (resetCallbacks) {
			StructClear(tagEventMap);
		}
	}
	
	/** Update the specified tag count potentially causing a tag to be added or removed from the explicit tag list. Returns `true` only if a tag was added 
	 * or removed. Returns `false` if no tags were added or removed.
	 * @arg {Struct.TagSpecifier} tag The tag to update
	 * @arg {Real} count The new count
	 * @return {Undefined} */
	static SetTagCount = function(tag, count) {
		INLINE;
		if (!tag.IsValid()) {
			return false;
		}
		
		var existingCount = 0;
		var countItem = FindTagCountItem(tag);
		if (!is_undefined(countItem)) {
			existingCount = countItem.count;
		}
		
		var countDelta = count - existingCount;
		if (countDelta != 0) {
			return UpdateTagMapInternal(tag, countDelta);
		}
		return false;
	}
	
	/** Updates the specified container of tags by the specified delta, potentially causing a tag to be added to, or removed from, the explicit tag list
	 * @arg {Struct.TagContainer} tags The container of tags to update
	 * @arg {Real} countDelta The delta of the tag count to apply
	 * @return {Undefined} */ 
	static UpdateTagsCount = function(tags, countDelta) {
		if (countDelta != 0) {
			var updatedAny = false;
			var deferredDelegates = new MulticastAction();
			
			var tagsArray = tags.GetTags();
			var len = tags.NumberOfTags();
			
			for (var i = 0; i < len; i++) {
				updatedAny |= UpdateTagMapDeferredParentRemovalInternal(tagsArray[i], countDelta, deferredDelegates);
			}
			
			if (updatedAny && (countDelta < 0)) {
				explicitTags.FillTagParents();
			}
			
			len = array_length(deferredDelegates);
			for (var i = 0; i < len; i++) {
				deferredDelegates[i].Broadcast();
			}
		}
	}
	
	/** Updates the specified tag by the specified delta potentially causing it to be added to, or removed from, the explicit tag list
	 * @arg {Struct.TagSpecifier} tags The container of tags to update
	 * @arg {Real} countDelta The delta of the tag count to apply
	 * @return {Undefined} */ 
	static UpdateTagCount = function(tag, countDelta) {
		INLINE;
		if (tag.IsValid() && (countDelta != 0)) {
			return UpdateTagMapInternal(tag, countDelta);
		}
		return false;
	}
	
	/** Internal helper that adjusts the explicit tag list and corresponding maps. May or may not defer the call to `FillTagParents()`. 
	 * @ignore
	 * @arg {Struct.TagSpecifier} tag
	 * @arg {Real} countDelta
	 * @arg {Bool} deferParentTagsOnRemove
	 * @return {Bool} */
	static UpdateExplicitTags = function(tag, countDelta, deferParentTagsOnRemove) {
		INLINE;
		
		var index = new Float();
		var item = FindTagCountItem(tag, index); 
		
		//We have this count item, so update its count
		if (!is_undefined(item)) {
			item.count += countDelta;
			
			if (item.count <= 0) {
				array_delete(items, index, 1);
				explicitTags.RemoveTag(tag, deferParentTagsOnRemove);
			}
		}
		
		//we dont have this count item but need to increase its count, so add one
		else if (countDelta > 0) {
			array_push(items, new TagCountItem(tag, countDelta));
			explicitTags.AddTag(tag);
		}
		
		else {
			if (ABILITY_LOG_WARNING) {
				LogWarning($"Attempting to remove nonexistent tag {tag} from a TagCountContainer");
				return false;
			}
		}
		return true;
	}
	
	/** Internal logic to adjust the explicit tag list and corresponding maps as necessary. Use this function for when you want to fully update the container
	 * in the immediate step.
	 * @ignore
	 * @arg {Struct.TagSpecifier} tag The tag to update
	 * @arg {Real} count The new count
	 * @return {Bool} */
	static UpdateTagMapInternal = function(tag, countDelta) {
		INLINE;
		if (!UpdateExplicitTags(tag, countDelta, false)) {
			return false;
		}
		
		//Since we allowed TagContainer to auto fill parent tags, we just need to execute delegates
		var deferredDelegates = new MulticastAction();
		var significantChange = GatherTagChangeDelegates(tag, countDelta, deferredDelegates); 
		deferredDelegates.Broadcast();
		return significantChange;
	}
	
	/** Internal helper to adjust the explicit tag list and corresponding maps/delegates as necessary. Does not remove tag parents if the specified tag 
	 * ends up being removed by the update. As such, calling code **must** call `FillTagParents()` followed by executing the `deferredDelegates` list.
	 * @ignore
	 * @arg {Struct.TagSpecifier} tag The tag to update
	 * @arg {Real} count The new count
	 * @arg {Struct.MulticastAction} delegate The multicast action delegate to populate with deffered callbacks
	 * @return {Bool} */
	static UpdateTagMapDeferredParentRemovalInternal = function(tag, countDelta, deferredDelegates) {
		INLINE;
		if (!UpdateExplicitTags(tag, countDelta, true)) {
			return false;
		}
		
		return GatherTagChangeDelegates(tag, countDelta, deferredDelegates);
	}
	
	/** Update the specified tag count by the specified delta potentially causing it to be added to, or removed from, the explicit tag list. This method
	 * prevents any removed tags from automatically removing their parents. Because of this, any code calling this method must also call 
	 * `FillTagParents()` somewhere in the same step to handle this. Afterwards, the `deferredDelegates()` must be broadcasted to handle the callbacks.
	 * @arg {Struct.TagSpecifier} tag The tag to update
	 * @arg {Real} count The new count
	 * @arg {Struct.MulticastAction} delegate The multicast action delegate to populate with deffered callbacks
	 * @return {Bool} */
	static UpdateTagCountDeferredParentRemoval = function(tag, countDelta, deferredDelegates) {
		INLINE;
		if (countDelta != 0) {
			return UpdateTagMapDeferredParentRemovalInternal(tag, countDelta, deferredDelegates);
		}
		return false;
	}
	 
}











