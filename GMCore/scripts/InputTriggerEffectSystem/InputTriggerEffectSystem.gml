//feather ignore all

/** InputTriggerEffectSystem: An InputSystem plug-in that allows you to set and manage trigger effects for gamepads. A trigger effect is hardware limited. Currently,
 * this system is only viable when the game is being played using a PS5 gamepad as its the only device type that supports these kinds of effects. 
 * @return {Struct.InputTriggerEffectSystem} */
function InputTriggerEffectSystem() constructor {
	//The default haptic trigger effect strength. This value can be changed later by using input_trigger_effect_set_strength()
	#macro INPUT_TRIGGER_EFFECT_DEFAULT_STRENGTH  1.0	
	
	
	//Indicates the type of effec this is
	enum Input_TriggerEffectType {
		off,
		feedback,
		weapon,
		vibration
	} 
	
	
	#region Private
		
		static off = new InputGamepadTriggerEffectOff();							//Create the off effect as static because we're never changing it.	
		static inputSystem = InputSystem.singleton;
		gamepadMap = {};
		players = array_create(INPUT_MAX_PLAYERS);
		steamModes = array_create(4);
		
		//Registering to events
		var _events = inputSystem.GetEvents();
		_events.GetOnFocusLost().AddStatic(self, OnFocusLost);
		_events.GetOnFocusGained().AddStatic(self, OnFocusGained);
		_events.GetOnPlayerDeviceChanged().AddStatic(self, OnPlayerDeviceChanged);
		_events.GetOnSystemRestart().AddStatic(self, OnSystemRestart);
		
		
		/** Returns the gamepad trigger associated with the specified gamepad or `undefined` if one can't be found
		 * 
		 * @arg {Struct.InputDeviceGamepad} _gamepad
		 * @return {Struct.InputTriggerEffectHandler} */
		static GetGamepadTrigger = function(_gamepad) {
			return StructTryGetMember(gamepadMap, _gamepad);
		}
		
		/** Returns the gamepad used by the player with the specified index. Returns undefined if they aren't using a gamepad
		 * 
		 * @arg {Real} _playerIndex The index of the player
		 * @return {Struct.InputDeviceGamepad} */
		static GetPlayerGamepad = function(_playerIndex) {
			//Can only add the effect if the player is valid and using a gamepad
			var _player = inputSystem.GetPlayer(_playerIndex);
			if (_player.UsesGamepad()) {
				return _player.GetDevice();	
			}
		}
		
		/** returns `true` if the specified gamepad button is a trigger button
		 * 
		 * @arg {Constant.GamepadButton} _trigger Gamepad button to check
		 * @return {Bool} */
		static IsTrigger = function(_trigger) {
			return (IsLeftTrigger(_trigger) || IsRightTrigger(_trigger));
		}
		
		/** Returns `true` if the specified button is the left gamepad trigger button
		 * 
		 * @arg {Constant.GamepadButton} _button A gamepad button
		 * @return {Bool} */
		static IsLeftTrigger = function(_trigger) {
			return (_trigger == gp_shoulderlb);
		} 
		
		/** Returns `true` if the specified button is the right gamepad trigger button
		 * 
		 * @arg {Constant.GamepadButton} _button A gamepad button
		 * @return {Bool} */
		static IsRightTrigger = function(_trigger) {
			return (_trigger == gp_shoulderrb);
		} 
		
		
		/** Sets the trigger effect for a shoulder button for a player
		 * 
		 * @arg {Struct.InputTriggerPlayer} _player The player to set the effect for
		 * @arg {Constant.GamepadButton} _button A gamepad shoulder lb/rb button
		 * @arg {Struct.InputGamepadTriggerEffect} _effect The effect to set
		 * @arg {Bool} _newSet `[=true]` If this is the first time this effect is being set for this button. Leave blank if not sure.
		 * @return {Undefined} */
		static SetTriggerEffect = function(_playerIndex, _trigger, _effect, _set) {
			var _gamepad = GetPlayerGamepad(_playerIndex);
			if (is_undefined(_gamepad)) {
				return;
			}
			
			var _triggerPlayer = players[_playerIndex];
			if (_triggerPlayer.IsPaused()) {
				return;
			}
			
			var _applied = Apply(_gamepad, _trigger, _effect, _triggerPlayer.GetStrength());
			
			if (_set) {
				var _intercepted = (_applied == false);
				if (IsLeftTrigger(_trigger)) {
					_triggerPlayer.SetEffect(true, _effect);
				}
				else if (IsRightTrigger(_trigger)) {
					_triggerPlayer.SetEffect(false, _effect);
				}
			}
		}
		
		/** Reapplies the trigger effects that are cached on the specified player
		 * 
		 * @arg {Real} _playerIndex The gamepad to reapply effects for
		 * @return {Undefined} */		
		static ReapplyPlayerTriggerEffects = function(_playerIndex = undefined) {
			//Recursively reapply effects to all players
			if (inputSystem.PlayerIndexIsRecursive(_playerIndex)) {
				var i = 0; repeat(INPUT_MAX_PLAYERS) {
					ReapplyPlayerTriggerEffects(i++);
				}
			}
			
			var _gamepad = GetPlayerGamepad(_playerIndex);
			if (!is_undefined(_gamepad)) {
				var _triggerPlayer = players[_playerIndex];
				var _strength = _triggerPlayer.GetStrength();	
				var _effectLeft = _triggerPlayer.GetEffect(true);
				var _effectRight = _triggerPlayer.GetEffect(false);	
				
				
				Apply(_gamepad, gp_shoulderlb, _effectLeft, _strength);
				Apply(_gamepad, gp_shoulderrb, _effectRight, _strength);
			}
		}		
		
		/**
		 * 
		 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to apply the trigger to
		 * @arg {Constant.GamepadButton} _trigger Can be constants `gp_shoulderlb` or `gp_shoulderrb`
		 * @arg {Struct.InputGamepadTriggerEffect} _effect The effect to apply
		 * @arg {Real} _strength The strength of the effect
		 * @return {Bool} */
		static Apply = function(_gamepad, _trigger, _effect, _strength) {
			var _bool = false;
			
			//lb = 0, rb = 1;
			
			//PS5 uses different trigger effect logic which is specific to each effect.
			if (INPUT_PS5) {
				_bool = _effect.ApplyPS5(_gamepad, _trigger, _strength);
			}
			else if (inputSystem.UsingSteamworks()) {
				var _steamHandle = _gamepad.GetSteamHandle();
				
				//Steam uses libScePad for dualSense trigger effects
				if (INPUT_WINDOWS && !inputSystem.UsingSteamWine() && !is_undefined(_steamHandle)) { 
					static steamTriggerData = {};
					static commands = [{}, {}];
					var _left = 0;
					var _right = 1;
					var _triggerIndex = (_trigger == gp_shoulderlb) ? _left : _right;
					
					
					//Apply strength to the effect
					var _data = _effect.GetData();
					_data.Modify(_strength);
					
					//Build Effect data for Steam
					var _key = "command_data";
					var _effectKey = $"{_effect.GetModeName()}_param";
					commands[_left][$ _key] = {};
					commands[_right][$ _key] = {};
					commands[_triggerIndex][$ _key][$ _effectKey] = _data;
					
					//Build Mode data for Steam
					_key = "mode"
					commands[_left][$ _key] = steam_input_sce_pad_trigger_effect_mode_off;
					commands[_right][$ _key] = steam_input_sce_pad_trigger_effect_mode_off;
					commands[_triggerIndex][$ _key] = steamModes[_effect.GetType()];
					
					
					//Build command for steam
					var _r2 = steam_input_sce_pad_trigger_effect_trigger_mask_r2;
					var _l2 = steam_input_sce_pad_trigger_effect_trigger_mask_l2;
					steamTriggerData[$ "command"] = commands;
					steamTriggerData[$ "trigger_mask"] = (_triggerIndex == _left) ? _l2 : _r2;
					
					_bool = steam_input_set_dualsense_trigger_effect(_steamHandle, steamTriggerData);
				}
			}
			return _bool;
		}
		
		/** Stops trigger effects for the specified gamepad
		 * 
		 * @arg {Struct.InputDeviceGamepad} [_gamepad] `[=undefined]` The gamepad to stop effects for. If no gamepad is specified, then all gamepad effects will be stopped.
		 * @return {Undefined} */
		static TriggerEffectStop = function(_gamepad = undefined) {
			//Recursively call stop for all gamepads
			if (is_undefined(_gamepad)) {
				var _gamepads = inputSystem.GamepadEnumerate();
				var i = 0; repeat(array_length(_gamepads)) {
					TriggerEffectStop(_gamepads[i++]);
				}
			}
			
			//It shouldn't happen, but just in case, ignore anything that isn't a gamepad
			if (_gamepad.GetType() != Input_DeviceType.gamepad) {
				return;
			}
			
			Apply(_gamepad, gp_shoulderlb, off, 0);
			Apply(_gamepad, gp_shoulderrb, off, 0);
		}
	#endregion
	
	
	
	#region Events
		
		/** Receivee a focus lost event notice and causes all gamepads to temporarily stop emitting trigger effects
		 * @return {Undefined} */		
		static OnFocusLost = function() {
			TriggerEffectStop();
		}
		
		/** Receive a focus gained event notice and causes all gamepads to reapply the trigger effects that were stopped due to a focus lost event
		 * @return {Undefined} */			
		static OnFocusGained = function() {
			ReapplyPlayerTriggerEffects();
		}
		
		/** Receive a player device changed event notice that causes the player to stop emitting trigger effects on their old device and start emitting them on the new device
		 * @arg {Real} _playerIndex The index of the player that triggered the event
		 * @arg {Struct.InputDeviceGamepad} _oldDevice The device that needs to stop emitting trigger effects
		 * @arg {Struct.InputDeviceGamepad} _newDevice The device that needs to start emitting trigger effects
		 * @return {Undefined} */		
		static OnPlayerDeviceChanged = function(_playerIndex, _oldDevice, _newDevice) {
			TriggerEffectStop(_oldDevice);
			ReapplyPlayerTriggerEffects(players[_playerIndex]);
		}
		
		/** Receive a system restart event notice that causes all gamepads to remove their trigger effects
		 * @return {Undefined} */
		static OnSystemRestart = function() {
			for (var i = 0; i < INPUT_MAX_PLAYERS) {
				PlayerSetTriggerEffectOff(i, gp_shoulderlb);
				PlayerSetTriggerEffectOff(i, gp_shoulderrb)
			}
		}
		
		
	#endregion
	
	
	#region Using the system
		
		/** Returns `true` if the specified player's device supports trigger effects which are unique to PS5 controllers
		 * @arg {Real} _playerIndex The index of the player to check
		 * @return {Bool} */
		static PlayerDeviceSupportsTriggerEffects = function(_playerIndex) {
			//Safer to assume false
			var _bool = false;
			
			//Check gamepad type
			var _gamepad = GetPlayerGamepad(_playerIndex);
			if (!is_undefined(_gamepad)) {
				_bool = (_gamepad.GetGamepadType() == Input_GamepadType.ps5); 
			}
			//Otherwise check platform type. If we're using steam we can let steam handle trigger effect compatibility when we try to set them
			else {
				_bool = (INPUT_PS5 || inputSystem.UsingSteamworks());
			}
			return _bool;
		}
		
		/** Simulates the feel of a trigger pull on a firearm when the player presses one of the trigger buttons on their gamepad.
		 * @arg {Real} _playerIndex The index of the player to set this effect for
		 * @arg {Constant.GamepadButton} _trigger The trigger button that should have the effect. Can be either one of `gp_shoulderlb` or `gp_shoulderrb` for the left or right triggers respectively.
		 * @arg {Real} _strength The strength of the effect
		 * @arg {Real} _start The break point of the effect from 0 to 1
		 * @arg {Real} _end The release point of the effect from 0 to 1
		 * @return {Undefined} */
		static PlayerSetTriggerEffectWeapon = function(_playerIndex, _trigger, _strength, _start, _end) {
			//Don't do work if the player doesn't use a gamepad
			var _gamepad = GetPlayerGamepad(_playerIndex);
			if (is_undefined(_gamepad)) {
				return;
			}
			
			//Collecting required data
			var _weapon = new InputGamepadTriggerEffectWeapon(_strength, _start, _end);
			var _triggerPlayer = players[_playerIndex];
			var _playerStrength = _triggerPlayer.GetStrength();
			
			//Apply the effect to the player's gamepad
			var _applied = Apply(_gamepad, _trigger, _weapon, _playerStrength);
			
			//Cache the effect in the player so we can reapply to other gamepads if needed
			_triggerPlayer.SetEffect(_trigger, _weapon, _applied);
		}
		
		/** Adds vibration to a player's gamepad at the pull of a trigger.
		 * @arg {Real} _playerIndex The index of the player to set this effect for
		 * @arg {Constant.GamepadButton} _trigger The trigger button that should have the effect. Can be either one of `gp_shoulderlb` or `gp_shoulderrb` for the left or right triggers respectively.
		 * @arg {Real} _position The analog axis value of the trigger for where the effect should activate. Between `0` and `1`.
		 * @arg {Real} _amplitude Amplitude of the vibration wave from `0` to `1`.
		 * @arg {Real} _frequency Frequency of the vibration wave from `0` to `1`.
		 * @return {Undefined} */
		static PlayerSetTriggerEffectVibration = function(_playerIndex, _trigger, _position, _amplitude, _frequency) {
			//Don't do work if the player doesn't use a gamepad
			var _gamepad = GetPlayerGamepad(_playerIndex);
			if (is_undefined(_gamepad)) {
				return;
			}		
			
			//Collecting required data
			var _vib = new InputGamepadTriggerEffectVibration(_position, _amplitude, _frequency);
			var _triggerPlayer = players[_playerIndex];
			var _playerStrength = _triggerPlayer.GetStrength();
			
			//Apply the effect to the player's gamepad
			var _applied = Apply(_gamepad, _trigger, _vib, _playerStrength);
			
			//Cache the effect in the player so we can reapply to other gamepads if needed
			_triggerPlayer.SetEffect(_trigger, _vib, _applied);
		}
		
		/** Adds vibration to a player's gamepad at the pull of a trigger.
		 * @arg {Real} _playerIndex The index of the player to set the effect for
		 * @arg {Constant.GamepadButton} _trigger The trigger button that should have the effect. Can be either one of `gp_shoulderlb` or `gp_shoulderrb` for the left or right triggers respectively.
		 * @arg {Real} _strength The strength of the effect from `0` to `1`.
		 * @return {Undefined} */
		static PlayerSetTriggerEffectFeedback = function(_playerIndex, _trigger, _position, _strength) {
			//Don't do work if the player doesn't use a gamepad
			var _gamepad = GetPlayerGamepad(_playerIndex);
			if (is_undefined(_gamepad)) {
				return;
			}
			
			//Collecting required data
			var _feed = new InputGamepadTriggerEffectFeedback(_position, _strength);
			var _triggerPlayer = players[_playerIndex];
			var _playerStrength = _triggerPlayer.GetStrength();
			
			//Apply the effect to the player's gamepad
			var _applied = Apply(_gamepad, _trigger, _feed, _playerStrength);
			
			//Cache the effect in the player so we can reapply to other gamepads if needed
			_triggerPlayer.SetEffect(_trigger, _feed, _applied);
		}
		
		/** Stops and removes the trigger effect assigned to a player.
		 * @arg {Real} _playerIndex The index of the player to set the effect for
		 * @arg {Constant.GamepadButton} _trigger `[=undefined]` The trigger button that should turn off effects. Can be any of `gp_shoulderlb` or `gp_shoulderrb` for the left or right triggers respectively, or set `undefined` or `all` for both triggers
		 * @return {Undefined} */		
		static PlayerSetTriggerEffectOff = function(_playerIndex, _trigger = undefined) {
			//Don't do anymore work if the player doesn't use a gamepad
			var _gamepad = GetPlayerGamepad(_playerIndex);
			if (is_undefined(_gamepad)) {
				return;
			}	
			
			//Recursively turn off for both triggers
			if (is_undefined(_trigger) || (_trigger == all)) {
				PlayerSetTriggerEffectOff(_playerIndex, gp_shoulderlb);
				PlayerSetTriggerEffectOff(_playerIndex, gp_shoulderrb);
				return;
			}		
			
			//Collecting required data
			var _triggerPlayer = players[_playerIndex];
			
			//Apply and cache
			var _applied = Apply(_gamepad, _trigger, off);
			_triggerPlayer.SetEffect(_trigger, off, _applied);
		}
		
		/** Allows you to fine tune the overall strength of the effects on a per-player basis
		 * @arg {Real} _playerIndex The index of the player you want to adjust strength for. Use `undefined` or `all` to set the strength for all players
		 * @arg {Real} _strength The "master" strength setting for the player. This value ultimately determines the final strength value for each effect assigned to this player
		 * @return {Undefined} */
		static PlayerSetEffectStrength = function(_playerIndex, _strength) {
			//Recursively set strength for all players so we can also reapply their effects with the new strength
			if (inputSystem.PlayerIndexIsRecursive(_playerIndex)) {
				var i = 0; repeat(INPUT_MAX_PLAYERS) {
					PlayerSetEffectStrength(i++, _strength);
				}
			}
			
			if (!inputSystem.ValidatePlayerIndex(_playerIndex)) {
				inputSystem.ThrowInvalidPlayerIndex("PlayerSetEffectStrength", _playerIndex, self);
			}			
			
			//Setting strength for the player
			var _triggerPlayer = players[_playerIndex];
			_triggerPlayer.SetStrength(_strength);
			
			//Reapply their effects so they use the new strength
			ReapplyPlayerTriggerEffects(_playerIndex);
		}
		
		/** Returns the strength modifier for the specified player. This modifier dampens how strong trigger effects for that player will be.
		 * @arg {Real} _playerIndex The index of the player to get strength from
		 * @return {Real} */
		static PlayerGetEffectStrength = function(_playerIndex) {
			if (!inputSystem.ValidatePlayerIndex(_playerIndex)) {
				inputSystem.ThrowInvalidPlayerIndex("PlayerGetEffectStrength", _playerIndex, self);
			}
			
			var _triggerPlayer = players[_playerIndex];
			return _triggerPlayer.GetStrength();
		}
		
		/** Set the pause state of a player's trigger effects
		 * @arg {Real} _playerIndex The index of the player to target. You can also set `all` or `undefined` to set the state for all players
		 * @arg {Bool} _bool Set `true` to pause effects or `false` to unpause them
		 * @return {Undefined} */
		static PlayerSetEffectsPaused = function(_playerIndex, _pause) {
			//Recursively pause or unpause all players
			if (inputSystem.PlayerIndexIsRecursive(_playerIndex)) {
				var i = 0; repeat(INPUT_MAX_PLAYERS) {
					PlayerSetEffectsPaused(i++, _pause);
				}
			}
			
			var _triggerPlayer = players[_playerIndex];
			_triggerPlayer.SetPaused(_pause);
		}
		
		/** Returns `true` if trigger effects for the specified player are paused
		 * @arg {Real} _playerIndex The index of the player to check
		 * @return {Bool} */
		static PlayerEffectsArePaused = function(_playerIndex) {
			if (!inputSystem.ValidatePlayerIndex(_playerIndex)) {
				inputSystem.ThrowInvalidPlayerIndex("PlayerEffectsArePaused", _playerIndex, self);
			}
			return players[_playerIndex].IsPaused();
		}
		
		/** Returns the steam state of the trigger effect for the specified player
		 * @arg {Real} _playerIndex The index of the player to check
		 * @arg {Constant.GamepadButton} _trigger The trigger to check. Can be `gp_shoulderrb` or `gp_shoulderlb`
		 * @return {Constant.Input_TriggerEffectState} */ 
		static PlayerGetTriggerEffectSteamState = function(_playerIndex, _trigger) {
			//If we don't have a valid trigger button, return off so we don't do extra work
			if (!IsTrigger(_trigger)) {
				ThrowInvalidType("PlayerGetTriggerEffectSteamState", "_trigger", _trigger, "gp_shoulderrb or gp_shoulderlb");
			}
			
			//Make sure our gamepad is connected
			var _gamepad = GetPlayerGamepad(_playerIndex);
			if (inputSystem.DeviceIsConnected(_gamepad)) {
				var _triggerPlayer = players[_playerIndex];
				
				//Check variousIntercepted options by what's most likely for slightly quicker return
				if (_triggerPlayer.IsPaused()) {
					return Input_TriggerEffectState.intercepted;
				}
				var _effect = undefined;
				if (IsLeftTrigger(_trigger)) {
					if (_triggerPlayer.IsInterceptedLeft()) {
						return Input_TriggerEffectState.intercepted;
					}
					_effect = _triggerPlayer.GetEffect(true);
				}
				else {
					if (_triggerPlayer.IsInterceptedRight()) {
						return Input_TriggerEffectState.intercepted;
					}
					_effect = _triggerPlayer.GetEffect(false);
				}
				
				//If we're still here, check the effect state directly
				return _effect.GetSteamState(_gamepad, _trigger);
			}
			
			//Return off if we don't have a device to check
			else {
				return Input_TriggerEffectState.off;
			}
		}
		
	#endregion
	
	
	//Initializing our players
	var i = 0; repeat(INPUT_MAX_PLAYERS) {
		players[i] = new InputTriggerEffectPlayer(i);
		i++;
	}
	
	//Setting up steam modes
	if (inputSystem.UsingSteamworks()) {
		steamModes[Input_TriggerEffectType.off] = steam_input_sce_pad_trigger_effect_mode_off;
		steamModes[Input_TriggerEffectType.feedback] = steam_input_sce_pad_trigger_effect_mode_feedback;
		steamModes[Input_TriggerEffectType.weapon] = steam_input_sce_pad_trigger_effect_mode_weapon;
		steamModes[Input_TriggerEffectType.vibration] = steam_input_sce_pad_trigger_effect_mode_vibration;
	}		
}