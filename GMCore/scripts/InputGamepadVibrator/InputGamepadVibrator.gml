//feather ignore all

/** InputGamepadVibrator: This object evaluates the magnitudes of the `InputRumbleEvents` that are fed to it by the `InputRumbleSystem`.
 * The evaluated magnitude is then set for the gamepad assigned to this vibrator. Fed events that no longer have any duration are consumed
 * and terminated. 
 * @arg {Struct.InputDeviceGamepad} _gamepad
 * @return {Struct.InputGamepadVibrator} */
function InputGamepadVibrator(_gamepad) constructor {
	
	
	enum Input_VibrateGamepadFlags {
		vibrating,
		supported,
	}
	
	
	#region Private
		///@ignore
		gamepad = _gamepad;												//The gamepad this vibrator vibrates
		///@ignore
		left = 0;														//Cached value to set for the left motor
		///@ignore
		right = 0;														//Cached value to set for the right motor
		///@ignore
		calibrationStrength = 1;										//Calibration strength of the gamepad itself
		///@ignore
		flags = new BitMask();											//Tracks flags for this gamepad
		
	#endregion
	
	
	
	#region Vibration
		/** Set if this gamepad is vibrating or not
		 * @arg {Bool} _bool 
		 * @return {Undefined} */
		static SetVibrating = function(_bool) {
			flags.SetBitState(Input_VibrateGamepadFlags.vibrating, _bool);
		}
		
		/** Returns `true` if this gamepad is actively vibrating.
		 * @return {Bool} */
		static IsVibrating = function() {
			return flags.IsBitActive(Input_VibrateGamepadFlags.vibrating);
		}	
		
		/** Sets the values of a gamepad's left and right motors.
		 * @arg {Real} _left The value to set for the left motor
		 * @arg {Real} _right The value to set for the right motor
		 * @return {Undefined} */
		static VibrateGamepad = function(_left, _right) {
			var _index = gamepad.GetIndex();
			if (INPUT_SWITCH) {
				var _type = gamepad.GetType();
				if ((_type == Input_GamepadType.joyconLeft) || (_type == Input_GamepadType.joyconRight)) {
					//Documentation said to use switch_controller_motor_single for these two controller types but I'll be damned if I can feel any difference!
					switch_controller_vibrate_hd(_index, switch_controller_motor_single, max(_left, _right), 250, max(_left, _right), 160);
				}
				else {
					switch_controller_vibrate_hd(_index, switch_controller_motor_left,  _left,  250, _left,  160);
					switch_controller_vibrate_hd(_index, switch_controller_motor_right, _right, 250, _right, 160);				
				}
			}
			//Standard set
			else {
				var _steamHandle = gamepad.GetSteamHandle();
				if (!is_undefined(_steamHandle)) {
					steam_input_trigger_vibration(_steamHandle, 65535*_left, 65535*_right);
				}
				
				else if (INPUT_FIX_PS_NATIVE_VIBRATION_SIDE && (gamepad.IsPlayStationController())) {
					gamepad_set_vibration(_index, _right, _left);
				}
				else {
					gamepad_set_vibration(_index, _left, _right);
				}
			}				
		}
		
		/** Updates the gamepad motor strength using the specified strength and boolean filter. 
		 * @arg {Struct.InputRumblePlayer} _rumblePlayer The rumble player with the data needed to activate this gamepad's vibration motors
		 * @return {Undefined} */
		static UpdateMotorStrength = function(_rumblePlayer) {
			var _events = _rumblePlayer.GetRumbleEvents();
			var _len = array_length(_events);
			
			//Don't do work if there's no work to be done.
			if (_len <= 0) {
				return;
			}
			
			//These values will be modified by each vibrator component
			var _left = 0;
			var _right = 0;
			
			
			
			//Cycle through each component
			var i = 0; repeat(_len) {
				var _event = _events[i];
				//Only evalute if vibration isn't supposed to be paused or if the component is forcing vibration
				if (!_rumblePlayer.IsPaused() || _event.GetForced()) {
					_event.Update();
					
					//Collect the left/right motor magnitude
					var _mag = _event.GetEvaluatedMagnitude();
					_left = _mag.x;
					_right = _mag.y;
				}
				
				//If the component is finished with its duration then it needs to be removed
				if (_event.IsFinished()) {
					array_delete(_events, i, 1);
				}
				//Only increment if the current component wasn't removed. Otherwise we would be skipping event.
				else {
					i++
				}
			}
			
			//Update the motor values of the vibrator
			var _strength = _rumblePlayer.GetStrength();
			left = _left * _strength;
			right = _right * _strength;
			IsVibrating(true);
		}	
		
		/** Updates the left and right motor values of the assigned gamepad according to the current state of the vibrator.
		 * @return {Undefined} */
		static UpdateRumble = function() {
			if (IsSupported() && IsVibrating()) {
				VibrateGamepad(calibrationStrength * left, calibrationStrength * right);
				SetVibrating(false);
			}
			else {
				VibrateGamepad(0, 0);
			}
		}
	#endregion
	
	/** Returns `true` if this gamepad supports vibration
	 * @return {Bool} */
	static IsSupported = function() {
		return flags.IsBitActive(Input_VibrateGamepadFlags.supported);
	}
	
	//Main
	//index < 4 = XInput
	var _gpIndex = gamepad.GetIndex();
	if ((INPUT_WINDOWS && (_gpIndex < 4)) || !INPUT_WINDOWS) {
		flags.SetBitState(Input_VibrateGamepadFlags.supported, true);
		
		if (INPUT_PS5) {
			ps5_gamepad_set_vibration_mode(_gpIndex, ps5_gamepad_vibration_mode_compatible);
		}
		else {
			if ((INPUT_WINDOWS || INPUT_SWITCH) && gamepad.IsSwitchController()) {
				calibrationStrength = INPUT_VIBRATION_JOYCON_STRENGTH;
			}
		}
		VibrateGamepad(0, 0);
	}
	
}