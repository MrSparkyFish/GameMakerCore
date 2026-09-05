//feather ignore all

/**
 * @arg {Struct.InputDeviceGamepad} _device
 * @return {} */
function InputMotion(_device) constructor {
	
	enum Input_MotionFlags {
		calibrated,
		supported
	}
	
	///@ignore
	static inputSystem = InputSystem.singleton;						//Gives us access to internal input functions
	///@ignore
	static c = 570.6;												//Angular velocity coefficient constant. DO NOT CHANGE
	///@ignore
	static d = 5;													//Angular velocity divisor constant. DO NOT CHANGE
	///@ignore
	static m = 1/16384;												//Acceleration multiplier constant. DO NOT CHANGE
	
	///@ignore
	calibration = new Quaternion();									//Our identity quaternion for this gamepad
	///@ignore
	device = _device;
	///@ignore
	rotation = new Quaternion();
	///@ignore
	acceleration = new Vector3();
	///@ignore
	angularVelocity = new Vector3();
	///@ignore
	eulersAngles = new Vector3();
	///@ignore
	flags = new BitMask();
	
	if (INPUT_SWITCH || INPUT_PS4 || INPUT_PS5) {
		//Console platforms are presumed to always have motion data available for their first-party gamepads
		flags.SetBitState(Input_MotionFlags.supported, device.IsType(Input_DeviceType.gamepad));
	}
	
	else if ((INPUT_WINDOWS || INPUT_LINUX) && inputSystem.UsingSteamworks()) {
		var _steamHandle = device.GetSteamHandle();
		var _bool = is_numeric(_steamHandle && is_struct(steam_input_get_motion_data(_steamHandle)));
		flags.SetBitState(Input_MotionFlags.supported, _bool);
	}
	
	/** Returns a copy of the gyroscopes current rotation as Euler's angles
	 * @return {Struct.Vector3$$Instance} */
	static GetGyroscopeAngles = function() {
		return eulersAngles.Clone();
	}
	
	/** Returns a copy of the current gyroscope XYZ speed
	 * @return {Struct.Vector3$$Instance} */
	static GetAcceleration = function() {
		return acceleration.Clone();
	}
	
	
	/** Returns `true` if this input motion handler has been calibrated with its assigned gamepad device.
	 * @return {Bool} */
	static IsCalibrated = function() {
		return flags.IsBitActive(Input_MotionFlags.calibrated);
	}
	
	
	static IsSupported = function() {
		return flags.IsBitActive(Input_MotionFlags.supported);
	}
	
	/** Resets motion controls to a neutral state
	 * @return {Undefined} */
	static Clear = function() {
		acceleration = Vector3.Up();
		angularVelocity = new Vector3();
		rotation =  new Quaternion();
		eulersAngles = new Vector3();
	}
	
	/** Sets the calibration (identity) rotation of this motion handler to the current rotation of its representing gamepad device
	 * @return {Undefined} */
	static Calibrate = function() {
		calibration.SetFromVector(rotation);
		flags.EnableBit(Input_MotionFlags.calibrated);
	}
	
	/** Process motion control input for the gamepad device assigned to this handler
	 * @return {Undefined} */
	static Update = function() {
		//Take a break if not focused on game
		if (!inputSystem.GameHasFocus()) {
			return;
		}
		
		var _index = device.GetIndex();
		
		//Motion Controls for switch
		if (INPUT_SWITCH) {
			var _axisX = switch_controller_axis_x;
			var _axisZ = switch_controller_axis_y;
			var _signX = 1;
			var _signZ = 1;
			var _sensor = 0;
			
			var _type = device.GetType();
			if (_type == Input_GamepadType.nintendoSwitch) {
				if (device.GetDescription() == "SwitchJoyConPair") {
					_sensor = 1;
				}
			}
			else if (_type == Input_GamepadType.joyconLeft) {
				_axisX = switch_controller_axis_y;
				_axisZ = switch_controller_axis_x;
				_signX = -1;
			}
			else if (_type == Input_GamepadType.joyconRight) {
				_axisX = switch_controller_axis_y;
				_axisZ = switch_controller_axis_x;
				_signZ = -1;				
			}
			
			acceleration.Set(
				_signX * switch_controller_acceleration(_index, _axisX, _sensor),
				-switch_controller_acceleration(_index, switch_controller_axis_z, _sensor),
				_signZ * switch_controller_acceleration(_index, _axisZ, _sensor)
			);
			
			angularVelocity.Set(
				_signX * degtorad(switch_controller_angular_velocity(__device, _axisX, _sensor)/d) * c,
				-degtorad(switch_controller_angular_velocity(__device, switch_controller_axis_z, _sensor)/d) * c,
				angularVelocityZ = _signZ * degtorad(switch_controller_angular_velocity(__device, _axisZ, _sensor)/d) * c
			);
			
		}
		
		//Motion controls on playstation
		else if (INPUT_PLAYSTATION) {
			var _index = device.GetIndex();
			acceleration.Set(
				gamepad_axis_value(__device, gp_axis_acceleration_x),
				-gamepad_axis_value(__device, gp_axis_acceleration_y),
				-gamepad_axis_value(__device, gp_axis_acceleration_z)
			);
			
			angularVelocity.Set(
				gamepad_axis_value(__device, gp_axis_angular_velocity_x) / pi,
				-gamepad_axis_value(__device, gp_axis_angular_velocity_y) / pi,
				-gamepad_axis_value(__device, gp_axis_angular_velocity_z) / pi
			);
		}
		
		//Motion Controls on linux/windows
		else if (INPUT_LINUX || INPUT_WINDOWS) {
			var _steamHandle = device.GetSteamHandle();
			if (is_numeric(_steamHandle)) {
				
				var _steamData = steam_input_get_motion_data(_steamHandle);
				if (!is_struct(_steamData)) {
					//Device isn't returning motion data so we have to clear
					flags.DisableBit(Input_MotionFlags.supported);
					return Clear();
				}
				
				flags.EnableBit(Input_MotionFlags.supported);
				acceleration.Set(
					_steamData.pos_accel_x * m,
					-_steamData.pos_accel_y * m,
					-_steamData.pos_accel_z * m
				);
				rotation.Set(
					_steamData.rot_quat_x,
					_steamData.rot_quat_y,
					_steamData.rot_quat_z,
					_steamData.rot_quat_w
				);
				
				
				var q = calibration.Conjugate().Multiply(rotation).Normalize();
				
				//Convert to Euler's angles
				var _eulersAngles = q.GetEulersAngles();
				
				//Deliberately reassigning Euler's angles. This is because the standard quaternion coordinate system
				//doesn't match up with the assumed coordinate system of a gamepad so we have to manually correct by reversing the order
				angularVelocity.Set(
					_eulersAngles.z - eulersAngles.z,
					_eulersAngles.y - eulersAngles.y,
					_eulersAngles.x - eulersAngles.x
				);
				
				//Update our eulersAngles so we have them for next frame
				eulersAngles.SetFromVector(_eulersAngles);
			}
		}
		
		else {
			Clear();
		}
	}
}