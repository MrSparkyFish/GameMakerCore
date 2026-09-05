//feather ignore all

/** InputVerbGroupSystem: An InputSystem plug-in that allows you to categorize like-verbs.
 * @return {Struct.InputVerbGroupSystem} */
function InputVerbGroupSystem() constructor {
	/** Notes:
	 * A "VerbGroup" is a bitmask where each bit in the mask represents one of the
	 * defined verbs. These groups are used to indicate which individual verbs 
	 * should have their values cleared (become inactive) and which ones should not. 
	 * 
	 * Instead of comparing verbs directly to an array or struct of the groups they're 
	 * in, we instead assign each verb a bitmask where each bit in the mask represents
	 * a verbGroup. This way we can quickly check which verbs are belong to which groups
	 * while also saving on a ton of overhead.
	 * 
	 * In Summary, any verbs that are a part of an "inactive" verb group will have 
	 * their raw values set to 0.
	 * 
	 * Reading the bitmasks:
	 * 0 in the bit means we don't clear the verbs value
	 * 1 in the bit means we clear the verbs value
	 */
	
	//Use a maximum verb group index of 50 because it's a nice round number and it gives us space for
	//other modifiers in the future. The theoretical maximum 
	#macro INPUT_MAX_VERB_GROUPS  50
	#macro __INPUT_MAX_VERB_GROUPS  50	//Old macro
	
	#region Private
		
		/// Ref to our input system singleton
		inputSystem = InputSystem.singleton;
		
		/// Contains the group masks for each verb index
		verbGroupLookup = [];																
		
		/// Player's mapped to bitmasks used for checking verb groups
		inactiveMap = {};
		
		
		//Registering to events
		var _events = inputSystem.GetEvents();
		_events.GetOnCollectPlayer().AddStatic(self, OnCollectPlayer);
		_events.GetOnFindBindingCollisions().AddStatic(self, OnFindBindingCollisions);
		
		
		//Set up bit masks for all our defined verb groups
		for (var i = inputSystem.VerbGetCount() - 1; i >= 0; i--) {
			//Using 0 to represent "active" verbs. In other words, if a bit becomes 1, 
			//then we clear the values for the verb represented by that bit.
			verbGroupLookup[i] = 0;
		}
		//Set up an array of bitmasks that covers whether each verb group is inactive.
		for (var i = INPUT_MAX_PLAYERS - 1; i >= 0; i--) {
			var _player = inputSystem.GetPlayer(i);
			//Using 0 to represent "active" verbs. In other words, if a bit becomes 1, 
			//then we clear the values for the verb represented by that bit.
			inactiveMap[$ _player] = 0;
		}
		
		//Adding our verb group definitions
		var _verbGroupDictionary = new InputVerbGroupDictionary();								
		var _groups = _verbGroupDictionary.GetVerbGroups();
		var _len = array_length(_groups);
		for (var i = 0; i < _len; i++) {
			//Each verb group `i` contains an array of the verbs that belong to it.
			var _verbArray = _groups[i];
			
			//Get each verb `j` from group `i` and insert a binary 1 into it that indicates which group it belongs to.
			var j = 0; repeat(array_length(_verbArray)) {
				verbGroupLookup[_verbArray[j]].EnableBit(i);
			}
		}
		
		
		/** Returns the inactive bit mask for the player at the specified index
		 * @arg {Real} _playerIndex Index of the player to get the mask for
		 * @return {Struct.BitMask} */
		static GetPlayerIndexMask = function(_playerIndex) {
			return GetPlayerInactiveMask(inputSystem.GetPlayer(_playerIndex));
		}
		
		/** Returns the inactive group mask for the specified player
		 * @ignore
		 * @arg {Struct.InputPlayer} _player The player to get the mask for
		 * @return {Struct.BitMask} */
		static GetPlayerInactiveMask = function(_player) {
			return inactiveMap[$ _player];
		}
		
		/** Abstracted logic to set value in a players inactive mask.
		 * @arg {Real} _playerIndex The index of the player to set for
		 * @arg {Real} _value The value to set for their mask
		 * @return {Undefined} */
		static SetPlayerInactiveMask = function(_playerIndex, _value) {
			var _player = inputSystem.GetPlayer(_playerIndex);
			var _mask = GetPlayerInactiveMask(_player);
			_mask = _value
		}
		
		/** Recieves a `CollectPlayer` event notice and updates the collected player's verbs accordingly.
		 * @ignore
		 * @arg {Struct.InputPlayer} _player The player who was collected
		 * @return {Undefined} */
		static OnCollectPlayer = function(_player) {
			//Player's inactive mask. We use this to compare groups.
			var _inactiveMask = GetPlayerInactiveMask(_player);
			var _count = inputSystem.VerbGetCount();
			for (var i = 0; i < _count; i++) {
				var _verbMask = verbGroupLookup[i];
				
				if (INPUT_VERB_GROUP_INACTIVE_ON_ANY) {
					//If a verbs mask matches any of the inactive masks then we know that verb should be cleared.
					if (_verbMask.ContainsAny(_inactiveMask)) {
						 var _verb = _player.GetVerb(i);
						_verb.ValueReset();
					}
				}
				else {
					//If a verbs mask matches all of the inactive masks then we know that verb should be cleared.
					if (_verbMask.AnyActiveBits() && (_verbMask.ContainsAll(_inactiveMask))) {
						var _verb = _player.GetVerb(i);
						_verb.ValueReset();
					}
				}
			}
		}
		
		
		/* Recieves a `FindBindingCollision` event notice and updates verbs groups accordingly
		 * @ignore
		 * @arg {Struct.InputPlayer} _player The player who searched for shared verb bindings
		 * @arg {Enum.Input_Verb} _verbIndex The index of the source verb
		 * @arg {Array<StructInputBindingCapture>} _captures An array of binding collisions that contain the other verbs bound to the button and in what position the button is bound
		 * @return {Undefined} */
		static OnFindBindingCollisions = function(_player, _verbIndex, _captures) {
			//We use the source mask to compare against other verbs for collisions
			var _sourceMask = verbGroupLookup[_verbIndex];
			
			//If we're in all verb groups then collisions must remain
			if (_sourceMask.NoActiveBits()) {
				return;
			}
			
			var i = inputSystem.VerbGetCount(); while(i >= 0) {
				
				var _capture = _captures[--i];
				var _verb = _capture.GetVerbIndex();
				var _verbMask = verbGroupLookup[_verb];
				
				//If we're in all verb groups then collisions must remain
				if (_verbMask.NoActiveBits()) {
					
					//But if the source and found masks don't have any overlap, then the collision needs to be removed
					if (!_sourceMask.ContainsAny(_verbMask)) {
						array_delete(_captures, i, 1);
					}
				}
			}
		}		
	#endregion
	
	
	/** Activates all verb groups for the specified player. Any verbs that are a part of an "inactive" verb group will not be able to return input values.
	 * @arg {Real} _playerIndex The index of the player whose verb groups should be activated
	 * @return {Undefined} */
	static ActivateAll = function(_playerIndex) {
		SetPlayerInactiveMask(_playerIndex, 0);
	}
	
	/** Deactivates all verb groups for the specified player. Any verbs that are a part of an "inactive" verb group will not be able to return input values.
	 * @arg {real} _playerIndex The index of the player whose verb groups should be deactivated.
	 * @return {Undefined} */
	static DeactivateAll = function(_playerIndex) {
		SetPlayerInactiveMask(_playerIndex, -1);
	}
	
	/** Returns `true` if the specified verb group for a player is "active". Any verbs that are a part of an "inactive" verb group will not be able to return input values.
	 * @arg {Real} _playerIndex The player whose verb groups you want to check
	 * @arg {Enum.Input_VerbGroup} _verbGroup The verb group you want to check
	 * @return {Undefined} */
	static VerbGroupIsActive = function(_playerIndex, _verbGroup) {
		var _inactiveMask = GetPlayerIndexMask(_playerIndex);
		return _inactiveMask.ContainsAny(_verbGroup);
	}
	
	/** Returns an array of `Enum.Input_Verb`s that are assigned to the specified verb group 
	 * @arg {Enum.Input_VerbGroup} _verbGroup The verb group to get the verbs from
	 * @return {Array<Enum.Input_Verb>} */
	static VerbGroupGetVerbs = function(_verbGroup) {
		var _verbArray = [];
		
		//Find verbs whose group masks overlap with the given group
		var i = 0; repeat(inputSystem.VerbGetCount()) {
			var _mask = verbGroupLookup[i++];
			if (_mask.ContainsAny(_verbGroup)) {
				array_push(_verbArray, i);
			}
		}
		return _verbArray;
	}
	
	/** Returns an array of verb groups that the specified verb is a part of.
	 * @arg {Enum.Input_Verb} _verb The verb to find groups from
	 * @return {Array<Enum.Input_VerbGroup} */
	static VerbGetGroups = function(_verb) {
		var _groups = [];
		
		//Find verbs
		var _mask = verbGroupLookup[_verb];
		for(var i = 0; i < INPUT_MAX_VERB_GROUPS; i++) {
			if (_mask.ContainsAny(i)) {
				array_push(_groups, i);
			}
		}
		return _groups;
	}
	
	/** Set a player's verb group to be active or inactive. Any verbs that are a part of an "inactive" verb group will not be able to return input values.
	 * @arg {Real} _playerIndex Index of the player whose group you want to set
	 * @arg {Enum.Input_VerbGroup} _verbGroup The verb group index you are setting
	 * @arg {Bool} _active Set `true` to activate the group, or `false` to deactive it.
	 * @arg {Bool} [_exclusive] `[=false]` When `true` causes all *other* verb groups to be set to the opposite of `_active` (ie: if `_active = true` then `_verbGroup` will activate and all other groups will deactivate and vice versa). This behavior is disabled by default.
	 * @return {Undefined} */
	static VerbGroupSetActive = function(_playerIndex, _verbGroup, _active, _exclusive = false) {
		var _inactiveMask = GetPlayerIndexMask(_playerIndex);
		
		//Active groups have bit values of 0 (don't reset these verbs)
		if (_active) {
			return (_exclusive) ? _inactiveMask.DisableBitExclusive(_verbGroup) : _inactiveMask.DisableBit(_verbGroup);
		}
		//Inactive masks have bit values of 1 (reset these verbs)
		else {
			return (_exclusive) ? _inactiveMask.EnableBitExclusive(_verbGroup) : _inactiveMask.EnableBit(_verbGroup);
		}
	}
}