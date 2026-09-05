//feather ignore all

/** InputIconSystem: An `InputSystem` plug-in that allows you to provide visual aids for gamepad buttons for things like turtorials, quick time events, etc.
 * @return {AnySystem} */
function InputIconSystem() constructor {
	
	
	#region Private
		
		static inputSystem = InputSystem.singleton;
		keyboardIcons = {};													//Map of keyboard buttons to their icon data
		gamepadIcons = {};													//Map of gamepad types to another map of buttons to their icon data
		emptyIcon = undefined;												//Contains icon data for when a button is empty/blank
		unsupportedIcon = undefined;										//Contains icon data for when a gamepad type is not supported
		
	#endregion
	
	
	/** Sets the icon data to use for the specified gamepad type and corresponding gamepad button.
	 * @arg {Enum.Input_GamepadType} _gamepadType The gamepad type to define icon data for
	 * @arg {Constant.GamepadButton} _button The gamepad button the data is for
	 * @arg {Any} _icon The icon data to set
	 * @return {Undefined} */
	static SetIconGamepad = function(_gamepadType, _button, _icon) {
		//Check if we have a map for this gamepad type
		var _gamepadMap = StructTryGetMember(gamepadIcons, _gamepadType);
		if (is_undefined(_gamepadMap)) {
			_gamepadMap = {};
			gamepadIcons[$ _gamepadType] = _gamepadMap;
		}
		StructSetMemberUnique(_gamepadMap, _button, _icon);
	}
	
	/** Sets the icon data to use for the specified keyboard button
	 * @arg {Constant.KbmButton} _button The `vk_*` or `mb_*` button constant that you want to set data for
	 * @arg {Any} _icon The icon data to set
	 * @return {Undefined} */
	static SetIconKbm = function(_button, _icon) {
		if (is_string(_button)) {
			_button = ord(string_upper(_button));
		}
		StructSetMemberUnique(keyboardIcons, _button, _icon);
	}
	
	/** Sets the default icon data to use for all buttons
	 * @arg {Any} _icon The icon data to set
	 * @return {Undefined} */ 
	static SetIconEmpty = function(_icon) {
		emptyIcon = _icon;
	}
	
	/** Sets the default icon to use for unsupported devices
	 * @arg {Any} _icon The icon data to set
	 * @return {Undefined} */
	static SetIconUnsupported = function(_icon) {
		unsupportedIcon = _icon;
	}
	
	/** Returns the icon data for unsupported buttons
	 * @return {Any} */
	static GetIconUnsupported = function() {
		return unsupportedIcon;
	}
	 
	/** Returns the default icon data
	 * @return {Any} */
	static GetIconEmpty = function() {
		return emptyIcon;
	}
	 
	/** Returns the icon data set for the button of a specific gamepad type
	 * @arg {Enum.Input_GamepadType} _gamepadType The gamepad type
	 * @arg {Constant.GamepadButton} _button The button to get the icon data from
	 * @return {Any} */
	static GetIconGamepad = function(_gamepadType, _button) {
		//Early exit if not a supported gamepad type
		var _gamepadMap = StructTryGetMember(gamepadIcons, _gamepadType);
		if (is_undefined(_gamepadMap)) {
			return unsupportedIcon;
		}
		
		return StructTryGetMember(_gamepadMap, _button, emptyIcon);
	}	
	
	/** Returns the icon data set for the specified keyboard or mouse button
	 * @arg {Constant.KbmButton} _button The button to get the icon for
	 * @return {Any} */
	static GetIconKbm = function(_button) {
		return StructTryGetMember(keyboardIcons, _button, emptyIcon);
	}
	
	/** Returns the icon data for a button binding held by a player's verb definition
	 * @arg {Enum.Input_Verb} _verb The verb to use
	 * @arg {Real} _bindingPosition The button binding position within the verb
	 * @arg {Real} _playerIndex The index of the player holding the verb definition
	 * @return {Any} */
	static FindIcon = function(_verb, _bindingPosition, _playerIndex) {
		if (!inputSystem.ValidateVerbIndex(_verb)) {
			inputSystem.ThrowInvalidVerb("FindIcon", _verb, self);
		}
		
		//Getting data
		var _player = inputSystem.GetPlayer(_playerIndex);
		var _deviceType = _player.GetDeviceType();
		var _verbDef = _player.GetVerb(_verb);
		var _icon = variable_clone(unsupportedIcon);
		
		//Only gamepads/kbm devices can have icons.
		if (_deviceType == Input_DeviceType.kbm) {
			var _button = _verbDef.GetButtonBinding(_bindingPosition, false);
			_icon = GetIconKbm(_button);
		}
		else if (_deviceType == Input_DeviceType.gamepad) {
			var _gamepadType = _player.GetLastGamepadType();
			var _button = _verbDef.GetButtonBinding(_bindingPosition, true);
			_icon = GetIconGamepad(_gamepadType, _button);
		}
		
		return _icon;
	}
	
	
	#region Icon Data Config
		// Icon data to return when a binding is empty
		SetIconEmpty("empty");
		
		// Icon data to return when a binding is unsupported on the target device
		SetIconUnsupported("unsupported");	
		
		// Icon data to return when a gamepad type is unrecognised or unsupported
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_face1, "face south");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_face2, "face east" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_face3, "face west" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_face4, "face north");
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_shoulderl,  "shoulder l");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_shoulderr,  "shoulder r");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_shoulderlb, "trigger l" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_shoulderrb, "trigger r" );
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_select, "select");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_start,  "start" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_home,   "home"  );
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_padl, "dpad left" ); 
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_padr, "dpad right"); 
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_padu, "dpad up"   ); 
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_padd, "dpad down" ); 
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, -gp_axislh, "thumbstick l left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN,  gp_axislh, "thumbstick l right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, -gp_axislv, "thumbstick l up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN,  gp_axislv, "thumbstick l down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN,  gp_stickl, "thumbstick l click");
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, -gp_axisrh, "thumbstick r left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN,  gp_axisrh, "thumbstick r right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, -gp_axisrv, "thumbstick r up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN,  gp_axisrv, "thumbstick r down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN,  gp_stickr, "thumbstick r click");
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_paddler,  "paddle r" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_paddlel,  "paddle l" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_paddlerb, "paddle rb");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_paddlelb, "paddle lb");
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_extra1, "extra 1");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_extra2, "extra 2");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_extra3, "extra 3");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_extra4, "extra 4");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_extra5, "extra 5");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_extra6, "extra 6");
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_UNKNOWN, gp_touchpadbutton, "touchpad");			
	#endregion
	
	
	#region Default Kbm Icon Data
		SetIconKbm("A", "A");
		SetIconKbm("B", "B");
		SetIconKbm("C", "C");
		SetIconKbm("D", "D");
		SetIconKbm("E", "E");
		SetIconKbm("F", "F");
		SetIconKbm("G", "G");
		SetIconKbm("H", "H");
		SetIconKbm("I", "I");
		SetIconKbm("J", "J");
		SetIconKbm("K", "K");
		SetIconKbm("L", "L");
		SetIconKbm("M", "M");
		SetIconKbm("N", "N");
		SetIconKbm("O", "O");
		SetIconKbm("P", "P");
		SetIconKbm("Q", "Q");
		SetIconKbm("R", "R");
		SetIconKbm("S", "S");
		SetIconKbm("T", "T");
		SetIconKbm("U", "U");
		SetIconKbm("V", "V");
		SetIconKbm("W", "W");
		SetIconKbm("X", "X");
		SetIconKbm("Y", "Y");
		SetIconKbm("Z", "Z");
		
		SetIconKbm("0", "0");
		SetIconKbm("1", "1");
		SetIconKbm("2", "2");
		SetIconKbm("3", "3");
		SetIconKbm("4", "4");
		SetIconKbm("5", "5");
		SetIconKbm("6", "6");
		SetIconKbm("7", "7");
		SetIconKbm("8", "8");
		SetIconKbm("9", "9");
		
		SetIconKbm(vk_backtick,   "`");
		SetIconKbm(vk_hyphen,     "-");
		SetIconKbm(vk_equals,     "=");
		SetIconKbm(vk_semicolon,  ";");
		SetIconKbm(vk_apostrophe, "'");
		SetIconKbm(vk_comma,      ",");
		SetIconKbm(vk_period,     ".");
		SetIconKbm(vk_rbracket,   "]");
		SetIconKbm(vk_lbracket,   "[");
		SetIconKbm(vk_fslash,     "/");
		SetIconKbm(vk_bslash,     "\\");
		
		SetIconKbm(vk_scrollock, "scroll lock");
		SetIconKbm(vk_capslock,  "caps lock");
		SetIconKbm(vk_numlock,   "num lock");
		SetIconKbm(vk_lmeta,     "left meta");
		SetIconKbm(vk_rmeta,     "right meta");
		SetIconKbm(vk_clear,     "clear");
		SetIconKbm(vk_menu,      "menu");
		
		SetIconKbm(vk_printscreen, "print screen");
		SetIconKbm(vk_pause,       "pause break");
		
		SetIconKbm(vk_escape,    "escape");
		SetIconKbm(vk_backspace, "backspace");
		SetIconKbm(vk_space,     "space");
		SetIconKbm(vk_enter,     "enter");
		
		SetIconKbm(vk_up,    "arrow up");
		SetIconKbm(vk_down,  "arrow down");
		SetIconKbm(vk_left,  "arrow left");
		SetIconKbm(vk_right, "arrow right");
		
		SetIconKbm(vk_tab,      "tab");
		SetIconKbm(vk_ralt,     "right alt");
		SetIconKbm(vk_lalt,     "left alt");
		SetIconKbm(vk_alt,      "alt");
		SetIconKbm(vk_rshift,   "right shift");
		SetIconKbm(vk_lshift,   "left shift");
		SetIconKbm(vk_shift,    "shift");
		SetIconKbm(vk_rcontrol, "right ctrl");
		SetIconKbm(vk_lcontrol, "left ctrl");
		SetIconKbm(vk_control,  "ctrl");
		
		SetIconKbm(vk_f1,  "f1");
		SetIconKbm(vk_f2,  "f2");
		SetIconKbm(vk_f3,  "f3");
		SetIconKbm(vk_f4,  "f4");
		SetIconKbm(vk_f5,  "f5");
		SetIconKbm(vk_f6,  "f6");
		SetIconKbm(vk_f7,  "f7");
		SetIconKbm(vk_f8,  "f8");
		SetIconKbm(vk_f9,  "f9");
		SetIconKbm(vk_f10, "f10");
		SetIconKbm(vk_f11, "f11");
		SetIconKbm(vk_f12, "f12");
		
		SetIconKbm(vk_divide,   "numpad /");
		SetIconKbm(vk_multiply, "numpad *");
		SetIconKbm(vk_subtract, "numpad -");
		SetIconKbm(vk_add,      "numpad +");
		SetIconKbm(vk_decimal,  "numpad .");
		
		SetIconKbm(vk_numpad0, "numpad 0");
		SetIconKbm(vk_numpad1, "numpad 1");
		SetIconKbm(vk_numpad2, "numpad 2");
		SetIconKbm(vk_numpad3, "numpad 3");
		SetIconKbm(vk_numpad4, "numpad 4");
		SetIconKbm(vk_numpad5, "numpad 5");
		SetIconKbm(vk_numpad6, "numpad 6");
		SetIconKbm(vk_numpad7, "numpad 7");
		SetIconKbm(vk_numpad8, "numpad 8");
		SetIconKbm(vk_numpad9, "numpad 9");
		
		SetIconKbm(vk_delete,   "delete");
		SetIconKbm(vk_insert,   "insert");
		SetIconKbm(vk_home,     "home");
		SetIconKbm(vk_pageup,   "page up");
		SetIconKbm(vk_pagedown, "page down");
		SetIconKbm(vk_end,      "end");
		
		//Name newline character after Enter
		SetIconKbm(10, "enter");
		
		//Reset F11 and F12 keycodes on certain platforms
		if (INPUT_LINUX || INPUT_MACOS)
		{
			SetIconKbm(128, "f11");
			SetIconKbm(129, "f12");
		}
		
		//F13 to F32 on Windows and Web
		if (INPUT_WINDOWS || INPUT_WEB)
		{
			for(var _i = vk_f1 + 12; _i < vk_f1 + 32; _i++)
			{
				SetIconKbm(_i, "f" + string(_i));
			}
		}	
	#endregion
	
	
	#region Default Nintendo Icon Data
		//Nintendo
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_face1, "B"); //B
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_face2, "A"); //A
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_face3, "Y"); //Y
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_face4, "X"); //X
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_shoulderl,  "L" ); //L
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_shoulderr,  "R" ); //R
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_shoulderlb, "ZL"); //ZL
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_shoulderrb, "ZR"); //ZR
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_select, "minus"); //Minus
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_start,  "plus" ); //Plus
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_padl, "dpad left" ); //D-pad left
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_padr, "dpad right"); //D-pad right
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_padu, "dpad up"   ); //D-pad up
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_padd, "dpad down" ); //D-pad down
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, -gp_axislh, "thumbstick l left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH,  gp_axislh, "thumbstick l right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, -gp_axislv, "thumbstick l up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH,  gp_axislv, "thumbstick l down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH,  gp_stickl, "thumbstick l click");
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, -gp_axisrh, "thumbstick r left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH,  gp_axisrh, "thumbstick r right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, -gp_axisrv, "thumbstick r up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH,  gp_axisrv, "thumbstick r down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH,  gp_stickr, "thumbstick r click");
		
		//Not available on the Switch console itself but available on other platforms
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_home,   "home");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_extra1, "capture");
		
		//Switch 2
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_extra2,  "C" ); //GameChat
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_paddlel, "GL"); //Grip Left
		SetIconGamepad(INPUT_GAMEPAD_TYPE_SWITCH, gp_paddler, "GR"); //Grip Right	
		
		//Left Joy-con
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, gp_face1, "face south"); //Face South
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, gp_face2, "face east" ); //Face East
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, gp_face3, "face west" ); //Face West
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, gp_face4, "face north"); //Face North
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, gp_shoulderl, "SL"); //SL
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, gp_shoulderr, "SR"); //SR
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, gp_start, "minus"); //Minus
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, -gp_axislh, "thumbstick left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT,  gp_axislh, "thumbstick right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, -gp_axislv, "thumbstick up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT,  gp_axislv, "thumbstick down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT,  gp_stickl, "thumbstick click");
		
		//Not available on the Switch console itself but available on other platforms
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_LEFT, gp_select, "capture"); //Capture		
		
		//Right Joy-con
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, gp_face1, "face south"); //Face South
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, gp_face2, "face east" ); //Face East
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, gp_face3, "face west" ); //Face West
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, gp_face4, "face north"); //Face North
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, gp_shoulderl, "SL"); //SL
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, gp_shoulderr, "SR"); //SR
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, gp_start, "plus"); //Plus
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, -gp_axislh, "thumbstick left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT,  gp_axislh, "thumbstick right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, -gp_axislv, "thumbstick up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT,  gp_axislv, "thumbstick down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT,  gp_stickl, "thumbstick click");
		
		//Not available on the Switch console itself but available on other platforms
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, gp_select, "home"); //Home
		SetIconGamepad(INPUT_GAMEPAD_TYPE_JOYCON_RIGHT, gp_extra2, "C"   ); //Switch 2 GameChat			
	#endregion
	
	
	#region Default PlayeStation Icon Data
		//PS4
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face1, "cross"   ); //Cross
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face2, "circle"  ); //Circle
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face3, "square"  ); //Square
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_face4, "triangle"); //Triangle
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderl,  "L1"); //L1
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderr,  "R1"); //R1
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderlb, "L2"); //L2
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_shoulderrb, "R2"); //R2
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_select, "share"  ); //Select
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_start,  "options"); //Start
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_padl, "dpad left" ); //D-pad left
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_padr, "dpad right"); //D-pad right
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_padu, "dpad up"   ); //D-pad up
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_padd, "dpad down" ); //D-pad down
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, -gp_axislh, "thumbstick l left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_axislh, "thumbstick l right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, -gp_axislv, "thumbstick l up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_axislv, "thumbstick l down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_stickl, "L3"                );
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, -gp_axisrh, "thumbstick r left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_axisrh, "thumbstick r right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, -gp_axisrv, "thumbstick r up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_axisrv, "thumbstick r down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4,  gp_stickr, "R3"                );
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS4, gp_touchpadbutton, "touchpad");	
		
		//PS5
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face1, "cross"   ); //Cross
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face2, "circle"  ); //Circle
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face3, "square"  ); //Square
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_face4, "triangle"); //Triangle
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderl,  "L1"); //L1
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderr,  "R1"); //R1
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderlb, "L2"); //L2
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_shoulderrb, "R2"); //R2
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_select, "create" ); //Select
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_start,  "options"); //Start
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_padl, "dpad left" ); //D-pad left
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_padr, "dpad right"); //D-pad right
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_padu, "dpad up"   ); //D-pad up
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_padd, "dpad down" ); //D-pad down
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, -gp_axislh, "thumbstick l left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_axislh, "thumbstick l right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, -gp_axislv, "thumbstick l up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_axislv, "thumbstick l down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_stickl, "L3"                );
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, -gp_axisrh, "thumbstick r left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_axisrh, "thumbstick r right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, -gp_axisrv, "thumbstick r up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_axisrv, "thumbstick r down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5,  gp_stickr, "R3"                );
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_touchpadbutton, "touchpad");
		
		//Not available on the PlayStation 5 console itself but available on other platforms
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_extra1, "mic");
		
		//DualSense Edge
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_paddler, "RB");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_PS5, gp_paddlel, "LB");	
	#endregion
	
	
	#region Default XBox Icon data
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_face1, "A"); //A
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_face2, "B"); //B
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_face3, "X"); //X
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_face4, "Y"); //Y
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_shoulderl,  "LB"); //LB
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_shoulderr,  "RB"); //RB
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_shoulderlb, "LT"); //LT
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_shoulderrb, "RT"); //RT
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_select, "view"); //View
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_start,  "menu"); //Menu
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_padl, "dpad left" ); //D-pad left
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_padr, "dpad right"); //D-pad right
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_padu, "dpad up"   ); //D-pad up
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_padd, "dpad down" ); //D-pad down
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, -gp_axislh, "thumbstick l left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX,  gp_axislh, "thumbstick l right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, -gp_axislv, "thumbstick l up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX,  gp_axislv, "thumbstick l down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX,  gp_stickl, "thumbstick l click");
		
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, -gp_axisrh, "thumbstick r left" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX,  gp_axisrh, "thumbstick r right");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, -gp_axisrv, "thumbstick r up"   );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX,  gp_axisrv, "thumbstick r down" );
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX,  gp_stickr, "thumbstick r click");
		
		//Series S|X only
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_extra1, "share");
		
		//Elite and third party controllers
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_paddler,  "P1");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_paddlel,  "P2");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_paddlerb, "P3");
		SetIconGamepad(INPUT_GAMEPAD_TYPE_XBOX, gp_paddlelb, "P4");	
	#endregion
}