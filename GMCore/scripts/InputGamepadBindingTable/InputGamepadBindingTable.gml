//Feather ignore all

/** Represents the button map for gamepads with default button values.
 * @return {Struct.InputGamepadBindingTable} */
function InputGamepadBindingTable() constructor {
	
	/** Fix method for negative axis values lh, lv, rh, rv
	 * @ignore
	 * @arg {Real} _deviceIndex which gamepad device "slot" to check
	 * @arg {Constant.GamepadAxis} _axisIndex The axis index to check
	 * @return {Real} */
	static GamepadAxisValueFix = function(_deviceIndex, _axisIndex) {
		return gamepad_axis_value(_deviceIndex, abs(_axisIndex));
	}
	
	
	//face buttons
	self[$ gp_face1] = gamepad_button_value;
	self[$ gp_face2] = gamepad_button_value;
	self[$ gp_face3] = gamepad_button_value;
	self[$ gp_face4] = gamepad_button_value;
	
	//triggers
	self[$ gp_shoulderl] = gamepad_button_value;
	self[$ gp_shoulderr] = gamepad_button_value;
	self[$ gp_shoulderlb] = gamepad_button_value;
	self[$ gp_shoulderrb] = gamepad_button_value;
	
	//Paddles
	self[$ gp_paddler] = gamepad_button_value;
	self[$ gp_paddlel] = gamepad_button_value;
	self[$ gp_paddlerb] = gamepad_button_value;
	self[$ gp_paddlelb] = gamepad_button_value;
	
	//system
	self[$ gp_select] = gamepad_button_value;
	self[$ gp_start] = gamepad_button_value;
	self[$ gp_home] = gamepad_button_value;
	self[$ gp_touchpadbutton] = gamepad_button_value;
	
	//sticks
	self[$ gp_stickl] = gamepad_button_value;
	self[$ gp_stickr] = gamepad_button_value;
	self[$ gp_axislh] = gamepad_axis_value;
	self[$ gp_axislv] = gamepad_axis_value;
	self[$ gp_axisrh] = gamepad_axis_value;
	self[$ gp_axisrv] = gamepad_axis_value;
	self[$ -gp_axislh] = GamepadAxisValueFix;
	self[$ -gp_axislv] = GamepadAxisValueFix;
	self[$ -gp_axisrh] = GamepadAxisValueFix;
	self[$ -gp_axisrv] = GamepadAxisValueFix;
	
	//dpad
	self[$ gp_padd] = gamepad_button_value;
	self[$ gp_padu] = gamepad_button_value;
	self[$ gp_padr] = gamepad_button_value;
	self[$ gp_padl] = gamepad_button_value;
	
	//extras
	self[$ gp_extra1] = gamepad_button_value;
	self[$ gp_extra2] = gamepad_button_value;
	self[$ gp_extra3] = gamepad_button_value;
	self[$ gp_extra4] = gamepad_button_value;
	self[$ gp_extra5] = gamepad_button_value;
	self[$ gp_extra6] = gamepad_button_value;
	
	//dualsense PS4/PS5
	self[$ gp_axis_acceleration_x] = MathReturnNull;
	self[$ gp_axis_acceleration_y] = MathReturnNull;
	self[$ gp_axis_acceleration_z] = MathReturnNull;
	self[$ gp_axis_angular_velocity_x] = MathReturnNull;
	self[$ gp_axis_angular_velocity_y] = MathReturnNull;
	self[$ gp_axis_angular_velocity_z] = MathReturnNull;
	self[$ gp_axis_orientation_x] = MathReturnNull;
	self[$ gp_axis_orientation_y] = MathReturnNull;
	self[$ gp_axis_orientation_z] = MathReturnNull;
	self[$ gp_axis_orientation_w] = MathReturnNull;
}