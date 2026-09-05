//feather ignore all

/** InputMotionSystem: An `InputSystem` plug-in that allows you to use motion controls in your game.
 * @return {Struct.InputMotionSystem} */
function InputMotionSystem() constructor {
	
	
	#region Private
		
		static inputSystem = InputSystem.singleton;
		devices = {};
		handlers = [];
		
		
		/** Creates a motion handler for the gamepad
		 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad that was connected
		 * @return {Undefined} */
		static OnGamepadConnected = function(_gamepad) {
			var _handler = new InputMotion(_gamepad);
			array_push(handlers, _handler);
			StructSetMemberUnique(devices, _gamepad, _handler);
		}
		
		/** Removes the motion control handler for the disconnected gamepad
		 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad that was disconnected
		 * @return {Undefined} */
		static OnGamepadDisconnected = function(_gamepad) {
			var _handler = devices[$ _gamepad];
			struct_remove(devices, _gamepad);
			ArrayRemove(handlers, _handler);
		}
		
		/** Update motion tracking for all motion devices
		 * @return {Undefined} */
		static OnUpdate = function() {
			var i = 0; repeat(array_length(handlers)) {
				handlers[i++].Update();
			}
		}
		
		/** Returns the motion handler assigned to the specified gamepad
		 * @arg {Struct.InputDeviceGamepad} _gamepad
		 * @return {Struct.InputMotion} */
		static FindHandler = function(_gamepad) {
			return devices[$ _gamepad];
		}
		
		/** Contains extracted motion control data for a gamepad:
		 * * `acceleration` - A vector3 storing XYZ motion speed
		 * * `eulerAngles` - A vector3 storing the gamepads XYZ gyroscope rotation
		 * @ignore
		 * @arg {Struct.InputMotion} _motion
		 * @return {Struct.InputMotionSystem$$MotionData} */
		static MotionData = function(_motion) constructor {
			acceleration = _motion.GetAcceleration();
			eulerAngles = _motion.GetGyroscopeAngles();
		}
		
	#endregion
	
	/** Returns `true` if the current platform supports motion controls
	 * @return {Undefined} */
	static PlatformSupportsMotion = function() {
		static supported = ((INPUT_SWITCH || INPUT_PLAYSTATION) || ((INPUT_WINDOWS || INPUT_LINUX) && inputSystem.UsingSteamworks()));
		return supported;
	}
	
	/** Calibrate motion controls for the specified player
	 * @arg {Real} _playerIndex
	 * @return {Undefined} */
	static MotionCalibrate = function(_playerIndex) {
		var _gamepad = inputSystem.PlayerGetDevice(_playerIndex);
		if (!is_undefined(_gamepad)) {
			if (_gamepad.IsType(Input_DeviceType.gamepad)) {
				var _handler = FindHandler(_gamepad);
				_handler.Calibrate();
			}
		}
	}
	
	/** Returns motion control data for the specified player
	 * @arg {Real} _playerIndex
	 * @return {Struct.InputMotionSystem$$MotionData} */
	static PlayerMotionData = function(_playerIndex) {
		var _gamepad = inputSystem.PlayerGetDevice(_playerIndex);
		var _handler = FindHandler(_gamepad);
		return new MotionData(_handler);
	}
	
	/** Returns `true` if the gamepad used by a player has been calibrated for motion input. Always returns `false` if the specified player isn't using a gamepad.
	 * @arg {Real} _playerIndex
	 * @return {Bool} */
	static PlayerMotionIsCalibrated = function(_playerIndex) {
		var _gamepad = inputSystem.PlayerGetDevice(_playerIndex);
		if (!_gamepad.IsType(Input_DeviceType.gamepad)) {
			return false;
		}
		else {
			var _handler = FindHandler(_gamepad);
			return _handler.IsCalibrated();
		}
	}
	
	/** Returns `true` if motion controls are supported by the device being used by a player
	 * @arg {Real} _playerIndex
	 * @return {Bool} */
	static PlayerMotionIsSupported = function(_playerIndex) {
		var _gamepad = inputSystem.PlayerGetDevice(_playerIndex);
		if (!_gamepad.IsType(Input_DeviceType.gamepad)) {
			return false;
		}
		else {
			var _handler = FindHandler(_gamepad);
			return _handler.IsSupported();
		}
	}
	
	if (PlatformSupportsMotion()) {
		//Register with system events only if motion is actually supported
		var _events = inputSystem.GetEvents();
		_events.GetOnGamepadConnected().AddStatic(self, OnGamepadConnected);
		_events.GetOnGamepadDisconnected().AddStatic(self, OnGamepadDisconnected);
		_events.GetOnUpdate().AddStatic(self, OnUpdate);
	}
}