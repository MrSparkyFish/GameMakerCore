//feather ignore all
 
/** InputColorSystem: An `InputSystem` plug-in that allows you to change gamepad colors
 * @return {Struct.InputColorSystem} */
function InputColorSystem() constructor {
	static inputSystem = InputSystem.singleton;
	colors = array_create(INPUT_MAX_PLAYERS, undefined);
	
	
	
	/** Set the color of the specified gamepad
	 * 
	 * @arg {Struct.InputDeviceGamepad} _gamepad
	 * @arg {Real} _color
	 * @return {Undefined} */
	static SetGamepadColor = function(_gamepad, _color = undefined) {
		_color ??= 0;
		var _index = _gamepad.GetIndex();
		if (inputSystem.UsingSteamworks()) {
			var _steamHandle = _gamepad.GetSteamHandle();
			if (!is_undefined(_steamHandle)) {
				var _ledFlag = (_color > 0) ? steam_input_led_flag_set_color : steam_input_led_flag_restore_user_default;
				steam_input_set_led_color(_steamHandle, _color, _ledFlag);
			}
		}
		
		else if (INPUT_PLAYSTATION) {
			if (_color <= 0) {
				if (INPUT_PS5) {
					ps4_gamepad_reset_color(_index);
					ps5_gamepad_reset_color(_index)
				}
			}
			else {
				gamepad_set_color(_index, _color);
			}
		}
	}
	
	/** Returns `true` if the specified gamepad supports color
	 * 
	 * @arg {Struct.InputDeviceGamepad} _gamepad
	 * @return {Undefined} */
	static GamepadSupportsColor = function(_gamepad) {
		var _bool = false;
		if (inputSystem.UsingSteamworks()) {
			var _steamHandle = _gamepad.GetSteamHandle();
			if (!is_undefined(_steamHandle)) {
				_bool = _gamepad.IsPlayStationController();
			}
		}
		else if (INPUT_PLAYSTATION) {
			_bool = inputSystem.DeviceIsConnected(_gamepad);
		}
		return _bool;
	}
	
	
	/**
	 * 
	 * @return {Undefined} */
	static OnPlayerDeviceChanged = function(_playerIndex, _oldDevice, _newDevice) {
		var _color = colors[_playerIndex];
		SetGamepadColor(_newDevice, _color);
	}
	
	
	static OnSystemRestart = function() {
		for (var i = 0; i < INPUT_MAX_PLAYERS; i++) {
			PlayerResetColor(i);
		}
	}
	
	
	/** Check if a players active device supports color changes
	 * @arg {Real} _playerIndex
	 * @return {Bool} */
	static DeviceSupportsColor = function(_playerIndex) {
		var _player = inputSystem.GetPlayer(_playerIndex);
		if (_player.UsesGamepad()) {
			return GamepadSupportsColor(_player.GetDevice());
		}
		return false;
	}
	
	/** Set a color to be used by a player
	 * @arg {Real} _playerIndex
	 * @arg {Real} _color
	 * @return {Undefined} */
	static PlayerSetColor = function(_playerIndex, _color) {
		colors[_playerIndex] = _color;
		
		if (DeviceSupportsColor(_playerIndex)) {
			var _device = inputSystem.PlayerGetDevice(_playerIndex);
			SetGamepadColor(_device, _color);
		}
	} 
	
	/** Returns the color index set for a player
	 * @return {Real} */
	static PlayerGetColor = function(_playerIndex) {
		return colors[_playerIndex];
	}
	
	/** Reset a player's device color
	 * @return {Undefined} */
	static PlayerResetColor = function(_playerIndex) {
		PlayerSetColor(_playerIndex, undefined);
	}
	
}