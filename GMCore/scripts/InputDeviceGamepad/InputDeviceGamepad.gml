/** InputGamepad: Represents a gamepad connected to the InputSystem.
 * @arg {Real} _gamepadIndex The index number to set for this gamepad
 * @arg {Real} [_description] Optionally set a custom description for the gamepad. Not recommended to set manually as some gamepads use their description as an encryption.
 * @arg {Struct.InputGamepadGUID} [_guid] The GUID gamepad product information. Automatically retrieved if left blank or set to `undefined`
 * @return {Struct.InputDeviceGamepad} */
function InputDeviceGamepad(_gamepadIndex, _description = undefined, _guid = undefined) : InputDevice() constructor {
	//feather ignore all
	_description ??= gamepad_get_description(_gamepadIndex);
	_guid ??= new InputGamepadGUID(gamepad_get_guid(_gamepadIndex));
	
	//Represents the type of gamepad being used
	enum Input_GamepadType {
		none,																//Used specifically for InputPlayer's when their device isn't a gamepad. Actual gamepads should never return this value.
		xBox,																//Indicates xBox controller
		ps4,																//Indicates ps4 controller
		ps5,																//Indicates ps5 controller
		nintendoSwitch,														//Indicates joycon-pair or pro-controller. 
		joyconLeft,															//Indicates single left joycon. Horizontal or Vertical mode determined by the `InputDeviceGamepadSwitch` subclass
		joyconRight,														//Indicates single right joycon. Horizontal or Vertical mode determined by the `InputDeviceGamepadSwitch` subclass
		unknown,															//Indicates a generic gamepad with no identifiable type. This gamepad type is still usable, unlike the `none` type.
	}	
	
	#region Internal
		
		///@ignore
		type = Input_DeviceType.gamepad;									//Indicates a gamepad InputDevice
		///@ignore
		gpType = Input_GamepadType.unknown;									//Indicates the gamepad type. Set up in the `Discover` initialization call
		///@ignore
		index = _gamepadIndex;												//The gamepad port this is connected to.
		
		
		///@ignore
		guid = _guid;														//GUID information about the physical gamepad
		///@ignore
		description = gamepad_get_description(index);						//Product description
		///@ignore
		steamHandle = undefined;											//Steams handle for this gamepad
		///@ignore
		steamHandleIndex = undefined;										//Steams index for this gamepad
		
		
		///@ignore
		prevValue = array_create(4, 0);										//Previous thumbstick input value [gp_axislh, gp_axislv, gp_axisrh, gp_axisrv] 
		///@ignore
		currentValue = array_create(4, 0);									//Current thumbstick input value [gp_axislh, gp_axislv, gp_axisrh, gp_axisrv] 
		///@ignore
		buttonMap = new InputGamepadBindingTable();							//This map is used to check the input values of the various gamepad buttons
		///@ignore
		buttons = undefined;												//Array of button constants available to this device
		
		
		/** Helper func to make `GetOutput()` a little bit neater
		 * @ignore
		 * @return {Bool} */
		static CanGetOutput = function() {
			var _bool = true;
			if (INPUT_BAN_GAMEPADS) {
				_bool = false;
			}
			else if (!inputSystem.GameHasFocus()) {
				_bool = false;
			}
			else if (!inputSystem.DeviceIsConnected(self)) {
				_bool = false;
			}
			else if (!gamepad_is_connected(index)) {
				_bool = false;
			}
			return _bool;
		}
		
		/** Helps check individual thumbstick directions for activity.
		 * @ignore
		 * @arg {Real} _index
		 * @return {Bool} */
		static CheckThumbstickActivity = function(_index) {
			switch (_index) {
				case gp_axislh:
					_index = 0;
				break;
				
				case gp_axislv:
					_index = 1;
				break;
				
				case gp_axisrh:
					_index = 2;
				break;
				
				case gp_axisrv:
					_index = 3;
				break;
			}
			var _prev = abs(prevValue[_index]);
			var _curr = abs(currentValue[_index]);
			return ((_prev <= INPUT_GAMEPAD_THUMBSTICK_MIN_THRESHOLD) && (_curr > INPUT_GAMEPAD_THUMBSTICK_MIN_THRESHOLD));
		}
		
		/** Validator for steam handles
		 * @ignore
		 * @arg {Any} _handle
		 * @return {Bool} */
		static IsValidSteamHandle = function(_handle) {
			return (is_numeric(_handle) && (_handle > 0));
		}
		
		/** Returns `true` if the specified guid string is for a joy-con that is blocked by the android platform
		 * @ignore
		 * @arg {String} _guid The guid to check
		 * @return {Bool} */
		static CheckAndroidBlocksSwitch = function(_guid) {
			var _switchCheck = [
				"31613237643563656561633964393335", 
				"4e696e74656e646f20436f2e2c204c74", 
				"61393962646434393836356631636132", 
				"31343431323332663936386663646631", 
				"65366131663736363061313736656431", 
				"31613237643563656561633964393335", 
				"39373064396565646338333134303131"
			];		
			return StringMatchesAny(_guid, _switchCheck);	
		}
		
		/** Returns `true` if the specified guid string also corresponds to a TV remote (for android)
		 * @ignore
		 * @arg {String} _guid The guid to check
		 * @return {Bool} */
		static CheckAndroidBlocksTV = function(_guid) {
			var _tvCheck = [
				"37306138633665393031353462623835", 
				"30653530626463313864336165306236", 
				"38346462303632636161363531303766", 
				"66626636666361303930383433646337"
			];		
			return StringMatchesAny(_guid, _tvCheck);	
		}
		
		/** Returns `true` if the specified vendor string matches any of the vendor strings that are block listed.
		 * @ignore
		 * @arg {String} _vendor The vendor string to check
		 * @return {Bool} */
		static CheckVendorBlocklist = function(_vendor) {
			//Blocklist sourced from https://github.com/chromium/chromium/blob/main/device/gamepad/gamepad_blocklist.cc
			var _vendCheck = [
				"4e04", "8eb5", "3328", "ef0e", 
				"f304", "e704", "d21f", "0804", 
				"5704", "3004", "cb06", "da09", 
				"3105", "6a05", "ef17", "1c1b"
			];		
			return StringMatchesAny(_vendor, _vendCheck);		
		}
		
		/** Returns `true` if the specified vendor product ID string matches a blacklisted string.
		 * @ignore
		 * @arg {String} _vpID The vendor + product ID string to check
		 * @return {Bool} */
		static CheckJoystickBlacklist = function(_vpID) {
			//Blocklist sourced from https://github.com/denilsonsa/udev-joystick-blacklist			
			var _vpIdCheck = [
				"5e049d00", "5e04b000", "5e04b400", "5e043007", 
				"5e044507", "5e044807", "5e045007", "5e046807", 
				"5e047307", "5e04a507", "5e04b207", "5e040008", 
				"6b0410ff", "6d040ac3", "d9040980", "d904dfa0", 
				"450c0a80", "17100320", "c016d004", "571d03ad", 
				"7d1ecb2d", "7d1e4a2e", "a0202d42", "16251f00", 
				"16252800", "ce26a201", "ac053232", "eb0301ff", 
				"eb0302ff", "12042171", "3c1b3c1b", "b404f3fe", 
				"620d1a9a", "d9040880", "d90492a2", "5e04cd07", 
				"5e042209", "5e04c009"
			];		
			return StringMatchesAny(_vpID, _vpIdCheck);	
		}
		
		/** Returns `true` is the specified guid string matches any of the ROG mouse guid strings
		 * @ignore
		 * @arg {String} _guid The guid string to check
		 * @return {Bool} */
		static CheckROG = function(_guid) {
			var _rogCheck = [
				"03000000050b00000619000000010000", 
				"03000000050b0000e318000000010000", 
				"03000000050b0000e518000000010000", 
				"03000000050b00005819000000010000", 
				"03000000050b0000181a000000010000", 
				"03000000050b00001a1a000000010000", 
				"03000000050b00001c1a000000010000"
			];	
			return StringMatchesAny(_guid, _rogCheck);	
		}
		
		/** Modifies this gamepads values using steam input. Performs basic block checking in the process to catch weird edge cases. This function is called at the end of all gamepad class definitions but only on desktop and if steam was successfully initialized.
		 * @ignore
		 * @return {Undefined} */
		static SteamTransform = function() {
			//Steamworks handling
			if (inputSystem.UsingSteamworks()) {
				var _isVirtual = (INPUT_WINDOWS && IsXInput());
				var _index = index;
				
				//Linux platform requires us to correct gamepad port index for steam
				if (INPUT_LINUX) {
					
					if (INPUT_LOG_STEAM_DEBUG) {
						LogDebug($"InputGamepad -> Running Linux steam input logic for gamepad index {_index}");
					}
					
					
					var _handleIndex = -1;
					_isVirtual = false;
					
					var i = 0; repeat(index + 1) {
						
						if (gamepad_get_description(i) == "Valve Streaming Gamepad" || StringContains(gamepad_get_guid(i), ["03000000de280000fc11", "03000000de280000ff11"]))  {
							_handleIndex++;
							_isVirtual = true;	
							
							if (INPUT_LOG_STEAM_DEBUG) {
								LogDebug($"Gamepad index {i} is a virtual gamepad");
							}
						}							
						i++;
					}
					
					if (INPUT_LOG_STEAM_DEBUG) {
						LogDebug($"Gamepad index converted from [{index}] to [{_handleIndex}]");
					}
					_index = _handleIndex;
				}
				
				
				//Correct the port index for the steam platform on Max and  Linux.
				var _guid = guid.GetGUID();
				var _checkMac = (INPUT_MACOS && (_guid == "030000005e0400008e02000001000000"));
				var _checkLinux = (INPUT_LINUX && (_guid == "03000000de280000ff11000001000000"));
				var _checkSteam = (inputSystem.UsingSteam() && inputSystem.UsingSteamdeck());
				if (_checkMac || (_checkLinux && !_checkSteam)) {
					
					//This gamepad is a steam virtual controller and should be ignored.
					SetBlocked(true);
					
					if (INPUT_LOG_STEAM_DEBUG) {
						LogDebug($"InputGamepad::SteamTransform -> Virtual gamepad detected, ignoring Gamepad with index {index}");
					}
					//Don't return! Still need to process Steam variables
				}
				
				//Non mac/linux desktop platforms
				else {
					steamHandle = steam_input_get_controller_for_gamepad_index(_index);
					var _check = steam_input_get_gamepad_index_for_controller(steamHandle);
					
					if (INPUT_LOG_STEAM_DEBUG) {
						LogDebug($"Checking gamepad index:\nOriginal index [{index}]. Remapped from index [{_index}].\nDerived from steam handle index [{_check}]");
						LogDebug($"Found Steam input handle {steamHandle} for gamepad index {_index}");
					}
					
					//Can only use steam input platform with virtual controllers.
					if (!_isVirtual && IsValidSteamHandle(steamHandle)) {
						//Clear steam variables if this gamepad is incompatible with the steam input structure
						steamHandle = undefined;
						steamHandleIndex = undefined;
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"Invalid steam handle detected for gamepad index {_index}");
						}
					}
					
					//This gamepad will likely use the steam input platform
					else {
						steamHandleIndex = steam_input_get_gamepad_index_for_controller(steamHandle);
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"Found steam handle index [{steamHandleIndex}] for gamepad index {_index}");
						}
						
						//Early exit if steam has no gamepad info for us or if this is a platform that doesn't work with steam.
						if (!INPUT_WINDOWS || steamHandleIndex == -1) {
							return;
						}
						
						//Get the steam data set for this steam gamepad typ during `InputSystem.InitializeSteam()` 
						var _steamType = steam_input_get_input_type_for_handle(steamHandle);
						var _steamGamepad = inputSystem.SteamGetGamepadType(_steamType);
						
						//Block this gamepad if steam data wasn't able to be set for it
						if (is_undefined(_steamGamepad)) {
							description = "Missing Description"
							gpType = Input_GamepadType.unknown;
							SetBlocked(true);
							
							if (INPUT_LOG_WARNING) {
								LogWarning($"InputGamepad::SteamTransform -> Steam gamepad type [{_steamType}] has no available steam data!");
							}
							return;
						}
						
						//We have available steam data
						else {
							description = _steamGamepad.GetDescription();
							gpType = _steamGamepad.GetType();
							if (INPUT_LOG_STEAM_DEBUG) {
								LogDebug($"Found steam input data:\nType = {_steamType}\nDescription = {description}\nType = {gpType}");
							}							
						}
					}
				}
			}
			
			//Block device types indicated by steam input
			if ((guid.GetVendorID() == "de28") && inputSystem.SteamIsGamepadTypeIgnored(gpType)) {
				if (INPUT_LOG_WARNING) {
					LogWarning($"InputGamepad::SteamTransform -> Gamepad type [{gpType}] is blacklisted by Steam Input. Blocking gamepad.");
				}
				SetBlocked(true);
				return;
			}
			
		}
		
		/** Modifies this gamepad using known quirks to perform comprehensive blocking and type overriding. This function is called at the end of all gamepad class definitions but only on desktop and if steam was successfully initialized.
		 * @ignore
		 * @return {Undefined} */
		static SteamTransformQuirks = function() {
			var _guid = guid.GetGUID();
			var _vpId = guid.GetVendorID() + guid.GetProductID();
			var _desc = string_lower(description);
			var _axisCount = gamepad_axis_count(index);								
			var _buttonCount = gamepad_button_count(index);							
			var _hatCount = gamepad_hat_count(index);									
			
			//Modifying the gamepad for known quirks of each os_type
			switch (os_type) {
				case os_windows:
					
					if ((_vpId == "63257505") && (_buttonCount == 14) && (_hatCount == 1) && StringContains(_desc, "switch co.,ltd. retro-bit controller")) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_WINDOWS Overriding gamepad type: Switch (Saturn Wireless Pro)");
						}
						gpType = Input_GamepadType.nintendoSwitch;
					}
					else if ((_vpId == "7e050920") && (_buttonCount > 21) && (!(_buttonCount == 30) && (_hatCount == 0))) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_WINDOWS Blocking gamepad: Switch USB Controller");
						}
						SetBlocked(true);
					}
					else if ((_vpId == "4c056802") && (_buttonCount == 19) && (_axisCount == 4)) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_WINDOWS Blocking gamepad: PS3 Controller (Bad Driver)");
						}
						SetBlocked(true);
					}
					else if ((_vpId == "4c056802") && (_buttonCount == 0) && (_axisCount == 8)) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_WINDOWS Blocking gamepad: DSHidMini Gyro");
						}
						SetBlocked(true);
					}
					else if (StringMatchesAny(_vpId, ["71011904", "5e04050b", "5e04130b", "5e04220b", "5e04200b"])) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_WINDOWS Blocking gamepad: DInput duplicate");
						}
						SetBlocked(true);						
					}
					else if (_vpId == "31730100") {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_WINDOWS Blocking gamepad: DSHIDMini DS4W mode");
						}
						SetBlocked(true);								
					}
				break;
				
				
				case os_macosx:
					if (_guid == "none" && StringContains(_desc, "apple")) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_MACOSX Blocking gamepad: Apple virtual controller");
						}
						SetBlocked(true);							
					}
					else if (CheckROG(_guid)) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_MACOSX Blocking gamepad: ROG Mouse");
						}
						SetBlocked(true);							
					}		
					else if (gpType == Input_GamepadType.joyconLeft || gpType == Input_GamepadType.joyconRight) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_MACOSX Blocking gamepad: Single Joy Con");
						}
						SetBlocked(true);							
					}
					else if (_vpId == "7e050920") {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_MACOSX Blocking gamepad: Switch Pro Controller");
						}
						SetBlocked(true);							
					}
				break;
				
				
				case os_linux:
					if (_buttonCount == 144 && _axisCount == 0) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_LINUX Blocking gamepad: Steam Deck virtual keyboard");
						}
						SetBlocked(true);						
					}
					else if (_buttonCount == 0 && _axisCount == 6 && _hatCount == 0) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_LINUX Blocking gamepad: Joy-Con IMU");
						}
						SetBlocked(true);							
					}
					else if (_vpId == "63257505" && _buttonCount == 13 && _hatCount == 1 && StringContains(_desc, "usb")) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_LINUX Blocking gamepad: Saturn Wireless Pro");
						}
						SetBlocked(true);								
					}
					else if (StringContains(_desc, ["touchpad", "touchscreen"])) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_LINUX Blocking gamepad: Touchpad");
						}
						SetBlocked(true);							
					}
					else if (CheckROG(_guid)) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_LINUX Blocking gamepad: ROG Mouse");
						}
						SetBlocked(true);						
					}
					else if (CheckVendorBlocklist(guid.GetVendorID())) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_LINUX Blocking gamepad: Blocklisted vendor ID");
						}
						SetBlocked(true);							
					}
					else if (CheckJoystickBlacklist(_vpId)) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_LINUX Blocking gamepad: Blocklisted device ID");
						}
						SetBlocked(true);							
					}
				break;
				
				
				case os_android:
					if (_desc == "joy-con charging grip") {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_ANDROID Blocking gamepad: Switch charging grip");
						}
						SetBlocked(true);							
					}
					else if (_guid == "39666538356630396233636633333330") {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_ANDROID Blocking gamepad: Xbox Elite Series 2");
						}
						SetBlocked(true);							
					}
					else if (CheckAndroidBlocksSwitch(_guid)) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_ANDROID Blocking gamepad: Incompatible Switch Gamepad");
						}
						SetBlocked(true);							
					}
					else if (CheckAndroidBlocksTV(_guid)) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_ANDROID Blocking gamepad: TV Remote");
						}
						SetBlocked(true);							
					}
				break;
				
				
				case os_ios:
				case os_tvos:
					if (gpType == Input_GamepadType.nintendoSwitch) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_TVOS/IOS Remapping face buttons for type Nintendo Switch");
						}	
						
						//Nintendo gamepads have an option to flip these automatically, but in this case we should always flip them.
						ButtonSetMap(gp_face1, function(_index) {
							return gamepad_button_value(_index, gp_face2);
						});
						ButtonSetMap(gp_face2, function(_index) {
							return gamepad_button_value(_index, gp_face1);
						});
						ButtonSetMap(gp_face3, function(_index) {
							return gamepad_button_value(_index, gp_face4);
						});
						ButtonSetMap(gp_face4, function(_index) {
							return gamepad_button_value(_index, gp_face3);
						});
					}
					
					else if (gpType == Input_GamepadType.joyconLeft || gpType == Input_GamepadType.joyconRight) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_TVOS/IOS Blocking gamepad: Single Joy Con");
						}
						SetBlocked(true);							
					}
					else if (StringContains(_desc, "snes")) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"InputGamepad::SteamTransformQuirks -> OS_TVOS/IOS Blocking gamepad: SNES NSO controller");
						}
						SetBlocked(true);						
					}
					
				break;
			}
		}
	#endregion
	
	
	
	#region Basics
		/** Returns the assigned steam handle of this device or undefined if no handle is assigned. Typically, only gamepad devices will have one assigned.
		 * @return {Any} */
		static GetSteamHandle = function() {
			return steamHandle;
		}
		
		/** Returns the steam handle index of this device or undefined if no handle is assigned. Typically, only gamepad devices will have one assigned. 
		 * @return {Real} */
		static GetSteamHandleIndex = function() {
			return steamHandleIndex;
		}	
		
		/** Returns the button constant for the first detected input from this device. Returns `undefined` if no button is found.
		 * @return {Constant.GamepadButton} */		
		static GetOutput = function() {
			if (CanGetOutput()) {
				var _names = struct_get_names(buttonMap);
				var _len = array_length(_names);
				for (var i = 0; i < _len; i++) {
					var _binding = _names[i];
					if (CheckButton(_binding) > INPUT_GAMEPAD_THUMBSTICK_MIN_THRESHOLD) {
						return _binding;
					}
				}
			}
		}	
		
		/** Returns `true` if activity is detected for this device. Automatically returns `false` if the `InputSystem` is banning gamepads, the game lost focus, or the gamepad is no longer connected.
		 * @return {Bool} */
		static IsActive = function() {
			if (INPUT_BAN_GAMEPADS || !inputSystem.GameHasFocus() || !inputSystem.DeviceIsConnected(self) || !gamepad_is_connected(index)) {
				return false;
			}
			
			//Looping through the gamepad button map to check input 
			var _names = struct_get_names(buttonMap);
			var _len = array_length(_names);
			for (var i = 0; i < _len; i++) {
				
				//Current button binding
				var _binding = real(_names[i]);
				
				//Checking thumbsticks
				if ((_binding == gp_axislh) || (_binding == gp_axislv) || (_binding == gp_axisrh) || (_binding == gp_axisrv)) {
					if (INPUT_GAMEPAD_THUMBSTICK_REPORTS_ACTIVE) {
						//Check previous thumbstick values for activity because current values
						//could be 0 if they just aren't moving which would incorrectly cause the method to return false.
						if (CheckThumbstickActivity(_binding)) {
							return true;
						}
					}
				}
				
				//Checking shoulder buttons
				else if ((_binding == gp_shoulderlb) || (_binding == gp_shoulderrb)) {
					if (INPUT_GAMEPAD_TRIGGER_REPORTS_ACTIVE) {
						//Check current values 
						if (CheckButton(_binding) > INPUT_GAMEPAD_TRIGGER_MIN_THRESHOLD) {
							return true;
						}
					}
				}
				
				//Check for button activity
				else {
					if (CheckButton(_binding)) {
						return true;
					}
				}
			}
			return false;
		}	
		
		/** Returns `true` if this `InputDevice` has not been assigned to a player and is available for use.
		 * @return {Bool} */
		static IsAvailable = function() {
			return (!INPUT_BAN_GAMEPADS && is_undefined(owner));
		}				
		
		/** Returns the gamepads GUID data
		 * @return {Struct.InputGamepadGUID} */
		static GetGUID = function() {
			return guid;
		}		
		
		/** Returns the specific gamepad type of this device. The return value is a member of `Input_GamepadType`
		 * @return {Real} */
		static GetGamepadType = function() {
			return gpType;
		}
		
		/** Returns if this gamepad is an xinput gamepad or not
		 * @return {Bool} */
		static IsXInput = function() {
			return flags.IsBitActive(Input_DeviceFlags.xinput);
		}
		
		/** Returns `true` if this gamepad is one of the following types: 
		 * * `Input_GamepadType.nintendoSwitch`
		 * * `Input_GamepadType.joyconLeft`
		 * * `Input_GamepadType.joyconRight`
		 * @return {Bool} */	
		static IsSwitchController = function() {
			return (gpType == Input_GamepadType.nintendoSwitch || gpType == Input_GamepadType.joyconLeft || gpType == Input_GamepadType.joyconRight);
		}
		
		/** Returns `true` if this gamepad is one of the following types: 
		 * * `Input_GamepadType.ps4`
		 * * `Input_GamepadType.ps5`
		 * @return {Bool} */		
		static IsPlayStationController = function() {
			return ((gpType == Input_GamepadType.ps4) || (gpType == Input_GamepadType.ps5));
		}
		
		/** Returns `true` if this gamepad is one of the following types: 
		 * * `Input_GamepadType.xBox`
		 * @return {Bool} */		
		static IsXBoxController = function() {
			return (gpType == Input_GamepadType.xBox);
		}
		
		/** Returns `true` if this gamepad is a generic type.
		 * @return {Bool} */
		static IsGenericController = function() {
			return (gpType == Input_GamepadType.unknown);
		}
		
		
		/** Updates the previous axis values of the gamepad's left and right thumbsticks. These values are used to make sure the `InputSystem` doesn't confuse inactivity with moving in the same direction for an extended period of time.
		 * @return {Undefined} */
		static UpdateThumbstickValues = function() {
			//If the gamepad is no longer detected, stop all stick activity
			if (INPUT_BAN_GAMEPADS || IsBlocked() || (!gamepad_is_connected(index))) {
				array_map_ext(prevValue, MathReturnNull);
			}
			
			//Otherwise set the values
			else {
				array_copy(prevValue, 0, currentValue, 0, 4);
				currentValue[0] = buttonMap[$ gp_axislh](index, gp_axislh);
		        currentValue[1] = buttonMap[$ gp_axislv](index, gp_axislv);
		        currentValue[2] = buttonMap[$ gp_axisrh](index, gp_axisrh);
		        currentValue[3] = buttonMap[$ gp_axisrv](index, gp_axisrv);			
			}
		}
	#endregion	
	
	
	
	#region Buttons
		
		/** Returns the value of a specific gamepad button for the current frame.
		 * @arg {Constant} _button The `gp_*` button constant to check.
		 * @return {Real} */
		static CheckButton = function(_button) {
			var _value = 0;
			if (struct_exists(buttonMap, _button)) {
				_value = buttonMap[$ _button](index, _button);
			}
			return _value;
		}
		
		/** Nullifies the binding map of a specific button for this device
		 * @arg {Constant.GamepadButton} _button The gamepad button to nullify
		 * @return {Undefined} */
		static ButtonNullifyMapping = function(_button) {
			buttonMap[$ _button] = MathReturnNull;
		}		
		
		/** Nullifies the button map of the device
		 * @return {Undefined} */
		static ButtonNullifyAllMappings = function() {
			var _buttons = struct_get_names(buttonMap);
			var _len = array_length(_buttons);
			var i = 0; repeat(_len) {
				ButtonNullifyMapping(_buttons[i++]);
			}
		}	
		
		/** Nullifies the button map of a group of buttons
		 * @arg {Array<Constant.GamepadButton>} _buttons Array of gamepad buttons
		 * @return {Undefined} */
		static ButtonNullifyMappingGroup = function(_buttons) {
			var i = 0; repeat(array_length(_buttons)) {
				var _button = _buttons[i++];
				ButtonNullifyMapping(_button);
			}			
		}
		
		/** Resets a specific button map to the default map value
		 * @arg {Constant.GamepadButton} _button A `gp_*` button to reset
		 * @return {Undefined} */ 
		static ButtonResetMap = function(_button) {
			buttonMap[$ _button] = inputSystem.GamepadGetDefaultButtonMap(_button);
		}
		
		/** Resets a group of mapped gamepad buttons back to their default map values
		 * @arg {Array<Constant.GamepadButton} _buttons Array of gamepad buttons
		 * @return {Undefined} */
		static ButtonResetMapGroup = function(_buttons) {
			var i = 0; repeat(array_length(_buttons)) {
				var _button = _buttons[i++];
				ButtonResetMap(_button);
			}
		}	
		
		/** Sets the button method for a button
		* @arg {Constant.GamepadButton} _gpConstant The button being set
		* @arg {Function} _method The function to set. This function can take arguments `_deviceIndex` and `_buttonConstant`. If remapping one of the negative button constants then your function definition should wrap the `_buttonConstant` argument with `abs()` before it uses it.
		* @return {Undefined} */
		static ButtonSetMap = function(_gpConstant, _method) {
			buttonMap[$ _gpConstant] = _method;
		}	
		
		/** Sets the button methods for a group of buttons
		 * @arg {Struct} _map A struct of button methods mapped to button constants
		 * @return {Undefined} */
		static ButtonSetMapGroup = function(_struct) {
			StructMerge(_struct, buttonMap);
		}
		
		
	#endregion
}