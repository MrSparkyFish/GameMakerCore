//feather ignore all

/** InputRumbleSystem: An input plug-in that provides gamepad rumble features.
 * @return {Struct.InputRumbleSystem} */
function InputRumbleSystem() constructor {
	
	
	
	#region Private
		
		static inputSystem = InputSystem.singleton;							//Needs access to input system
		gamepadMap = {};													//Map of InputDeviceGamepads to their vibrators
		vibrators = [];														//Array of vibrators for easier cycling
		players = array_create(INPUT_MAX_PLAYERS);							//Array of player rumble data
		
		/** Attempts to return the vibrator assigned to the specified gamepad. Returns `undefined` if no vibrator was assigned.
		 * @ignore
		 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to get the vibrator for
		 * @return {Struct.InputGamepadVibrator} */ 
		static GetGamepadVibrator = function(_gamepad) {
			return StructTryGetMember(gamepadMap, _gamepad);
		}	
		
		/** Adds a rumble event to the specified player
		 * @ignore
		 * @arg {Real} _playerIndex The index of the player to add the event to
		 * @arg {Struct.InputGamepadRumbleEvent} _event The gamepad rumble event to use
		 * @return {Undefined} */
		static PlayerAddEvent = function(_playerIndex, _event) {
			var _vibratePlayer = players[_playerIndex];
			_vibratePlayer.AddRumbleEvent(_event);
		}	
		
		/** When a gamepad is connected to the `InputSystem` a `InputGamepadVibrator` is created and assigned to it.
		 * @ignore
		 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad that was connected.
		 * @return {Undefined} */
		static OnGamepadConnected = function(_gamepad) {
			var _vibrator = new InputGamepadVibrator(_gamepad, self);
			gamepadMap[$ _gamepad] = _vibrator;
			array_push(vibrators, _vibrator);
		}
		
		/** When a gamepad is disconnected from the system, its assigned vibrator is also removed.
		 * @ignore
		 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad that was disconnected
		 * @arg {Bool} _fullDisconnect If the gamepad was fully disconnected or not
		 * @return {Undefined} */
		static OnGamepadDisconnected = function(_gamepad, _fullDisconnect) {
			var _vibrator = GetGamepadVibrator(_gamepad);
			if (!is_undefined(_vibrator)) {
				_vibrator.VibrateGamepad(0, 0);
				struct_remove(gamepadMap, _gamepad);
				ArrayRemove(_vibrator);
			}
		}
		
		/** When the `InputSystem` is updated, all gamepad vibrators are also updated
		 * @ignore
		 * @return {Undefined} */
		static OnUpdate = function() {
			//Loop through each player so we can update their gamepads with their rumble info
			for (var i = 0; i < INPUT_MAX_PLAYERS; i++) {
				
				//Get the current player and their rumble data
				var _player = inputSystem.GetPlayer(i);
				
				//Only gamepads can rumble. Also gamepads should only rumble if there's a player actually using them.
				if (_player.IsConnected() && _player.UsesGamepad()) {
					var _rumblePlayer = players[i];
					
					//Only evaluate vibration if they have rumble turned on
					if (_rumblePlayer.IsEnabled()) {
						var _gamepad = _player.GetDevice();
						var _vibrator = GetGamepadVibrator(_gamepad);
						var _events = _rumblePlayer.GetRumbleEvents();
						
						//Update the strength of the gamepad's motors using the players set strength and filter out paused components.
						_vibrator.UpdateMotorStrength(_rumblePlayer.GetRumbleEvents, _rumblePlayer.GetStrength(), _rumblePlayer.IsPaused());
					}					
				}
			}
			
			//After motor strength is updated for each player's gamepad, we rumble the motors of all gamepads at the same time
			//This is kept separate from the previous loop so that the actual motors are updated independently of their users.
			if (inputSystem.GameHasFocus()) {
				var _len = array_length(vibrators);
				for (var i = 0; i < _len; i++) {
					var _vibrator = vibrators[i];
					_vibrator.UpdateRumble();
				}				
			}
		}
		
		/** Removes all vibration components from each gamepad.
		 * @ignore
		 * @return {Undefined} */
		static OnSystemRestart = function() {
			var i = 0; repeat(array_length(vibrators)) {
				var _player = players[i++];
				_player.RemoveAllRumbleEvents();
			}
		}
		
	#endregion
	
	
	#region Vibration
		
		/** Adds an ADSR gamepad rumble event to a player. This type of vibration using an "Attack-Decay-Sustain-Release" curve.
		 * @arg {Real} _playerIndex The player to target with the event.
		 * @arg {Real} _peakStrength Peak strength of the vibration event at the top of the attack portion of the curve from 0 to 1.
		 * @arg {Real} _sustainLevel Strength of the sustain portion of the curve relative to the attack portion from 0 to 1
		 * @arg {Real} _bias Left-to-right motor bias for the vibration event where -1 only vibrates the left motor and 1 only vibrates the right motor.
		 * @arg {Real} _attack Duration of the attack portion of the curve (milliseconds)
		 * @arg {Real} _decay Duration of the decay portion of the curve (milliseconds)
		 * @arg {Real} _sustain Duration of the sustain portion of the curve (milliseconds)
		 * @arg {Real} _release Duration of the release portion of the curve (milliseconds)
		 * @arg {Bool} [_force] `[=false]` Whether this vibration event should ignore "vibration paused" state of the gamepad. 
		 * @return {Undefined} */
		static RumbleADSR = function(_playerIndex, _peakStrength, _sustainLevel, _bias, _attack, _decay, _sustain, _release, _force = false) {
			var _event = new InputGamepadRumbleEventADSR(_peakStrength, _sustainLevel, _bias, _attack, _decay, _sustain, _release, _force);
			PlayerAddEvent(_playerIndex, _event);
		}
		
		/** Makes a players gamepad rumble using a constant strength for the duration
		 * @arg {Real} _playerIndex The player to target with the event.
		 * @arg {Real} _strength Strength of the vibration from 0 to 1
		 * @arg {Real} _bias Left-Right motor bias where -1 is left motor only and 1 is right motor only
		 * @arg {Real} _duration Duration of the vibration event (milliseconds)
		 * @arg {Bool} [_force] `[=false]` Whether or not the "vibration paused" state should be ignored.
		 * @return {Undefined} */
		static RumbleSustain = function(_playerIndex, _strength, _bias, _duration, _force = false) {
			var _event = new InputGamepadRumbleEventSustain(_strength, _bias, _duration, _force);
			PlayerAddEvent(_playerIndex, _event);
		}
		
		/** Makes a players gamepad rumble using a curve
		 * @arg {Real} _playerIndex The player to target with the event.
		 * @arg {Real} _strength Peak strength of the vibration event at the top of the attack portion of the curve from 0 to 1.
		 * @arg {Struct.Curve} _curve The curve to use for vibration and intensity
		 * @arg {Real} _bias Left-to-right motor bias for the vibration event where -1 only vibrates the left motor and 1 only vibrates the right motor.  
		 * @arg {Real} _duration Duration of the vibration event (milliseconds)
		 * @arg {Bool} [_force] `[=false]` Whether this vibration event should ignore "vibration paused" state of the gamepad.  
		 * @return {Undefined} */	
		static RumbleCurve = function(_playerIndex, _strength, _curve, _bias, _duration, _force) {
			var _event = new InputGamepadRumbleEventCurve(_curve, _strength, _bias, _duration, _force);
			PlayerAddEvent(_playerIndex, _event);
		}
		
		/** Makes a players gamepad rumble using a set number of pulses over a duration
		 * @arg {Real} _playerIndex The player to target with the event.
		 * @arg {Real} _strength Peak strength of the vibration event at the top of the attack portion of the curve from 0 to 1.
		 * @arg {Real} _bias Left-to-right motor bias for the vibration event where -1 only vibrates the left motor and 1 only vibrates the right motor.  
		 * @arg {Real} _duration Duration of the vibration event (milliseconds)
		 * @arg {Bool} _pulseCount The number of vibration pulses to execute over the duration
		 * @arg {Bool} [_force] `[=false]` Whether this vibration event should ignore "vibration paused" state of the gamepad.  
		 * @return {Undefined} */	
		static RumblePulse = function(_playerIndex, _strength, _bias, _duration, _pulseCount, _force) {
			var _event = new InputGamepadRumbleEventPulse(_strength, _bias, _duration, _pulseCount, _force);
			PlayerAddEvent(_playerIndex, _event);
		}
		
	#endregion	
	
	
	
	//Main
	var i = 0; repeat(INPUT_MAX_PLAYERS) {
		var _vibratePlayer = new InputRumblePlayer();
		players[i++] = _vibratePlayer;
	}
	
	//Registering with events
	var _events = inputSystem.GetEvents();
	_events.GetOnUpdate().AddStatic(self, OnUpdate);
	_events.GetOnSystemRestart().AddStatic(self, OnSystemRestart);
	_events.GetOnGamepadConnected().AddStatic(self, OnGamepadConnected);
	_events.GetOnGamepadDisconnected().AddStatic(self, OnGamepadDisconnected);
}