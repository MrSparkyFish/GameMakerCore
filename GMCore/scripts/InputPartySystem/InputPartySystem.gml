//feather ignore all

/** InputPartySystem: An InputSystem plug-in that for adding and removing players to a party.
 * @return {Struct.InputPartySystem} */
function InputPartySystem() constructor {
	
	// This constant can be used with `InputPartySetParams()` instead of a specific join verb. Please
	// see documentation for `InputPartySetParams()` for more information.
	#macro INPUT_PARTY_ANY_BUTTON  -1	
	
	
	enum Input_PartySystemFlags {
		joining,
		fillEmpty,
		hotswapOnAbort
	}
	
	
	
	#region Private
		
		///@ignore
		static inputSystem = InputSystem.singleton;								//Ref to the input system
		///@ignore
		minPlayers = 1;															//Min number of players that can be in the party.
		///@ignore
		maxPlayers = INPUT_MAX_PLAYERS;											//Max number of players that can be in the party.
		///@ignore
		joinVerb = undefined;													//Which verb should be activated by a player to join the party
		///@ignore
		leaveVerb = undefined;													//Which verb should be activated by a player to leave the party
		///@ignore
		abortAction = undefined;												//If set to an action, the abort feature is enabled. which sets the first player to join to player 0 if theres no one in the part
		///@ignore
		flags = new BitMask();													//Tracks our state and other flags
		
		/** Returns the first available and connected device that has activity for any verb that isn't the provided verb
		 * @ignore
		 * @arg {Enum.Input_Verb} _verb Devices detecting this verb will be excluded.
		 * @arg {Real} _playerIndex The index of the player provided definition to the `_leaveVerb`
		 * @return {Undefined} */
		static DeviceGetNewActivity = function(_verb, _playerIndex) {
			//Multiplayer games only use kbm input or gamepad input, so filter out the ones that arent of that type
			var _devices = inputSystem.DeviceEnumerateFilter([Input_DeviceType.gamepad, Input_DeviceType.kbm]);
			var _len = array_length(_devices);
			var i = 0; repeat(_len) {
				var _device = _devices[i++];
				if (_device.IsAvailable() && _device.IsActive() && !inputSystem.DeviceHasVerbActivity(_device, _verb, _playerIndex)) {
					return _device;
				}
			}
		}
		
		/** Updates the player lobby with players trying to join/leave
		 * @ignore
		 * @return {Undefined} */
		static OnUpdate = function() {
			//Early exit if not in the join state
			if (!IsJoining()) {
				return;
			}
			
			//A join verb is required
			var _joinVerb = GetJoinVerb();
			if (is_undefined(_joinVerb)) {
				inputSystem.ThrowInputError("OnUpdate", "JoinVerb is not defined.", self);
			}
			
			//Remove players that aren't connected
			for (var i = 0; i < INPUT_MAX_PLAYERS; i++) {
				if (!inputSystem.PlayerIsConnected(i)) {
					inputSystem.PlayerChangeDevice(i, undefined);
				}
			}
			
			//Dropping players down into open spaces
			if (GetFillEmpty()) {
				var _finished = false;
				
				while (!_finished) {
					var i = INPUT_MAX_PLAYERS - 1; repeat(i) {
						var j = i;
						var k = j - 1;
						if (inputSystem.PlayerIsConnected(j) && !inputSystem.PlayerIsConnected(k)) {
							if (INPUT_LOG_DEBUG) {
								LogDebug($"InputPartySystem -> Moving player {j} (connected) to player {k} (disconnected)");
							}
							inputSystem.PlayerSwap(j, k);
							_finished = true;
						} 
					}
				}
			}
			
			//Disconnect extraneaous players
			var _maxPlayers = GetMaxPlayerCount()
			var i = _maxPlayers;
			repeat(INPUT_MAX_PLAYERS - _maxPlayers) {
				inputSystem.PlayerChangeDevice(i--, undefined);
			}	
			
			
			//Must have at least one player still in control of the game, so abort a players disconnection if we need to
			//Thats why we check before allowing others to leave.
			var _leaveVerb = GetLeaveVerb();
			i = 0; repeat(_maxPlayers) {
				
				//Abort player joining the party if they aren't connected to the system
				if (!inputSystem.PlayerIsConnected(i)) {
					var _action = GetAbortAction();
					var _connectionCount = inputSystem.PlayerConnectionCount();
					var _device;
					
					//If we have a valid abort action and there's no players in the party, then if the leave verb is activated,
					//The player who activated it becomes player 0 and we execute the abort action.
					if (!is_undefined(_action) && (_connectionCount <= 0)) {
						_device = inputSystem.DeviceFindNewActivityForVerb(_leaveVerb, i);
						
						if (!is_undefined(_device)) {
							if (INPUT_LOG_DEBUG) {
								LogDebug(ExceptionMessage("OnUpdate", $"Player {i} aborted with device {_device}"));
							}
							SetJoining(false);
							inputSystem.PlayerChangeDevice(i, _device);
							inputSystem.VerbConsumeAll(i);
							_action.Execute();
							return;
						}
						
					}
					
					if (_joinVerb == INPUT_PARTY_ANY_BUTTON) {
						_device = DeviceGetNewActivity(_leaveVerb, i);
					}
					else {
						_device = inputSystem.DeviceFindNewActivityForVerb(_leaveVerb, i);
					}
					
					if (is_undefined(_device)) {
						if (INPUT_LOG_DEBUG) {
							LogDebug(ExceptionMessage("OnUpdate", $"Player {i} joined with no device"));
						}
						inputSystem.PlayerChangeDevice(i, _device);
						inputSystem.VerbConsumeAll(i);
					}
				}
				i++;
			}
			
			 
			//Allowing players to leave the game
			if (!is_undefined(_leaveVerb)) {
				i = 0; repeat(_maxPlayers) {
					var _playerComponent = inputSystem.RequestSystemComponent(i);
					if (_playerComponent.CheckPressed(_leaveVerb)) {
						inputSystem.PlayerChangeDevice(i, undefined);
					}
					i++;
				}
			}
		}
	#endregion
	
	
	#region Properties
		/** Returns `true` if the party system is in the "joining" state
		 * @return {Bool} */
		static IsJoining = function() {
			return flags.IsBitActive(Input_PartySystemFlags.joining);
		}
		
		/** Set if the party system is in the 'joining' state
		 * @arg {Bool} _joining
		 * @return {Undefined} */
		static SetJoining = function(_joining) {
			flags.SetBitState(Input_PartySystemFlags.joining, _joining);
			
			//Hotswapping is always disabled when entering the join state
			if (_joining) {
				inputSystem.SetHotSwap(false);
			}
			else {
				if (GetHotswapOnAbort()) {
					inputSystem.SetHotSwap(true);
				}
			}
		}
		
		/** Returns `true` if the party system will back-fill empty party slots when players leave
		 * @return {Bool} */
		static GetFillEmpty = function() {
			return flags.IsBitActive(Input_PartySystemFlags.fillEmpty);
		}
		
		/** Returns the verb index used by players to join the party system
		 * @return {Constant.Input_Verb} */
		static GetJoinVerb = function() {
			return joinVerb;
		}
		
		/** Set which verb index is used to join the party system
		 * @arg {Enum.Input_Verb} _verb
		 * @return {Undefined} */
		static SetJoinVerb = function(_verb) {
			joinVerb = _verb;
		}
		
		/** Returns the verb index used by players to leave the party system
		 * @return {Constant.Input_Verb} */
		static GetLeaveVerb = function() {
			return leaveVerb;
		}
		
		/** Set which verb index is used for a player to leave the party system
		 * @arg {Enum.Input_Verb} _verb
		 * @return {Undefined} */
		static SetLeaveVerb = function(_verb) {
			leaveVerb = _verb;
		}
		
		/** Returns the max number of players allowed in the party system
		 * @return {Real} */
		static GetMaxPlayerCount = function() {
			return maxPlayers;
		}
		
		/** Returns `undefined` if no abort action has been set.
		 * @return {Struct.Action} */
		static GetAbortAction = function() {
			return abortAction;
		}
		
		/** Returns `true` if hotswapping will be automatically enable when the party system enters the "joining" state 
		 * @return {Bool} */
		static GetHotswapOnAbort = function() {
			return flags.IsBitActive(Input_PartySystemFlags.hotswapOnAbort);
		}
		
		/** When set to `true`, hotswapping will automatically be re-enabled when exiting the "joining" state. 
		 * @arg {Bool} _bool
		 * @return {Undefined} */
		static SetHotswapOnAbort = function(_bool) {
			flags.SetBitState(Input_PartySystemFlags.hotswapOnAbort, _bool);
		}	
	#endregion
	
	
	//Register our event callbacks with the core system
	inputSystem.GetEvents().GetOnUpdate().AddStatic(self, OnUpdate);
}