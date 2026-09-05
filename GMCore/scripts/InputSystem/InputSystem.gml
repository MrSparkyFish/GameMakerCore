//feather ignore all

/** InputSystem: Contains all internal data and logic for background player input processing.
 * ***
 * Satisfies Interfaces:
 * * `IPublisher`
 * @return {Struct.InputSystem} */
function InputSystem() constructor {
	static singleton = self;
	
	#region Constants
		#macro INPUT_STEAMWORKS_SUPPORT  	((INPUT_LINUX || INPUT_WINDOWS) && (not INPUT_WEB))
		#macro INPUT_SDL_SUPPORT         	((not INPUT_WEB) && INPUT_DESKTOP)
		
		#macro INPUT_BAN_KBM				(not INPUT_DESKTOP)
		#macro INPUT_BAN_TOUCH     			(not INPUT_MOBILE)
		#macro INPUT_BLOCK_MOUSE_CHECKS  	INPUT_CONSOLE
		
		#macro INPUT_SUPPORT_GAMEPADS  		(not INPUT_BAN_GAMEPADS)
		#macro INPUT_SUPPORT_KBM      		(not INPUT_BAN_KBM)
		#macro INPUT_SUPPORT_TOUCH     		(not INPUT_BAN_TOUCH)
		#macro INPUT_SUPPORT_HOTSWAP   		(not INPUT_BAN_HOTSWAP)	
	#endregion	
	
	
	#region Private
		
		//Internal system flags.
		enum Input_SystemFlags {
			usingSteam,															//If we launched from steam					
			usingSteamworks,													//If we're using steamworks for developers
			usingSteamDeck,														//If we're using a steamdeck
			onWine,																//If we're using the WINE emulator
			steamBigPicture,													//If we're using steam big picture mode
			switchLabels,														//If we switched to using steam labels for gamepads
			tapClick,															//If tap click is allowed to be used
			windowFocused,														//If the game window is in focus or not
			virtualOrderDirty,													//
			hotswap,															//Player 0 device swapping is allowed
			pointerBlockedByDefocus,											//The system will not allow pointer input because the game window was defocused
			pointerBlockedThisFrame,											//The system will not allow pointer input for the current frame.
			pointerBlockedByUser,												//The system will not allow pointer input as dictated by the user.
			pointerBlocked,														//The system will not allow pointer input if they're blocked.
			pointerMoved,														//If the pointer moved or not
		}
		
		//Default mask value
		var _defaultMask = Input_SystemFlags.hotswap * (!INPUT_BAN_HOTSWAP);
		
		///@ignore 
		systemFlags = new BitMask(_defaultMask);								//Helps manage internal flags									
		///@ignore 
		androidEnumTime = -infinity;											//Timestamp of when gamepads were last enumerated if on the Android platform
		///@ignore 
		restartTime = -infinity;												//Timestamp that indicates the last time the InputSystem was restarted due to a game restart.
		///@ignore 
		time = 0;																//Current amount of time the system has run for
		///@ignore 
		frame = 0;																//Current number of frames that have elapsed over the course of the systems run time.
		///@ignore 
		timer = new Timer();													//Timer object used to self manage the system. Automatically setup based on INPUT_COLLECT_MODE
		
		/** Initializes the sub-systems that are required by `InputSystem` for it to run properly.
		 * @ignore
		 * @return {Undefined} */
		static Initialize = function() {
			InitializeSteam();
			InitializePlugIns();
			InitializePlayers();
			
			if (INPUT_COLLECT_MODE == 0) {
				oGameSystem.onStepBegin.AddStatic(self, Collect);
				oGameSystem.onGameEnd.AddStatic(self, OnGameEnd);
			}
			
			else if (INPUT_COLLECT_MODE == 1) {
				timer.GetOnExpired().BindStatic(self, Collect);
			}
		}
		
	#endregion
	
	
	#region General System
		/** Throws an input system error
		 * @arg {String} _funcName The name of the function where the error originated
		 * @arg {String} _desc Description of the error
		 * @arg {Struct} [_scope] Optional scope if not the calling instance.
		 * @return {Struct.Exception} */
		static ThrowInputError = function(_funcName, _desc, _scope = undefined) {
			_scope ??= self;
			var _title = "Input Error!";
			var _message = ExceptionMessage(_scope, _funcName, _desc);
			ThrowException(_title, _message);
		}
		
		/** Throws an input system error due to an invalid player index
		 * @arg {String} _funcName The name of the function where the error originated
		 * @arg {Any} _playerIndex The invalid player index
		 * @arg {Struct} [_scope] Optional scope if not the calling instance.
		 * @return {Struct.Exception} */
		static ThrowInvalidPlayerIndex = function(_funcName, _playerIndex, _scope = undefined) {
			ThrowInputError(_funcName, $"Player index [{_playerIndex}] is not a valid player.", _scope);
		}	
		
		/** Returns true if the game is currently in focus.
		 * @return {Bool} */
		static GameHasFocus = function() {
			return systemFlags.IsBitActive(Input_SystemFlags.windowFocused);
		}
		
		/** Use this function to tell the `InputSystem` if the game is or isn't currently in focus.
		 * @arg {Bool} _bool Set `true` to tell the input system that the game is in focus. Set `false` to tell it that it lost focus.
		 * @return {Undefined} */
		static SetGameFocus = function(_bool) {
			systemFlags.SetBitState(Input_SystemFlags.windowFocused, _bool);
		}
		
		/** Returns the current frame number
		 * @return {Real} */
		static GetFrame = function() {
			return frame;
		}
		
		/** Returns the current amount of time (in milliseconds) that the input system has been running for. Please note that this value is only updated once per frame and will be inaccurate when called externally.
		 * @return {Real} */
		static GetTime = function() {
			return time;
		}
		
		/** Returns `true` if Hotswapping is enabled for player 0
		 * @return {Bool} */
		static IsHotSwapEnabled = function() {
			return systemFlags.IsBitActive(Input_SystemFlags.hotswap);
		}
		
		/** Set if Hotswapping should be enabled for player 0. A hotswap is triggered when player 0's device goes inactive for a period of time. During this time all players devices are temporarily removed until a new device can be found and assigned to player 0.
		 * @arg {Bool} _bool
		 * @return {Undefined} */
		static SetHotSwap = function(_bool) {
			if (INPUT_BAN_HOTSWAP || (IsHotSwapEnabled() == _bool)) {
				return;
			}
			if (_bool) {
				var i = 0; repeat(INPUT_MAX_PLAYERS) {
					PlayerChangeDevice(i++, undefined);
				}
			}
			systemFlags.SetBitState(Input_SystemFlags.hotswap, _bool);
		}
		
		/** Returns `true` if tap click is able to be detected by the system
		 * @return {Bool} */
		static IsTapClick = function() {
			return systemFlags.IsBitActive(Input_SystemFlags.tapClick);
		}
		
		/** Manual check function that returns `true` if the game window has regained focus.
		 * @return {Bool} */
		static CheckFocusRegained = function() {
			var _keyboard = (keyboard_key != vk_nokey);
			var _mouse = (mouse_button != mb_none);
			var _window = (INPUT_WINDOWS && window_has_focus());
			var _pointer = (INPUT_MACOS && pointer.GetMoved());
			return (_keyboard || _mouse || _window || _pointer);
		}
		
		/** Returns true if time out has been restarted or false if it hasn't
		 * @return {Bool} */
		static TimeoutRestart = function() {
			return (time - restartTime < 1000);
		}			
		
		/** Returns `true` if the system has any `InputVirtualButtons` that need system cleanup 
		 * @return {Bool} */
		static IsVirtualOrderDirty = function() {
			return systemFlags.IsBitActive(Input_SystemFlags.virtualOrderDirty);
		}	
		
		/** Set if the system has `InputVirtualButtons` that need system cleanup
		 * @arg {Bool} _bool Set `true` to clean up virtual buttons during the system update.
		 * @return {Undefined} */
		static SetVirtualOrderDirty = function(_bool) {
			systemFlags.SetBitState(Input_SystemFlags.virtualOrderDirty, _bool)
		}
	#endregion	
		
		
	#region Steam 
		
		///@ignore
		steamHandles = [];										//Array of steam handles assigned to steam input ports
		///@ignore
		steamGamepads = {};										//Map of `Input_GamepadType` to `InputSteamGamepadType`
		///@ignore
		steamInputTypeIgnore = [];								//Array of gamepad types to ignore as determined by steam input
		
		
		/** Initializes gamepad support through Steam.
		 * @ignore
		 * @return {Undefined} */
		static InitializeSteam = function() {
			//These will be used to set our system flags
			var _usingSteam = false;
			var _usingSteamworks = false;
			var _onSteamDeck = false;
			var _onWine = false;
			var _switchLabels = false;	
			
			
			//Setting up steam flags
			var _steamEnv = environment_get_variable("SteamEnv");
			if ((_steamEnv != "") && (_steamEnv == "1")) {
				_usingSteam = true;
			}
			
			
			//Check if using steamworks or steam deck
			try {
				_usingSteamworks = steam_input_init(true);
				_onSteamDeck = steam_utils_is_steam_running_on_steam_deck();
			}
			catch (error) {
				var _exception = new Exception("Input System", $"Steamworks extension unavailable.", self);
				LogDebug(_exception);
			}
			if (_usingSteamworks) {
				if (string(steam_get_app_id()) == "480") {
					ThrowInputError("Initializing Steam", "Steam Application ID '480' is reserved.\nPlease change to your game's actual Steam Application ID.If you need a testing ID you should:\n1. Use ID 378090\n2. Set Debug to Enabled\n3. Install the game itself (Rebel Wings) on Steam.");
				}
			}
			
			
			//Check if we're using steam deck without using steamworks
			if (!_onSteamDeck) {
				//Try deck environment 
				var _deckEnv = environment_get_variable("SteamDeck");
				if (_deckEnv != "") {
					_onSteamDeck = (_deckEnv == "1");
				}
				//try deck hardware identity
				else {
					var _os = os_get_info();
					if (ds_exists(_os, ds_type_map)) {
						var _id = undefined;
						if (INPUT_LINUX) {
							_id = _os[? "gl_renderer_string"];
						}
						else if (INPUT_WINDOWS) {
							_id = _os[? "video_adapter_description"];
						}
						
						//Steam Deck GPU Identifier
						if (!is_undefined(_id) && StringContains(_id, "AMD Custom GPU 0")) {
							_onSteamDeck = true;
						}
						
						ds_map_destroy(_os);
					}
				}
			}
			
			
			//Checking if in game labels should use steam's gamepad labels instead
			var _labels = environment_get_variable("SDL_GAMECONTROLLER_USE_BUTTON_LABELS");
			if (_labels != "") {
				_switchLabels = (_labels == "1");
			}
			//Default to using steam lables when on steam deck, but not on desktop
			else {
				_switchLabels = _onSteamDeck;
			}
			
			
			//Checking for the WINE emulator. Useful for trigger effects but otherwise unused by this library
			if (_usingSteamworks) {
				_onWine = (environment_get_variable("WINEDLLPATH") != "");
				
				//Building the steamGamepads struct.
				SteamSetGamepadType(steam_input_type_xbox_360_controller,   Input_GamepadType.xBox, "Xbox 360 Controller");
				SteamSetGamepadType(steam_input_type_xbox_one_controller,   Input_GamepadType.xBox, "Xbox One Controller");
				SteamSetGamepadType(steam_input_type_ps3_controller,        Input_GamepadType.ps4,  "PS3 Controller");
				SteamSetGamepadType(steam_input_type_ps4_controller,        Input_GamepadType.ps4,  "PS4 Controller");
				SteamSetGamepadType(steam_input_type_ps5_controller,        Input_GamepadType.ps5,  "PS5 Controller");
				SteamSetGamepadType(steam_input_type_steam_controller,      Input_GamepadType.xBox, "Steam Controller");
				SteamSetGamepadType(steam_input_type_steam_deck_controller, Input_GamepadType.xBox, "Steam Deck Controller");
				SteamSetGamepadType(steam_input_type_mobile_touch,          Input_GamepadType.xBox, "Steam Link");
				
				if (_switchLabels) {
					//Weird to assign xbox controlllers NinSwitch lables, but this is dictated by Steam Input so we have to add it
					SteamSetGamepadType(steam_input_type_switch_pro_controller, Input_GamepadType.xBox, "Switch Pro Controller");
					SteamSetGamepadType(steam_input_type_switch_joycon_single,  Input_GamepadType.xBox, "Joy-Con");
					SteamSetGamepadType(steam_input_type_switch_joycon_pair,    Input_GamepadType.xBox, "Joy-Con Pair");
				}
				else
				{   
					SteamSetGamepadType(steam_input_type_switch_pro_controller, Input_GamepadType.nintendoSwitch,	"Switch Pro Controller");
					SteamSetGamepadType(steam_input_type_switch_joycon_single,  Input_GamepadType.joyconRight,		"Joy-Con");
					SteamSetGamepadType(steam_input_type_switch_joycon_pair,    Input_GamepadType.nintendoSwitch,	"Joy-Con Pair");
				}
				
				SteamSetGamepadType("unknown", Input_GamepadType.unknown, "Controller");				
			}
			
			
			//Build a Linux-only gamepad ignore map
			if (INPUT_LINUX) {
				var _steamConfigs = environment_get_variable("EnableConfiguratorSupport");
				var _inSteam = (_usingSteam || _usingSteamworks);
				
				if (_inSteam && (_steamConfigs != "") && (_steamConfigs == string_digits(_steamConfigs))) {
					var _bitmask = new BitMask(real(_steamConfigs));
					
					//Resolve Steam Input configuration
					var _steamPS = _bitmask.IsBitActive(0);
					var _steamXbox = _bitmask.IsBitActive(1);
					var _steamGeneric = _bitmask.IsBitActive(2);
					var _steamSwitch = _bitmask.IsBitActive(3);
					
					if (_usingSteamworks || (environment_get_variable("SDL_GAMECONTROLLER_IGNORE_DEVICES") == "")) {
						//If ignore hint isn't set, GM accesses controllers meant to be blocked
						//We address this by adding the Steam config types to our own blocklist 
						if (_steamPS) {
							SteamIgnoreGamepadType([Input_GamepadType.ps4, Input_GamepadType.ps5]);
						}
						
						if (_steamXbox) {
							SteamIgnoreGamepadType([Input_GamepadType.xBox]);
						}
						
						if (_steamGeneric) { 
							SteamIgnoreGamepadType([Input_GamepadType.unknown]);
						}
						
						if (_steamSwitch) {
							SteamIgnoreGamepadType([Input_GamepadType.joyconLeft, Input_GamepadType.joyconRight, Input_GamepadType.nintendoSwitch]);
						}
					}
					
					//Check for a reducible type configuration
					if (!_steamGeneric && !_steamPS && (!_steamSwitch || _switchLabels)) {
						//The remaining configurations are in the Xbox Controller style including:
						//Steam Controller, Steam Link, Steam Deck, Xbox or Switch with AB/XY swap
						
						SteamSetGamepadType("unknown", Input_GamepadType.xBox, "Controller"); 
						if (INPUT_LOG_DEBUG) {
							LogDebug("Steam Input configuration indicates Xbox-like identity for virtual controllers");
						} 
					} 
				} 
			} 
			
			//Set our system flags related to steam
			systemFlags.SetBitState(Input_SystemFlags.onWine, _onWine);
			systemFlags.SetBitState(Input_SystemFlags.switchLabels, _switchLabels);
			systemFlags.SetBitState(Input_SystemFlags.usingSteam, _usingSteam);
			systemFlags.SetBitState(Input_SystemFlags.usingSteamDeck, _onSteamDeck);
			systemFlags.SetBitState(Input_SystemFlags.usingSteamworks, _usingSteamworks);
		}
		
		/** Helper function that adds a new SteamGamepadType to the InputSystem. Previously added gamepadPorts of the same steam type will be overwritten.
		 * @ignore
		 * @arg {Any} _steamType
		 * @arg {Enum.Input_GamepadType} _gamepadType
		 * @arg {String} _description
		 * @return {Undefined} */
		static SteamSetGamepadType = function(_steamType, _gamepadType, _description) {
			steamGamepads[$ _steamType] = new SteamGamepadType(_gamepadType, _description);
		}
		
		/** Returns the struct that can be used to convert the specified steam gamepad into a gamepad type the system can understand. 
		 * @arg {Real} _steamType The enumerated steam gamepad type. This is not a member of `Enum.Input_DeviceType`!
		 * @return {Struct.SteamGamepadType} */
		static SteamGetGamepadType = function(_steamType) {
			return StructTryGetMember(steamGamepads, _steamType);
		}		
		
		/** Checks the steam handles of gamepads connected to the platform via steam for any discrepencies that would indicate changes in gamepad connection. If discrepencies are found, the cached handles are updated and the method returns `true`.
		 * @return {Bool} */
		static SteamHandlesChanged = function() {
			//Memento for the handles
			var _oldHandles = steamHandles;
			var _newHandles = steam_input_get_connected_controllers();
			
			//Early exit if no steam handles
			if (!is_array(_newHandles)) {
				return false;
			}
			
			//Checking new handle values and types
			else {
				
				var _oldLen = array_length(_oldHandles);
				var _newLen = array_length(_newHandles);
				
				//Quick check: Handles will have changed if the count is different
				if (_oldLen != _newLen) {
					if (INPUT_LOG_STEAM_DEBUG) {
						LogDebug($"Steam handle array length doesn't match [old = {_oldLen} : new = {_newLen}].");
					}
					return true;
				} 
				
				//Fastest way to check for handle changes is to directly compare the new and old ones
				var i = 0; repeat (_newLen) {
					
					//Set the handles if there's a change
					if (_newHandles[i] != _oldHandles[i]) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"Steam handle value changed at [index = {i} : old = {_oldHandles[i]} : new = {_newHandles[i]}]");
						}
						steamHandles = _newHandles;
						return true;
					}
					i++;
				}
				
				
				//Otherwise do an in-depth check
				i = 0; repeat(array_length(gamepadPorts)) {
					
					var _gamepad = gamepadPorts[i];
					var _steamHandle = _gamepad.GetSteamHandle();
					var _handleIndex = _gamepad.GetSteamHandleIndex();
					var _actualIndex = steam_input_get_gamepad_index_for_controller(_steamHandle);
					
					//Set the handles if there's a change
					if ((_steamHandle != undefined) && (_handleIndex != _actualIndex)) {
						if (INPUT_LOG_STEAM_DEBUG) {
							LogDebug($"Steam gamepad index changed at \n[index = {i} : gamepad = {_steamHandle} gamepad number = {_handleIndex} \n previously gamepad number {_steamHandle} : currently gamepad number {_actualIndex}]");
						}
						steamHandles = _newHandles;
						return true;
					}
					i++;
				}
				
				return false;
			}
		}
		
		/** Checks if a gamepad type is ignored or not
		 * @arg {Enum.Input_GamepadType} _type 
		 * @return {Bool} */
		static SteamIsGamepadTypeIgnored = function(_type) {
			return array_contains(steamInputTypeIgnore, _type);
		}
		
		/** Add a gamepad type that should be ignored by steam.
		 * @arg {Enum.Input_GamepadType|Array<Enum.Input_GamepadType>} _type
		 * @return {Undefined} */
		static SteamIgnoreGamepadType = function(_type) {
			_type = ArrayConvertValue(_type);
			
			var i = 0; repeat(array_length(_type)) {
				var _val = _type[i++];
				ArrayPushUnique(steamInputTypeIgnore, _val);
			}
		}
		
		/** Returns `true` if steam has successfully been initialized and integrated.
		 * @return {Bool} */
		static UsingSteam = function() {
			return systemFlags.IsBitActive(Input_SystemFlags.usingSteamworks);
		}
		
		/** Returns `true` if the game is running on Steam Deck hardware
		 * @return {Bool} */
		static UsingSteamdeck = function() {
			return systemFlags.IsBitActive(Input_SystemFlags.usingSteamDeck);
		}
		
		/** Returns `true` if the game is running in the WINE emulator
		 * @return {Bool} */
		static UsingSteamWine = function() {
			return systemFlags.IsBitActive(Input_SystemFlags.onWine);
		}
		
		/** Returns `true` if the game is running in Steam Big Picture UI
		 * @return {Bool} */
		static UsingSteamBigPicture = function() {
			return systemFlags.IsBitActive(Input_SystemFlags.steamBigPicture);
		}
		
		/** Returns `true` if using steamworks.
		 * @return {Bool} */
		static UsingSteamworks = function() {
			return systemFlags.IsBitActive(Input_SystemFlags.usingSteamworks);
		}		
	#endregion
	
	
	#region Plug-ins
		
		///@ignore
		plugins = {};
		
		
		/** This function initializes all the plug ins defined for Input to be used. It should only be called once, and before the first "Collect" call.
		 * @ignore
		 * @return {Undefined} */
		static InitializePlugIns = function() {
			var _plugInDictionary = new InputPlugInDictionary();
			var _plugins = _plugInDictionary.plugIns;
			var i = 0; repeat(array_length(_plugins)) {
				var _plug = _plugins[i++];
				plugins[$ _plug.name] = _plug.Initialize(self);
			}
		}
		
		/** Helper function that checks if the current version of Input supports the plug-in
		 * @ignore
		 * @arg {String} _targetVersion
		 * @arg {String} _inputVersion
		 * @return {Bool} */
		static PlugInCompareVersion = function(_targetVersion, _inputVersion) {
			var _targetStrings = string_split(_targetVersion, ".", true);
			var _inputStrings = string_split(_inputVersion, ".", true);
			if (_targetStrings[0] != _inputStrings[0]) {
				return false;
			}
			
			return (real(_targetStrings[1] <= real(_inputStrings[1])));
		}
		
		/** Checks if the named plug in is defined in the system.
		 * @arg {String} _plugIn The name of the plug in to verify
		 * @return {Bool} */
		static PlugInExists = function(_plugIn) {
			return struct_exists(plugins, _plugIn);
		}
		
		
	#endregion
	
	
	#region Devices
		
		///@ignore
		rebindArray = [];																		//Array of device rebinding handlers for easier cycling
		///@ignore
		rebindingMap = {};																		//Map of devices to their rebinding handlers.
		///@ignore
		pointer = new InputPointer();															//Mouse/Touch abstraction
		///@ignore
		kbm = new InputDeviceKbm();																//Default Kbm device. For singleplayer, not couch co-op
		///@ignore
		touch = new InputDeviceTouch();															//Default touch device. For singleplayer, not couch co-op
		///@ignore
		generic = new InputDevice();															//Generic device. 
		
		///@ignore
		typeTable = new GamepadTypeLookupTable();												//Type table for gamepads. Helps know what gamepads to make in the `GamepadConnect()` call.
		///@ignore
		defaultGamepadButtonMap = new InputGamepadBindingTable();								//Holds the default gamepad button map checker functions	
		///@ignore
		defaultKbmButtonMap = new InputKbmBindingTable();										//Holds the default keyboard button map checker functions
		///@ignore
		gamepadPorts = array_create(gamepad_get_device_count(), undefined);						//An array that represents the InputSystem's controller ports
		///@ignore
		defaultGamepadType = Input_GamepadType.xBox;											//Default gamepad to instantiate for connecting gamepads if unable to correctly identify them.
		///@ignore
		gamepadLookupTable = new GamepadBindingNameLookupTable();								//gamepad button name lookup table
		///@ignore
		kbmLookUpTable = new KbmBindingNameLookupTable();										//keyboard+mouse button name lookup table
		
		///@ignore
		tapPresses = 0;																			//Current number of detected virtual button taps
		///@ignore
		tapReleases = 0;																		//Current number of detected virtual button tap releases
		///@ignore
		virtualButtons = [];																	//List of all virtual buttons connected to Input
		
		/** Makes sure that gamepads connected to the `InputSystem` match what's connected to the platform. Newly connected controllers have `InputDeviceGamepad` objects created to represent them in the `InputSystem`, and disconnected controllers remove their representing `InputDeviceGamepad`.
		 * @ignore
		 * @return {Undefined} */
		static GamepadUpdatePorts = function() {
			//Check for any new devices if on android
			if (INPUT_ANDROID && ((time - androidEnumTime) > INPUT_ANDROID_GAMEPAD_ENUMERATION_INTERVAL)) {
				androidEnumTime = time;
				gamepad_enumerate();
			} 
			
			//Expand the gamepad array so that it can fit in any newly detected gamepad devices.
			var _len = array_length(gamepadPorts);
			var _deviceCount = gamepad_get_device_count();
			if (_len != _deviceCount) {
				ArrayResizePadded(gamepadPorts, _deviceCount, undefined);
			}
			
			//Expanded gamepad array sets new indicies to empty values, so fill them with gamepad devices.
			//There should be one InputDeviceGamepad instance pre-made for each gamepad that could potentially connect.
			var _gamepadPort = 0; 
			repeat(_deviceCount) {
				
				//Check the gamepadPorts array for any empty ports. 
				//Should be a gamepad connected to each port (on the system side, not neccessarily true for the platform side).
				var _gamepad = GamepadTryGetAt(_gamepadPort);//Get system connected gamepad.
				var _connected = gamepad_is_connected(_gamepadPort);//check if this gamepad is connected to the platform
				
				
				//The Gamepad is still connected to the `InputSystem`
				if (!is_undefined(_gamepad)) {
					var _gpType = _gamepad.GetGamepadType();
					var _gpLastConnected = _gamepad.GetLastConnectedTime();
					
					//The gamepad is also still connected to the platform
					if (_connected) {
						
						//In the case of a switch controller, even though the platform knows it was still connected
						//it needs to be full disconnected then reinstantiated because their L+R reconnection confuses the system side.
						if (INPUT_SWITCH && (!_gamepad.IsSwitchController())) {
							GamepadDisconnect(_gamepadPort, true);
							GamepadConnect(_gamepadPort);
						}
						//Since the gamepad is still connected to both system and platform, just update connection time
						else {
							_gamepad.UpdateConnectedTime();
						}
					}
					
					//The gamepad is not connected to the platform (but connected to `InputSystem`)
					else {
						//Verify its not connected to the platform by checking its last connection time, then full disconnect it
						var _timeDiff = current_time - _gpLastConnected;
						if (_timeDiff >= INPUT_GAMEPADS_DISCONNECTION_TIMEOUT) {
							GamepadDisconnect(_gamepadPort, true);
						}
					}
					
					//NB: Don't worry about partial disconnected controllers, they're still connected platform side and system side, so they get unblocked elsewhere.
					
				}
				
				//There is a gamepad connected to the platform but not to `InputSystem`
				//So connect a new gamepad to the system.
				else if (_connected) {
					GamepadConnect(_gamepadPort);
				}
				
				//Check the next gamepad port
				_gamepadPort++;
			}
		}
		
		/** This function attempts to identify and create a specific instance of a subclass of `InputDeviceGamepad`. Gamepad is identified first by current platform, then by looking up product GUID data in the gamepad type table, then by the products hardware description if the table has no matching value. This method is called during `GamepadConnect()` to identify and create new gamepad instances. 
		 * @ignore
		 * @arg {Real} _port The port index that should be assiged to the gamepad
		 * @return {Struct.InputDeviceGamepad} */
		static GamepadDiscover = function(_port) {
			//Figure out what kind of controller was connected, then create a gamepad that can represent it. 
			//Easiest way is to check what console we're on, if any, and assign a controller that way.
			//The gamepads will resolve specific type conflicts (ie, ps4 or ps5 controller) on their own as a part of their instantiation, 
			//so only worry about figuring out what type to create.
			var _gamepad;
			if (INPUT_SWITCH) {
				_gamepad = new InputDeviceGamepadSwitch(_port);
			}
			else if (INPUT_PS4 || INPUT_PS5) {
				_gamepad = new InputDeviceGamepadPS(_port);
			}
			else if (INPUT_XBOX) {
				_gamepad = new InputDeviceGamepadXBox(_port);
			}
			
			//If we're not on console, we have to discover the gamepad type from its GUID data and create the gamepad that matches that type.
			else {
				
				if (INPUT_LOG_DEBUG) {
					LogDebug($"Discovering Gamepad Connected to Port {_port}");
				}			
				//Create an instance of InputGamepadGUID to handle guid parsing and data storage. Then get product description.
				//These values are used to attempt to identify a gamepad type.
				var _guidData = new InputGamepadGUID(gamepad_get_guid(_port));
				var _description = gamepad_get_description(_port);
				var _type = GamepadDiscover(_guidData, _description);	
				
				//Finally, create our gamepad representative for our discovered gamepad type
				if (_type == Input_GamepadType.joyconLeft || Input_GamepadType.joyconLeft || Input_GamepadType.nintendoSwitch) {
					_gamepad = new InputDeviceGamepadSwitch(_port, _description, _guidData);
				}
				else if (_type == Input_GamepadType.ps4 || _type == Input_GamepadType.ps5) {
					_gamepad = new InputDeviceGamepadPS(_port, _description, _guidData);
				}
				else if (_type == Input_GamepadType.xBox) {
					_gamepad = new InputDeviceGamepadXBox(_port, _description, _guidData);
				}
				//Failsafe: 
				else {
					//Set a generic gamepad device (Input_GamepadType.unknown)
					_gamepad = new InputDeviceGamepad(_port, _description, _guidData);
				}			
			}
			return _gamepad;		
		}
		
		/** Aux function for sorting buttons by their priority where 0 is the highest priority and values greater than 0 are of lesser priority.
		 * @ignore
		 * @arg {Struct.InputVirtualButton} _buttonA 
		 * @arg {Struct.InputVirtualButton} _buttonB
		 * @return {Real} */
		static SortVirtualButtons = function(_buttonA, _buttonB) {
			return sign(_buttonB.GetPriority() - _buttonA.GetPriority());
		}
		
		/** Returns `true` if the specified mouse button is a valid alternative tap button
		 * @ignore
		 * @arg {Constant} _button
		 * @return {Bool} */
		static IsAlternateTapButton = function(_button) {
			return ((_button == mb_left) || (_button == mb_any) || (_button == mb_none));
		}	
		
		
		/** Returns true if the input is allowed to be rebound. Returns false if it isn't
		 * @ignore
		 * @arg {Real} _input An input button constant (*vk_, mb_, gp_*)
		 * @arg {Array} _rebindingIgnore Array of buttons to be explicitly ignored
		 * @arg {Array} _rebindingAllow Array of buttons to be explicitly included
		 * @return {Bool} */
		static DeviceScanFilter = function(_input, _rebindingIgnore, _rebindingAllow) {
			_rebindingIgnore = ArrayConvertValue(_rebindingIgnore);
			_rebindingAllow = ArrayConvertValue(_rebindingAllow);
			var _pass = false;
			if (is_array(_rebindingIgnore)) {
					if (array_contains(_rebindingIgnore, _input)) {
					_pass = false;
				}
			}
			if (is_array(_rebindingAllow)) {
				if (!array_contains(_rebindingAllow, _input)) {
					_pass = false;
				} 				
			}
			return _pass;
		}
		
		/** Returns `true` if the specified device is of the specified type
		 * @ignore
		 * @arg {Struct.InputDevice} _device The device to check
		 * @arg {Enum.Input_DeviceType} _type The type to check agains
		 * @return {Undefined} */
		static DeviceTypeFilter = function(_device, _type) {
			return (_device.GetType() == _type);
		}
		
		#region General Devices
			/** Returns an array of all input devices that can be used with the current platform.
			 * @arg {Bool} [_includeGeneric `[=false]`] Optionally include `INPUT_GENERIC_DEVICE` in the return array. Default is false.
			 * @return {Array<StructInputDevice>} */ 
			static DeviceEnumerate = function(_includeGeneric = false) {
				var _devices = [];
				
				if (!INPUT_BAN_GAMEPADS) {
					_devices = GamepadEnumerate(_devices);
				}
				
				if (!INPUT_BAN_KBM) {
					array_push(_devices, kbm);
				}
				
				if (!INPUT_BAN_TOUCH) {
					array_push(_devices, touch);
				}
				
				if (_includeGeneric) {
					array_push(_devices, generic);
				}
				return _devices;
			}
			
			/** Returns an array of all input devices that can be used with the current platform that also match one of the device types provided in the filter array.
			 * @arg {Arra<Enum.Input_DeviceType>|Enum.Input_DeviceType} _allow The device type, or an array of types, for devices that you want to filter into the return. Device types not included here will be ignored
			 * @return {Array<StructInputDevice>} */ 
			static DeviceEnumerateFilter = function(_allow) {
				//Ensures our types are in an array
				_allow = ArrayConvertValue(_allow);
				
				//Copy pasting the logic from the standard device enumerate to specifically exclude types
				//Is faster than grabbing all compatible device types then removing them one at a time.
				var _devices = [];
				if (!INPUT_BAN_GAMEPADS) {
					if (array_contains(_allow, Input_DeviceType.gamepad)) {
						_devices = GamepadEnumerate(_devices);
					}
				}
				
				if (!INPUT_BAN_KBM) {
					if (array_contains(_allow, Input_DeviceType.kbm)) {
						array_push(_devices, kbm);
					}
				}
				
				if (!INPUT_BAN_TOUCH) {
					if (array_contains(_allow, Input_DeviceType.touch)) {
						array_push(_devices, touch);
					}
				}
				
				if (array_contains(_allow, Input_DeviceType.generic)) {
					array_push(_devices, generic);
				}
				return _devices;				
			}
			
			/** Returns `true` if the specified `InputDevice` is connected to the current platform. Returns `false` if the device is not supported or incompatible.
			 * @arg {Struct.InputDevice} _device The device to check.
			 * @return {Bool} */
			static DeviceIsConnected = function(_device) {
				//Assume false
				var _bool = false;
				
				if (!is_undefined(_device)) {
					//Assign `_bool` according to type specific conditions
					_bool = _device.CheckPlatformConnection();
				}
				return _bool;
			}
			
			/** Returns the first available and unassigned `InputDevice` that has detectable input activity. Returns `undefined` if no such device is found.
			 * @return {Struct.InputDevice} */
			static DeviceFindNewActivity = function() {
				var _devices = DeviceEnumerate(false);
				var i = 0; repeat(array_length(_devices)) {
					var _device = _devices[i++];
					if (_device.IsActive() && _device.IsAvailable()) {
						return _device;
					}
				}
			}			
			
			/** Returns `true` if the targeted device has activity for the specified verb.
			 * @arg {Struct.InputDevice} _device The device to use in the check
			 * @arg {Enum.Input_Verb} _verb The index of the verb to check activity for
			 * @arg {Real} [_playerIndex] `[=0]` The index of the player providing the verb definition
			 * @return {Real} */
			static DeviceHasVerbActivity = function(_device, _verb, _playerIndex = 0) {
				var _type = _device.GetType();
				var _player = GetPlayer(_playerIndex);
				var _verbDef = _player.GetVerb(_verb);
				var _active = false;
				
				//Kbm and gamepads are the only device types with checkable buttons
				if (_type == Input_DeviceType.kbm) {
					_active = _device.CheckButtonAny(_verbDef.BindingsGetKbm());
				}
				else if (_type == Input_DeviceType.gamepad) {
					_active = _device.CheckButtonAny(_verbDef.BindingsGetGamepad());
				}
				return _active;
			} 			
			
			/** Returns the first available and unassigned `InputDevice` that has detectable input activity on the specified verb. Returns `undefined` if no such device is found.
			 * @arg {Enum.Input_Verb} _verb The verb to check for device activity
			 * @arg {Real} [_playerIndex] `[=0]` The player index that will provide the verb definition for the check.
			 * @return {Struct.InputDevice} */
			static DeviceFindNewActivityForVerb = function(_verb, _playerIndex = 0) {
				var _devices = DeviceEnumerate(false);
				var i = 0; repeat(array_length(_devices)) {
					var _device = _devices[i++];
					if (DeviceHasVerbActivity(_device, _verb, _playerIndex)) {
						return _device;
					}
				}
			}
			
			/** Returns `true` if a device is hooked into the rebinding loop to scan for new button bindings.
			 * @arg {Struct.InputDevice} _device
			 * @return {Bool} */
			static DeviceGetRebinding = function(_device) {
				return struct_exists(rebindingMap, _device);
			}
			
			/** Allows a device to actively scan for all verbs. Results can be returned by calling DeviceGetRebindingResult. Only viable for gamepadPorts and KBM. Bindings to explicitly ignore or allow can be passed in via the optional ignore/allow structs. It should be noted that a device being scanned will continue to report input as normal. To prevent input from leaking to, e.g. interface navigation, you should check against `DeviceGetRebinding()` where appropriate
			 * @arg {Struct.InputDevice} _device The Device to set to a rebinding state.
			 * @arg {Array<Enum.Input_Verbs>} [_ignore] Optional array of `Enum.Input_Verbs` that should be explicitly ignored during scanning
			 * @arg {Array<Enum.Input_Verbs>} [_allow] Optional array of `Enum.Input_Verbs` that should be explicitly allowed during scanning
			 * @arg {Bool} [_consume] Whether or not the device's owner should have all of its verbs consumed or not. Defaults to true.
			 * @return {Undefined} */
			static DeviceEnableRebinding = function(_device, _ignore = undefined, _allow = undefined, _consume = true) {
				if (is_undefined(_device)) {
					return;
				}
				//Only allow gamepadPorts and kbm devices to rebind
				var _type = _device.GetType();
				if (_type != Input_DeviceType.kbm || _type != Input_DeviceType.gamepad) {
					return;
				}
				
				//Only bother making the handler if there isn't one for the device which is why we dont use `StructSetMemberUnique`
				if (!struct_exists(rebindingMap, _device)) {
					//Create and add the handler
					var _handler = new InputRebindingHandler(_device, _ignore, _allow);
					rebindingMap[$ _device] = _handler;
					array_push(rebindArray, _handler);
					
					//Consume owner verbs
					if (_consume) {
						var _player = _device.GetOwner();
						if (!is_undefined(_player)) {
							_player.VerbConsumeAll();
						}
					}
				}
			}
			
			/** Stops a device from scanning for new verb bindings.
			 * @arg {Struct.InputDevice} _device The device to stop rebinding updates for
			 * @arg {Bool} [_consume] Whether or not the device's owner should have all of its verbs consumed or not. Defaults to true.
			 * @return {Undefined} */
			static DeviceDisableRebinding = function(_device, _consume = true) {
				var _handler = StructTryGetMember(rebindingMap, _device);
				if (!is_undefined(_handler)) {
					//Removing the handler from our containers
					struct_remove(rebindingMap, _device);
					ArrayRemove(rebindArray, _handler);
					
					//Consuming verbs for the device owner
					if (_consume) {
						var _player = _device.GetOwner();
						if (!is_undefined(_player)) {
							_player.VerbConsumeAll();
						}
					}
				}		
			}
			
			/** Stops all devices from scanning for new button bindings.
			 * @return {Undefined} */
			static DeviceDisableRebindingAll = function() {
				var _devices = DeviceEnumerate(false);
				var i = 0; repeat(array_length(_devices)) {
					DeviceDisableRebinding(_devices[i++], false);
				}
			}
			
			/** Returns the button constant found for a device as a result of the rebinding process. Returns `undefined` if no button was found.
			 * @arg {Struct.InputDevice} _device The device to get the rebinding result for
			 * @return {Constant.InputButton} */
			static DeviceGetRebindingResult = function(_device) {
				var _handler = StructTryGetMember(rebindingMap, _device);
				if (!is_undefined(_handler)) {
					return _handler.RebindingResult();
				}
			}
			
		#endregion
		
		
		
		#region KBM Devices
			
			/** Returns the name of a button binding from the keyboard and mouse lookup table.
			 * @arg {Constant.KbmButton} _button A `vk_*` or `mb_*` button constant
			 * @arg {String} [_unknownButton] Optional default name to return if the specified button is not found.
			 * @return {String} */
			static KbmGetBindingName = function(_button, _unknownButton = "???") {
				return StructTryGetMember(kbmLookUpTable, _button) ?? _unknownButton;
			}
			
			/** Returns the default kbm checker function for a specific keyboard or mouse button.
			 * @arg {Constant.KbmButton} _button A `vk_*` or `mb_*` button constant
			 * @return {Function} */
			static KbmGetDefaultButtonMap = function(_button, _unknownButton) {
				return defaultKbmButtonMap[$ _button];
			}
			
			/** Returns `true` if the specified Keyboard or Mouse button is currently held down.
			 * @arg {Constant.KbmButton} _button A `vk_*` or `mb_*` button constant
			 * @return {Bool} */
			static KbmCheckButton = function(_button) {
				return kbm.CheckButton(_button);
			}
			
			
			/** Returns the first KBM button constant that has an active input value. Returns `undefined` if no active input is detected.
			 * @arg {Struct.InputDeviceKbm} _kbmDevice The KBM device to scan for bindings
			 * @arg {Array} _rebindingIgnore Array of buttons to be explicitly ignored
			 * @arg {Array} _rebindingAllow Array of buttons to be explicitly included			 
			 * @return {Constant.KbmButton} */
			static KbmBindingScan = function(_kbmDevice, _rebindingIgnore, _rebindingAllow) {
				//Check keyboard buttons
				var _binding = _kbmDevice.GetKeyboardOutput();
				if (DeviceScanFilter(_binding, _rebindingIgnore, _rebindingAllow)) {
					return _binding;
				}
				
				//If a keyboard button wasn't returned, check Mouse buttons
				_binding = _kbmDevice.GetMouseOutput();
				if (DeviceScanFilter(_binding, _rebindingIgnore, _rebindingAllow)) {
					return _binding;
				}						
			}	
		#endregion
		
		
		#region Gamepad Devices
			
			/** Returns the name of a button binding from either the gamepad or kbm binding name lookup tables.
			 * @arg {Real} _button The button constant to get the name of (*vk_, mb_, or gp_ constant)
			 * @arg {String} [_unknownBinding] The name to use in the event the name of the binding cannot be found or doesn't exist. Defaults to "???".
			 * @return {String} */
			static GamepadGetBindingName = function(_button, _unknownBinding = "???") {
				return StructTryGetMember(gamepadLookupTable, _button) ?? _unknownBinding;
			}
			
			/** Returns the default gamepad checker function for a specific gamepad button.
			 * @arg {Constant} _button A gp_* button constant.
			 * @return {Function} */
			static GamepadGetDefaultButtonMap = function(_button) {
				return defaultGamepadButtonMap[$ _button];
			}
			
			/** Returns the array of all gamepads that are connected to the system. If no valid gamepads are found, an empty array is returned instead.
			 * @arg {Array<StructInputDeviceGamepad>} [_gamepadArray] `[=[]]` Optionally provide an array to push connected gamepads into. If no array is specified, a new array is created.
			 * @return {Array<StructInputDeviceGamepad>} */
			static GamepadEnumerate = function(_gamepadArray = []) {
				if (!is_array(_gamepadArray)) {
					ThrowInvalidType("GamepadEnumerate", "_gamepadArray", _gamepadArray, "Array", self);
				}
				
				if (!INPUT_BAN_GAMEPADS) {
					//Real devices should take prio over virtual ones to avoid thrashing
					var _sortOrder = 1;
					var _device = 0;
					var _usingWorks = systemFlags.IsBitActive(Input_SystemFlags.usingSteamworks);
					var _gpCount = gamepad_get_device_count();
					
					//Search last to first on platforms with low-index controllers (steam input, ViGEm)
					//We want real devices to take priority over virtual ones where possible to avoid thrashing
					if (!INPUT_WEB && (INPUT_MACOS || (!_usingWorks && INPUT_WINDOWS) || (_usingWorks && INPUT_LINUX))) {
						_sortOrder = -1;
						_device = _gpCount - 1;
					} 
					
					//Enumerate devices
					repeat(_gpCount) {
						if (DeviceIsConnected(gamepadPorts[_device])) {
							array_push(_gamepadArray, _device);
							_device += _sortOrder;
						}
					}					
				}
				
				return _gamepadArray;
			}
			
			/** Returns the `InputDeviceGamepad` connected to the specified gamepad port. Returns `undefined` if no gamepad is detected.
			 * @return {Struct.InputDeviceGamepad} */
			static GamepadTryGetAt = function(_port) {
				return ArrayTryGetElement(gamepadPorts, _port);
			}
			
			/** Sets the internal system port that a gamepad is connected to.
			 * @arg {Struct.InputDeviceGamepad} _gamepad
			 * @arg {Real} _index
			 * @return {Undefined} */
			static GamepadSetAt = function(_gamepad, _index) {
				gamepadPorts[_index] = _gamepad;
			}			
			
			/** Set the default gamepad type. Default gamepad type is used to determine which subclass of `InputDeviceGamepad` to instantiate for newly connected gamepads in the event its specific type is unable to be identified.
			 * @arg {Enum.Input_GamepadType} _type The type to set
			 * @return {Undefined} */
			static GamepadSetDefaultType = function(_type) {
				if (!MathIsBetweenEquals(_type, Input_GamepadType.none, Input_GamepadType.unknown)) {
					if (INPUT_LOG_WARNING) {
						LogWarning($"InputSystem::GamepadSetDefaultType -> Gamepad type ({_type}) not recognized. Unable to change default gamepad type.");
					}
					return;
				}
				defaultGamepadType = _type;
			}
			
			/** Returns the default gamepad type. Default gamepad type is used to determine which subclass of `InputDeviceGamepad` to instantiate for newly connected gamepads in the event its specific type is unable to be identified.
			 * @return {Constant.Input_GamepadType} */
			static GamepadGetDefaultType = function() {
				return defaultGamepadType;
			}			
			
			/** Returns the gamepad GUID data for the gamepad connected to the specified system port. If there is no gamepad at the specified port a blank GUID is returned instead
			 * @arg {Real} _port The system port to get gamepad data from
			 * @return {Struct.InputGamepadGUID} */
			static GamepadGetGUID = function(_port) {
				var _gamepad = GamepadTryGetAt(_port);
				if (!is_undefined(_gamepad)) {
					return new InputGamepadGUID();
				}
				return _gamepad.GetGUID();
			}
			
			/** Returns the first gamepad button constant that has an active input value. Returns `undefined` if no active input is detected.
			 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to scan bindings for.
			 * @return {Constant.GamepadButton} */
			static GamepadBindingScan = function(_gamepad, _rebindingIgnore, _rebindingAllow) {
				//Early exit if its not a gamepad
				if (!is_instanceof(_gamepad, InputDeviceGamepad)) {
					return undefined;
				}
				
				var _binding = _gamepad.GetOutput();
				if (DeviceScanFilter(_binding, _rebindingIgnore, _rebindingAllow)) {
					return _binding;
				}
			}				
			
			/** Returns `true` if the specified button or array of buttons contains a thumbstick button constant.
			 * @arg {Constant.InputButton|Array<Constant.InputButton>} _button A single button or array of buttons to check.
			 * @return {Bool} */
			static GamepadIsBindingThumbstick = function(_buttons = undefined) {
				static _thumbstick = [
					gp_axislh, gp_axislv, gp_axisrh, gp_axisrv,
					-gp_axislh, -gp_axislv, -gp_axisrh, -gp_axisrv
				]
				return (ArrayContainsAnyValue(_buttons, _thumbstick));			
				
			}				
			
			/** Returns `true` if the `InputSystem` has any gamepads that are connected.
			 * @return {Bool} */
			static GamepadConnectedAny = function() {
				var _bool = false;
				if (!INPUT_BAN_GAMEPADS) {
					var i = 0; repeat(array_length(gamepadPorts)) {
						if (DeviceIsConnected(gamepadPorts[i++])) {
							_bool = true;
							break;
						}
					}
				}
				return _bool;
			}
			
			/** Identify a gamepad port on the system side to connect a gamepad to. The specific gamepad type is automatically identified, instantiated, and connected to the specified port.
			 * @arg {Real} _port The gamepad port where a new gamepad was detected 
			 * @return {Undefined} */		
			static GamepadConnect = function(_port) {
				if (!AssertIsNumeric(_port, "Invalid Gamepad Port")) {
					ThrowInvalidType("GamepadConnect", "_port", _port, "Numeric");
				}
				
				//Discover the gamepad type being connected.
				var _gamepad = GamepadDiscover(_port);
				
				//Now that we have our correct gamepad representation, 
				//we can assign it to an internal connection port that matches its actual connection port.
				GamepadSetAt(_port, _gamepad);
				
				
				//With the gamepad now connected to its internal port we can update its connection timestamp
				_gamepad.UpdateConnectedTime();
				
				if (INPUT_LOG_INFO) {
					LogInfo($"InputSystem::GamepadConnect -> Gamepad connected at port {_port}");
				}	
				
				//End by triggering a gamepadConnected event.
				events.Publish(InputEvent.gamepadConnected, [_gamepad]);
			}
			
			/** Disconnect a gamepad at the system level. Optionally perform a "soft disconnect" to block specific gamepads from interacting with the system, or perform a "hard disconnect" which completely removes the gamepad from the system until it is re-instantiated. Gamepads that have been soft disconnected must be manually un-blocked for them to resume interacting with the system. Note that if you provide the port of a soft disconnected gamepad to `GamepadConnect` a new gamepad instance will overwrite the disconnected gamepad.
			 * @arg {Real} _port The gamepad port that detected a disconnect
			 * @arg {Bool} _fullDisconnect Set `true` to initiate a full disconnect which removes the gamepad instance (it will be reinstantiated next time a gamepad is connected). Defaults to `false` for a soft disconnect.
			 * @return {Undefined} */
			static GamepadDisconnect = function(_port, _hardDisconnect = false) {
				var _gamepad = GamepadTryGetAt(_port);
				
				if (!is_undefined(_gamepad)) {
					//Full disconnect removes the gamepad from the system. 
					//For example, changing a controller types from Xbox to Switch Pro on PC or something.
					//It must be reinstantiated
					if (_hardDisconnect) {
						if (INPUT_LOG_DEBUG) {
							LogDebug($"InputSystem -> Gamepad disconnected at index: {_port}");
						}
						//Keeps gamepad port size to save a bit of overhead caused by array resizing
						//It ain't much, but it's honest work.
						ArrayRemoveByIndex(gamepadPorts, _port, true);
					}
					
					//Partial disconnect (like if it went to sleep). Block the gamepad so
					//we don't have to reinstantiate it.
					else {
						if (INPUT_LOG_DEBUG) {
							LogDebug($"InputSystem -> Partial gamepad disconnected at index: {_port}");
						}
						_gamepad.SetBlocked(true);
					}
				}
				events.Publish(InputEvent.gamepadDisconnected, [_gamepad, _port, _hardDisconnect]);
			}						
			
		#endregion
		
		
		#region Pointers (Touch Input)
			/** Returns `true` if pointers are being blocked by window defocus.
			 * @return {Bool} */
			static PointerIsBlockedByWindowDefocus = function() {
				return systemFlags.IsBitActive(Input_SystemFlags.pointerBlockedByDefocus);
			}
			
			/** Set if pointers should be blocked by window defocus.
			 * @arg {Bool} _bool Set `true` to block pointers; set `false` to stop blocking pointers
			 * @return {Undefined} */
			static PointerSetBlockedByWindowDefocus = function(_bool) {
				systemFlags.SetBitState(Input_SystemFlags.pointerBlockedByDefocus, _bool);
			}
			
			/** Returns `true` if pointer's are blocked from input collection for the current frame.
			 * @return {Bool} */
			static PointerIsBlockedThisFrame = function() {
				return systemFlags.IsBitActive(Input_SystemFlags.pointerBlockedThisFrame);
			}
			
			/** Set if pointer's should be blocked from input collection for the current frame or not.
			 * @arg {Bool} _bool Set `true` to block pointers. Set `false` to unblock them.
			 * @return {Undefined} */
			static PointerSetBlockedThisFrame = function(_bool) {
				systemFlags.SetBitState(Input_SystemFlags.pointerBlockedThisFrame, _bool);
			}
			
			/** Returns `true` if pointer's are blocked from input collection by the user.
			 * @return {Bool} */
			static PointerIsBlockedByUser = function() {
				return systemFlags.IsBitActive(Input_SystemFlags.pointerBlockedByUser);
			}
			
			/** Set if pointer's should be blocked from input collection by the user.
			 * @arg {Bool} _bool Set `true` to block pointers. Set `false` to unblock them.
			 * @return {Undefined} */
			static PointerSetBlockedByUser = function(_bool) {
				systemFlags.SetBitState(Input_SystemFlags.pointerBlockedByUser, _bool);
			}
			
			/** Returns `true` if pointer's are blocked from input collection
			 * @return {Bool} */
			static PointerIsBlocked = function() {
				return systemFlags.IsBitActive(Input_SystemFlags.pointerBlocked);
			}
			
			/** Set if pointer's should be blocked from input collection
			 * @arg {Bool} _bool Set `true` to block pointers. Set `false` to unblock them.
			 * @return {Undefined} */
			static PointerSetBlocked = function(_bool) {
				systemFlags.SetBitState(Input_SystemFlags.pointerBlocked, _bool);
			}
			
			/** Returns `true` if the pointer has changed positions.
			 * @return {Bool} */
			static PointerMoved = function() {
				return systemFlags.IsBitActive(Input_SystemFlags.pointerMoved);
			}	
			
			/** Returns `true` if the specified touch input is newly tapped in the current frame. If the specified touch input was previously tapped, it must be released before it this method can return `true` again.
			 * @arg {Constant.MouseButton} [_button] Optional mouse button to use for tap (if different from the default mb_left).
			 * @return {Bool} */
			static PointerCheckTap = function(_button = mb_left) {
				if (PointerIsBlocked() || INPUT_BLOCK_MOUSE_CHECKS) {
					return false;
				}
				
				if (!IsAlternateTapButton(_button)) {
					return device_mouse_check_button_pressed(0, _button);
				}
				
				//Checking for unique mb_left, mb_any, and mb_none cases.
				var _isLeft = (INPUT_WINDOWS && IsTapClick()) ? true : device_mouse_check_button_pressed(0, mb_left);
				switch (_button) {
					case mb_left: 
						return _isLeft;
					break;
					
					case mb_any:
						return (_isLeft || device_mouse_check_button_pressed(0, mb_any));
					break;
					
					case mb_none:
						return (!_isLeft && device_mouse_check_button_pressed(0, mb_none));
					break;
				}
				
				ThrowInputError("PointerCheckButton", $"Invalid Mouse Button [buttonIndex = {_button}]");	
			}
			
			/** Returns `true` if the specified touch input is held down for the current frame.
			 * @arg {Constant.MouseButton} [_button] Optional mouse button to use for tap (if different from the default mb_left).
			 * @return {Bool} */
			static PointerCheckTapHold = function(_button = mb_left) {
				if (PointerIsBlocked() || INPUT_BLOCK_MOUSE_CHECKS) {
					return false;
				}
				
				if (!IsAlternateTapButton(_button)) {
					return device_mouse_check_button(0, _button);
				}
				
				var _isLeft;
				if (INPUT_WINDOWS && IsTapClick()) {
					_isLeft = true;
				}
				else if (INPUT_MOBILE) {
					//Touch clicks. Edge testing
					if (INPUT_TOUCH_EDGE_DEADZONE > 0) {
						pointer.UpdateGUIPosition();
						var _guiSize = new Vector2(display_get_gui_width(), display_get_gui_height());
						var _edge = new Vector2(INPUT_TOUCH_EDGE_DEADZONE, INPUT_TOUCH_EDGE_DEADZONE);
						
						var _guiPos = pointer.GetGUIPosition();
						if (_guiPos.LessThan(_edge) || _guiPos.GreaterThan(_guiSize.Subtract(_edge))) {
							_isLeft = false;
						}
						else {
							_isLeft = device_mouse_check_button(0, _button);
						}
					}				
				}
				else {
					_isLeft = device_mouse_check_button_pressed(0, mb_left);
				}
				
				switch (_button) {
					case mb_left: 
						return _isLeft;
					break;
					
					case mb_any:
						return (_isLeft || device_mouse_check_button_pressed(0, mb_any));
					break;
					
					case mb_none:
						return (!_isLeft && device_mouse_check_button_pressed(0, mb_none));
					break;
				}
				ThrowInputError("PointerCheckTapHold", $"Invalid Mouse Button [buttonIndex = {_button}]");													
			}	
			
			/** Returns `true` if the specified mouse button or mobile touch is newly released in the current frame.
			 * @arg {Constant.MouseButton} [_button] Optional mouse button to use for tap (if different from the default mb_left).
			 * @return {Bool} */
			static PointerCheckTapReleased = function(_button = mb_left) {
				if (INPUT_BLOCK_MOUSE_CHECKS || PointerIsBlocked()) {
					return false;
				}
				
				//Make sure a button pressed by a freshly blocked pointer still fires a release event.
				if (PointerIsBlockedThisFrame()) {
					return PointerCheckTap(_button);
				}
				if (!IsAlternateTapButton(_button)) {
					return device_mouse_check_button_released(0, _button);
				}
				
				//Checking for unique mb_left, mb_any, and mb_none cases.
				//Check windows
				var _isLeft = false;
				if (INPUT_WINDOWS && IsTapClick()) {
					_isLeft = true;
				}
				//Check mobile
				else if (INPUT_MOBILE) {
					//Touch clicks. Edge testing
					if (INPUT_TOUCH_EDGE_DEADZONE > 0) {
						pointer.UpdateGUIPosition();
						var _guiSize = new Vector2(display_get_gui_width(), display_get_gui_height());
						var _edge = new Vector2(INPUT_TOUCH_EDGE_DEADZONE, INPUT_TOUCH_EDGE_DEADZONE);
						var _guiPos = pointer.GetGUIPosition();
						
						if (_guiPos.LessThan(_edge) || _guiPos.GreaterThan(_guiSize.Subtract(_edge))) {
							_isLeft = false;
						}
						else {
							_isLeft = device_mouse_check_button_released(0, mb_left);
						}
					}				
				}
				//Basic mouse
				else {
					_isLeft = device_mouse_check_button_released(0, mb_left);
				}
				
				
				switch (_button) {
					case mb_left:
						return _isLeft;
					break;
					
					case mb_any:
						return (_isLeft || device_mouse_check_button_released(0, mb_any));
					break;
					
					case mb_none:
						return (!_isLeft && device_mouse_check_button_released(0, mb_none));
					break;
				}	
				
				ThrowInputError("PointerCheckTapReleased", $"Invalid Mouse Button [buttonIndex = {_button}]");	
			}
			
			/** Returns the current device space position of the pointer
			 * @return {Struct.Vector2} */
			static PointerGetDevicePosition = function() {
				return pointer.GetDevicePosition();
			}	
			
			/** Returns the device space position of the pointer during the previous frame.
			 * @return {Struct.Vector2} */
			static PointerGetPreviousPosition = function() {
				return pointer.GetPreviousPosition();
			}
			
			/** Returns the position of the pointer in GUI space
			 * @return {Struct.Vector2} */
			static PointerGetGuiPosition = function() {
				return pointer.GetGUIPosition();
			}
			
			/** Returns the current positition of the pointer in room space.
			 * @return {Struct.Vector2} */
			static PointerGetRoomPosition = function() {
				return pointer.GetRoomPosition();
			}		
		#endregion
		
		#region Virtual Buttons
			
			/** Adds a new `InputVirtualButton` to be detected by the system
			 * @arg {Struct.InputVirtualButton} _vb
			 * @return {Undefined} */
			static AddVirtualButton = function(_vb) {
				array_push(virtualButtons, _vb);
			}		
			
			/** Reset's all `InputVirtualButton` instances to their initial state, rendering them inoperable.
			 * @return {Undefined} */
			static VirtualButtonResetAll = function() {
				var _len = array_length(virtualButtons);
				var i = 0; repeat (_len) {
					virtualButtons[i++].ClearState();
				}
			}			
		#endregion
	#endregion
	
	
	#region Players
		
		///@ignore
		players = array_create(INPUT_MAX_PLAYERS);								//Array of players connected to the system.
		///@ignore
		components = array_create(INPUT_MAX_PLAYERS);							//Array of players indicies and their components
		///@ignore
		lowestConnectedPlayerIndex = undefined;									//The index of the first player that has a system connected device.
		
		
		
		/** Initializes an `InputPlayer` and `InputSystemComponent` for each player that could potentially be connected. Player 0 is also assigned a device and connected to the system.
		 * @ignore
		 * @return {Undefined} */
		static InitializePlayers = function() {
			//Cleanup missing verb definitions, just in case.
			var i = 0; repeat(verbCount) {
				if (!is_instanceof(verbDefinitions[i], InputVerb)) {
					verbDefinitions[i] = undefined;
				}
				i++;
			}
			
			//Instantiate our players and their respective components.
			i = 0; repeat(INPUT_MAX_PLAYERS) {
				var _player = new InputPlayer();
				players[i] = _player;
				components[i] = new InputSystemComponent(i);
				i++;
			}
			
			//Setup the preferred input device for the default player.
			var _device;
			var _player = players[0];
			if (INPUT_MOBILE) {
				_device = touch;
			}
			else if (INPUT_DESKTOP) {
				_device = kbm;
			}
			else if (INPUT_CONSOLE) {
				//Check for gamepad connections
				GamepadUpdatePorts();
				
				var _gamepadCount = gamepad_get_device_count();//Num of connected gamepads
				var j = 0; repeat(_gamepadCount) {
					//Set the default player device to the lowest connected gamepad. 
					var _gamepad = GamepadTryGetAt(j++);
					if (DeviceIsConnected(_gamepad)) {
						_device = _gamepad;
					}
				}
			}
			_player.SetDevice(_device);
		}		
		
		/** Returns `true` if the specified player index is valid.
		 * @arg {Real} _index The player index to validate.
		 * @return {Undefined} */
		static ValidatePlayerIndex = function(_index) {
			return MathIsBetweenEquals(_index, 0, INPUT_MAX_PLAYERS);
		}
		
		/** Returns the `InputPlayer` found at the specified index.
		 * @arg {Real} _index The index of the profile to return
		 * @return {Struct.InputPlayer} */
		static GetPlayer = function(_index) {
			if (INPUT_SAFETY_CHECKS) {
				if (!ValidatePlayerIndex(_index)) {
					ThrowInvalidPlayerIndex("GetPlayer", _index, self);
				}
			}
			return players[_index];
		}
		
		/** Returns the first component that has a connected device. Returns `undefined` if no players have a connected device.
		 * @return {Struct.InputSystemComponent} */
		static GetFirstConnectedPlayer = function() {
			return (ValidatePlayerIndex(lowestConnectedPlayerIndex)) ? GetPlayer(lowestConnectedPlayerIndex) : undefined;
		}
		
		/** Returns the first `InputSystemComponent` that is assigned a generic `InputDevice`. Returns `undefined` if no component is assigned a generic device.
		 * @return {Struct.InputPlayer} */
		static GetPlayerWithGenericDevice = function() {
			for (var i = 0; i < INPUT_MAX_PLAYERS; i++) {
				var _player = players[i];
				if (_player.UsesGeneric()) {
					return _player;
				}
			}
		}
		
		/** Returns the first `InputPlayer` that is assigned a gamepad. Returns `undefined` if no players are using gamepads.
		 * @return {Struct.InputPlayer} */		
		static GetPlayerWithGamepad = function() {
			for (var i = 0; i < INPUT_MAX_PLAYERS; i++) {
				var _player = players[i];
				if (_player.UsesGamepad()) {
					return _player;
				}
			}			
		}
		
		/** Returns `true` if the specified player index is supposed to reference all player indexes.
		 * @arg {Real} _playerIndex The index to check
		 * @return {Bool} */
		static PlayerIndexIsRecursive = function(_playerIndex) {
			return (is_undefined(_playerIndex) || (_playerIndex == all));
		}	
		
		/** Returns the `InputDevice` assigned to the specified player
		 * @arg {Real} _playerIndex The index of the player to get the device from
		 * @return {Struct.InputDevice} */
		static PlayerGetDevice = function(_playerIndex) {
			return GetPlayer(_playerIndex).GetDevice();
		}			 
		
		/** Change which device is currently being used by a player. Afterwards, triggers `InputEvent.playerDeviceChanged
		 * @arg {Real} _playerIndex The index for the player receiving a new device assignment
		 * @arg {Struct.InputDevice} _device The input device to assign to the component. Set `undefined` to remove the player's device instead.
		 * @return {Undefined} */
		static PlayerChangeDevice = function(_playerIndex, _device) {
			//Only allow hotswaps for player 0
			if (IsHotSwapEnabled()) {
				if ((_playerIndex != 0) && is_instanceof(_device, InputDevice)) {
					ThrowInputError("SetDevice", $"Cannot change input device for player {_playerIndex} - hotswap mode is enabled", self);
				}
			}
			
			//Don't do work if we're not actually changing devices.
			var _player = GetPlayer(_playerIndex);
			var _oldDevice = _player.GetDevice();
			if (_oldDevice == _device) {
				return;
			}
			
			//Set the device
			_player.SetDevice(_device);
			
			//Send event notice
			events.Publish(InputEvent.playerDeviceChanged, [_playerIndex, _oldDevice, _device]);
		}
		
		/** Returns the number of `InputSystemComponents` that have a device connected to the `InputSystem`
		 * @return {Undefined} */
		static PlayerConnectionCount = function() {
			var _count = 0;
			var i = 0; repeat(array_length(players)) {
				if (players[i++].IsConnected()) {
					_count++;
				}
			}
			return _count;
		}
		
		/** Returns the number of players that have an assigned device.
		 * @return {Real} */
		static PlayerDeviceCount = function() {
			var _count = 0;
			var i = 0; repeat(array_length(players)) {
				if (players[i++].HasDevice()) {
					_count++;
				}
			}
			return _count;			
		}
		
		/** Finds a button bound to a verb at the specified position, then searchs for all verbs bound to it. If no verbs are found, an empty array is returned instead. This method triggers `InputEvent.findBindingCollisions`
		 * @arg {Real} _playerIndex The index of the player who should look for binding collisions.
		 * @arg {Real} _verbIndex The index of the verb that has the binding you want to look for.
		 * @arg {Real} [_bindingPosition] `[=0]` The binding index of the button on the verb.
		 * @arg {Bool} [_forGamepad] `[=false]` Set to `true` if you want to look for a gamepad button using the binding index.
		 * @arg {Array} [_resultBag] Optionally provide an array where results should be stored.
		 * @return {Array<StructInputBindingCapture>} */
		static PlayerFindBindingCollisions = function(_playerIndex, _verbIndex, _bindingPosition = 0, _forGamepad = false, _resultBag = undefined) {
			var _player = GetPlayer(_playerIndex);
			var _verb = _player.GetVerb(_verbIndex);
			var _button = _verb.GetButtonBinding(_bindingPosition, _forGamepad);
			var _array = _player.FindVerbsBoundTo(_button, _forGamepad, _resultBag);
			events.Publish(InputEvent.findBindingCollisions, [_player, _verbIndex, _array]);
			return _array;
		}
		
		/** Resets all Gamepad and Kbm bindings for all verbs of the specified component
		 * @arg {Real} _playerIndex The index of the player to reset verbs for.
		 * @return {Undefined} */
		static PlayerResetBindings = function(_playerIndex) {
			var _player = GetPlayer(_playerIndex);
			var _gamepad, _kbm;
			var i = 0; repeat(verbCount) {
				_gamepad = VerbGetDefaultBindings(i, true);
				_kbm = VerbGetDefaultBindings(i, false);
				var _verb = _player.GetVerb(i++);
				_verb.BindingsSetGamepad(_gamepad);
				_verb.BindingsSetKbm(i, _kbm);
			}
		}
		
		/** Swaps the system's index value which consequently swaps all data that references them by index.
		 * @arg {Real} _playerA The index of a player being swapped
		 * @arg {Real} _playerB The index of the other player being swapped.
		 * @return {Undefined} */
		static PlayerSwap = function(_playerA, _playerB) {
			var _ogA = players[_playerA];
			var _ogB = players[_playerB];
			players[_playerA] = _ogB;
			players[_playerB] = _ogA;
			//TODO: Devices would also need to swap because they don't use player index
		}
		
		/** Returns `true` if the specified player and their device is connected to the system.
		 * @arg {Real} _playerIndex The player to check
		 * @return {Bool} */
		static PlayerIsConnected = function(_playerIndex) {
			return GetPlayer(_playerIndex).IsConnected();
		}
		
		/** Returns the `InputSystemComponent` associated with the specified player index.
		 * @arg {Real} _playerIndex The player whose component is being requested
		 * @return {Struct.InputSystemComponent} */
		static RequestSystemComponent = function(_playerIndex) {
			var _component = ArrayTryGetElement(components, _playerIndex);
			if (is_undefined(_component)) {
				_component = new InputSystemComponent(_playerIndex);
				components[_playerIndex] = _component;
			}
			return _component;
		}
	#endregion
	
	
	#region Verbs and Clusters. 
		//Verbs are used to check devices and return what inputs are being pressed.
		//Clusters are groups of verbs that check a group of buttons.
		
		///@ignore
		dictionary = new InputDictionary();									//Contains arrays of the default verb and cluster definitions.
		
		///@ignore
		verbDefinitions = dictionary.verbs;									//Array of default verb definitions 
		///@ignore
		verbCount = array_length(verbDefinitions);							//Number of available verbs
		
		///@ignore
		clusterDefinitions = dictionary.clusters;							//Array of default cluster definitions
		///@ignore
		clusterCount = array_length(clusterDefinitions);					//Number of available clusters
		
		
		/** Checks a verb index to see if its a valid verb
		 * @arg {Enum.Input_Verb} _verb
		 * @return {Bool} */
		static ValidateVerbIndex = function(_verb) {
			if (!INPUT_SAFETY_CHECKS) {
				return true;
			}
			return (MathIsBetweenEquals(_verb, 0, verbCount));
		}
		
		/** Checks a cluster index to see if its a valid cluster
		 * @arg {Enum.Input_Cluster} _cluster
		 * @return {Bool} */		
		static ValidateClusterIndex = function(_cluster) {
			if (!INPUT_SAFETY_CHECKS) {
				return true;
			}
			return (MathIsBetweenEquals(_cluster, 0, clusterCount));
		}
		
		/** Throws an exception for an invalid verb
		 * @arg {String} _funcName Name of the function where the problem originated
		 * @arg {Enum.Input_Verb} _verb Invalid Input Verb index
		 * @arg {Struct} [_scope] The original function scope if different from the `InputSystem`
		 * @return {Undefined} */
		static ThrowInvalidVerb = function(_funcName, _verb, _scope = undefined) {
			_scope ??= self;
			ThrowInputError(_funcName, $"Invalid Input: Verb index {_verb} does not exist.", _scope);
		}
		
		/** Throws an exception for an invalid cluster
		 * @arg {String} _funcName Name of the function where the problem originated
		 * @arg {Enum.Input_Verb} _cluster Invalid Input Cluster index
		 * @arg {Struct} [_scope] The original function scope if different from the `InputSystem`		 
		 * @return {Undefined} */
		static ThrowInvalidCluster = function(_funcName, _cluster, _scope = undefined) {
			_scope ??= self;
			ThrowInputError(_funcName, $"Invalid Input: Cluster index {_cluster} does not exist.", _scope);
		}				
		
		/** Returns the number of cluster definitions
		 * @return {Real} */
		static ClusterGetCount = function() {
			return clusterCount;
		}		
		
		/** Returns the number of verb definitions
		 * @return {Real} */
		static VerbGetCount = function() {
			return verbCount;
		}
		
		/** Returns the name of a verb
		 * @arg {Enum.Input_Verb} _verb The verb to get the name for
		 * @return {String} */
		static VerbGetName = function(_verb) {
			return verbDefinitions[_verb].GetName();
		}
		
		/** Consumes all verbs for the specified player
		 * @arg {Real} _playerIndex The index of the player who should consume verbs
		 * @return {Undefined} */
		static VerbConsumeAll = function(_playerIndex) {
			GetPlayer(_playerIndex).VerbConsumeAll();
		}
		
		/** Returns a copy of the kbm or gamepad button bindings for the specified verb
		 * @arg {Enum.Input_Verb} _verb The verb to get default bindings for
		 * @arg {Bool} [_forGamepad] Set true to get the gamepad bindings. Otherwise, the method returns the kbm bindings.
		 * @return {Array<Constant.KbmButton>|Array<Constant.GamepadButton>} */
		static VerbGetDefaultBindings = function(_verb, _forGamepad) {
			var _verbDef = verbDefinitions[_verb];
			var _bindings = (_forGamepad) ? _verbDef.BindingsGetGamepad() : _verbDef.BindingsGetKbm();
			return variable_clone(_bindings);
		}
		
		/** Returns an array of all default verb definitions. These are not copies!
		 * @return {Array<StructInputVerb>} */
		static VerbGetAll = function() {
			return verbDefinitions;
		}
		
		/** Writes all of a player's verb definitions into the specified buffer. The data that is written from each verb is:
		 * - `buffer_bool`  Whether the verb was held in the previous frame
		 * - `buffer_f32`   Raw input value
		 * - `buffer_f32`   Clamp input value
		 * - `buffer_s32`   Number of frames since the verb was pressed
		 * @arg {Id.Buffer} _buffer The buffer to write to
		 * @arg {Real} _playerIndex The index of the player whose verbs should be written
		 * @return {Undefined} */
		static VerbWriteBuffer = function(_buffer, _playerIndex) {
			buffer_write(_buffer, buffer_string, __INPUT_VERB_STATE_HEADER);
    		buffer_write(_buffer, buffer_u16, verbCount);
			
			//Write the player's verbs
			var _player = GetPlayer(_playerIndex);
			var i = 0; repeat(verbCount) {
				var _verb = _player.GetVerb(i++);
				buffer_write(_buffer, buffer_bool, _verb.IsPreviouslyHeld());
				buffer_write(_buffer, buffer_f32, _verb.GetValueRaw());
				buffer_write(_buffer, buffer_f32, _verb.GetValue());
				buffer_write(_buffer, buffer_f32, frame - _verb.GetPressFrame());
			}
			
			buffer_write(_buffer, buffer_string, INPUT_VERB_FOOTER);
		}
		
		/** Reads the buffered verb values as created with `VerbWriteBuffer()`
		 * @arg {Id.Buffer} _buffer The buffer to write to
		 * @arg {Real} _playerIndex The index of the player to set verbs for
		 * @return {Undefined} */
		static VerbReadBuffer = function(_buffer, _playerIndex) {
			var _header = buffer_read(_buffer, buffer_string);
			if (_header != INPUT_VERB_HEADER) {
				ThrowInputError("VerbReadBuffer", $"Header mismatch. Expecting {INPUT_VERB_HEADER}, got {_header}");
			}
			
			var _verbCount = buffer_read(_buffer, buffer_u16);
			if (_verbCount != verbCount) {
				ThrowInputError("VerbReadBuffer", $"Verb count mismatch. Expecting {verbCount}, got {_verbCount}");
			} 
			
			//Read the verb data and set for the player
			var _player = GetPlayer(_playerIndex);
			var i = 0; repeat(verbCount) {
				var _verb = _player.GetVerb(i++);
				_verb.SetPreviouslyHeld(buffer_read(_buffer, buffer_bool));
				_verb.SetValueRaw(buffer_read(_buffer, buffer_f32));
				_verb.SetValue(buffer_read(_buffer, buffer_f32));
				_verb.SetPressFrame(buffer_read(_buffer, buffer_s32));
			}
			
			var _footer = buffer_read(_buffer, buffer_string);
			if (_footer != INPUT_VERB_FOOTER) {
				ThrowInputError("VerbReadBuffer", $"Footer mismatch. Expecting {INPUT_VERB_FOOTER}, got {_footer}");
			}
		}		
		
		/** Returns the number of bytes that all verbs will occupy when calling `VerbWriteBuffer()`
		 * @return {Undefined} */
		static VerbByteLengthAll = function() {
			static _len = 2 + string_byte_length(INPUT_VERB_HEADER) + buffer_sizeof(buffer_bool) + power(buffer_sizeof(buffer_f32), 3) + string_byte_length(INPUT_VERB_FOOTER);
			return verbCount * _len;
		}
		
	#endregion
	
	
	#region Events
		
		enum InputEvent {
			collect,
			collectPlayer,														
			update,
			hotswap,
			gamepadDisconnected,
			gamepadConnected,
			playerDeviceChanged,
			playerUpdate,
			playerHotswap,
			focusLost,
			focusGained,
			systemRestart,
			findBindingCollisions
		}
		
		///@ignore Container of all the events available to this InputSystem
		events = new InputSystemEventRegistry();
		
		/** Returns the container of input system events for objects to add functions to.
		 * @return {Struct.InputSystemEventRegistry} */
		static GetEvents = function() {
			return events;
		}
		
		/** Verifies that the specified player can have its input collected. Helper func to make `CollectPlayer()` a bit neater and easier to read. 
		 * @ignore
		 * @arg {Struct.InputPlayer} _player
		 * @return {Bool} */
		static CanCollectPlayer = function(_player) {
			var _bool = true;
			if (!_player.IsConnected()) {
				_bool = false;
			}
			else if (_player.IsBlocked()) {
				_bool = false;
			}
			else if (_player.IsGhost()) {
				_bool = false;
			}
			else if (!GameHasFocus()) {
				_bool = false;
			}
			else if (TimeoutRestart()) {
				_bool = false;
			}
			return _bool;
		}			
		
		
		/** Collects and process the values of input verbs for all players. This is the driving force of the `InputSystem` and should be called in the `Begin-Step` event.
		 * @return {Undefined} */
		static Collect = function() {
			
			//Unstick various key/button combinations to prevent controller lock
			//Unstick KBM controls
			var _len, i;
			if (!INPUT_BAN_KBM && keyboard_check(vk_anykey)) {
				//Unstick on windows
	            if (INPUT_WINDOWS) {
	                if (keyboard_check(vk_alt) && keyboard_check_pressed(vk_space)) {
	                    //Unstick Alt Space
	                    keyboard_key_release(vk_alt);
	                    keyboard_key_release(vk_space);
	                    keyboard_key_release(vk_lalt);
	                    keyboard_key_release(vk_ralt);
	                }
	                
	                if (keyboard_check(0xE6) && !keyboard_check_pressed(0xE6)) {
	                    //Unstick OEM key (Power button on Steam Deck)
	                    keyboard_key_release(0x0E6);
	                }
	            }
				
				//Unstick on web/ios
	            else if (INPUT_WEB && INPUT_APPLE) {
	                if (keyboard_check_released(vk_lmeta) || keyboard_check_released(vk_rmeta)) {
	                    //Meta release causes every key pressed during hold to stick
	                    //This is "the nuclear option", but the problem is severe
	                     i = 8; 
						_len = 0x100 - i;
	                    repeat(_len) {
	                        keyboard_key_release(i++);
	                    }
	                }
	            }
				
				//Unstick on macOS
	            else if (INPUT_MACOS) {
	                //Unstick doubled-up keys
	                if (keyboard_check_released(vk_control)) {
	                    keyboard_key_release(vk_lcontrol);
	                    keyboard_key_release(vk_rcontrol);
	                }
	                if (keyboard_check_released(vk_shift)) {
	                    keyboard_key_release(vk_lshift);
	                    keyboard_key_release(vk_rshift);
	                }
	                if (keyboard_check_released(vk_alt)) {
	                    keyboard_key_release(vk_lalt);
	                    keyboard_key_release(vk_ralt);
	                }
	                
	                //Unstick Meta
	                if (keyboard_check_released(vk_lmeta)) {
	                    keyboard_key_release(vk_rmeta);
	                }
	                else if (keyboard_check_released(vk_rmeta) && keyboard_check(vk_lmeta)) {
	                    keyboard_key_release(vk_lmeta);
	                }
	            }
			}
			
			
			//Handle steamworks
			if (UsingSteamworks()) { 
				steam_input_run_frame();
				
				//Enable Windows IME if the Steam Overlay is open
				if (INPUT_WINDOWS && GameHasFocus()) {
					var _overlayEnabled = steam_is_overlay_activated();
					var _imeEnabled = keyboard_virtual_status();
					
					if (_imeEnabled != _overlayEnabled) {
						if (_overlayEnabled) {
							keyboard_virtual_show(undefined, undefined, undefined, undefined);
						}
						else {
							keyboard_virtual_hide();
						}
					}
				}
				
				//Check steam handles for changes. Forcing disconnect 
				//on gamepads with changes allows them to be reconnected to the correct ports
				if (SteamHandlesChanged()) {
					if (INPUT_LOG_STEAM_DEBUG) {
						LogDebug($"Steam Gamepad Handles Changed to: {steamHandles}");
					}
					if (INPUT_LOG_INFO) {
						LogInfo($"InputSystem: Steam gamepad handles have changed. Disconnecting all gamepads for reconnection.");
					}
					
					_len = array_length(gamepadPorts);
					i = 0; repeat (_len) {
						GamepadDisconnect(gamepadPorts[i++], true);
					}
				}					
			}
			
			
			//Checking that each gamepad connected to the platform is also connected to the `InputSystem`
			if (!INPUT_BAN_GAMEPADS && (current_time > INPUT_GAMEPADS_COLLECT_PREDELAY)) {
				//Check for new gamepad connections or disconnections and handle them accordingly
				GamepadUpdatePorts();
				
				//Update thumbstick values for each gamepad in a port so we don't confuse same direction movement with inactivity.
				_len = array_length(gamepadPorts);
				i = 0; repeat(_len) {
					var _gamepad = GamepadTryGetAt(i++);
					if (!is_undefined(_gamepad)) {
						_gamepad.UpdateThumbstickValues();
					}
				}
			}
			
			
			//Update our rebinding handlers
			i = 0; repeat(array_length(rebindArray)) {
				rebindArray[i++].Handle();
			}
			
			
			//Handle hotswapping. HotSwaps process changing device types (ie; player is using a gamepad, but mouses off screen to close a different app)
			//NB: HotSwaps only work for on default player.
			if (!INPUT_BAN_HOTSWAP) {
				
				//Flag will be true if a hotswap was triggered and is waiting to be processed.
				if (IsHotSwapEnabled()) {
					
					//Check that the player hasn't reported a detected input verb for at least the last 500ms
					var _player = players[0];
					if (_player.IsInactive()) {
						
						//If the player's assigned device also has no activity, then find the one that they are using.
						var _device = _player.GetDevice();
						if (!_device.IsActive()) {
							
							//Find the device that does have activity and assign it to the player, then trigger a hotswap event notice
							var _activeDevice = DeviceFindNewActivity();
							if (!is_undefined(_activeDevice)) {
								_player.SetDevice(_activeDevice);
								events.GetOnHotswap().Broadcast();
							}	
						}
					}
				}
			}
			
			
			//Collect verb input values from all `InputSystemComponents`
			_len = array_length(players);
			for (var i = 0; i < _len; i++) {
				CollectPlayer(players[i]);
			}
			
			//Send Notice that the primary collect event is finished. This event is a good place for objects to perform cleanup if necessary.
			events.GetOnCollect().Broadcast();
			
			
			//Update after collect if not using manual update/collect methods
			if (INPUT_UPDATE_AFTER_COLLECT) {
				Update();
			}
		}		
		
		
		/** Collects the values of all input verbs defined by the specified player.
		 * @arg {Struct.InputPlayer} _player The player to collect input for.
		 * @return {Undefined} */
		static CollectPlayer = function(_player) {
			//Update connection status 
			_player.UpdateConnectionStatus();
			
			//Early exit if collection is not possible right now
			if (!CanCollectPlayer(_player) || DeviceGetRebinding(_player.GetDevice())) {
				_player.VerbResetValueAll();
				return;
			}
			
			var _device = _player.GetDevice();
			var _rawValues = _player.GetRawInputCache();
			var _clampValues = _player.GetClampedInputCache();
			var _onKbm = _player.UsesKbm();
			var _newHeld = false;
			
			//In case of touch devices, update virtual button touch positions before recording input
			if (_player.UsesTouch() || (INPUT_MOUSE_CAN_USE_VIRTUAL_BUTTONS && _onKbm)) {
				//Detect new touch points and find the top-most button to handle it so they can be properly processed during verb collection
				var i = 0; repeat(INPUT_MAX_TOUCHPOINTS) {
					if (device_mouse_check_button_pressed(i, mb_left)) {
						var _len = array_length(virtualButtons);
						var j = 0; repeat (_len) {
							if (virtualButtons[j++].TouchpointCapture(i)) {
								break;
							}
						}
					}
					i++;
				}
				
				//Reset verb values, then collect and fill them.
				_player.VerbResetValueAll();
				var i = 0; repeat(array_length(virtualButtons)) {
					virtualButtons[i++].Collect(_rawValues, _clampValues);
				}
			}
			
			if (_onKbm) {
				var i = 0; repeat(verbCount) {
					
					//Get the verb and its button bindings
					var _verb = _player.GetVerb(i);
					var _bindings = _verb.BindingsGetKbm();
					
					//Setup initial values
					var _value = 0;
					
					//Check each button to see if its pressed
					var j = 0; repeat(array_length(_bindings)) {
						var _button = _bindings[j++];
						_newHeld = _device.CheckButton(_button);
						break;
					}
					
					var _finalValue = (_newHeld) ? 1 : 0;
					_rawValues[i] = _finalValue
					_clampValues[i] = _finalValue;
					i++;
				}
			}			
			
			else if (_player.UsesGamepad()) {
				var i = 0; repeat(verbCount) {
					//Thresholds
					var _minLeft = _player.GetMinimumStickThreshold(Input_ClusterThresholdType.left);
					var _maxLeft = _player.GetMaximumStickThreshold(Input_ClusterThresholdType.left);
					var _minRight = _player.GetMinimumStickThreshold(Input_ClusterThresholdType.right);
					var _maxRight = _player.GetMaximumStickThreshold(Input_ClusterThresholdType.right);
					
					//Get the verb and its button bindings
					var _verb = _player.GetVerb(i);
					var _bindings = _verb.BindingsGetKbm();
					
					//Setup initial values
					var _valueRaw = 0;
					var _valueClamp = 0;
					
					//Check each button to see if its pressed
					var j = 0; repeat(array_length(_bindings)) {
						var _button = _bindings[j++];
						var _value = _device.CheckButton(_button);
						
						if (_value > _valueRaw) {
							_valueRaw = _value;
							_button = abs(_button);
							if ((_button == gp_shoulderlb) || (_button == gp_shoulderrb)) {
								_valueClamp = MathLinear(_value, INPUT_GAMEPAD_TRIGGER_MIN_THRESHOLD, INPUT_GAMEPAD_TRIGGER_MIN_THRESHOLD);
							}
							else if ((_button == gp_axislh) || (_button == gp_axislv)) {
								_valueClamp = MathLinear(_value, _minLeft, _maxLeft);
							}
							else if ((_button == gp_axisrh) || (_button == gp_axisrv)) {
								_valueClamp = MathLinear(_value, _minRight, _maxRight);
							}
							else {
								_valueClamp = (_value > 0);
							}
						}
					}
					
					_rawValues[i] = _valueRaw;
					_clampValues[i] = _valueClamp;
					i++;
				}				
			}
			
			//Trigger player verbs collected event.
			var _collectPlayer = events.GetOnCollectPlayer();
			_collectPlayer.Broadcast(_player);
		}
		
		/** The system receives a notice that the game is ending. This function should be called in the `Game End` GMO event.
		 * @return {Undefined} */
		static OnGameEnd = function() {
			//Set the restart timestamp
			restartTime = time;
			
			//Consume all component verbs.
			var _len = array_length(players);
			for (var i = 0; i < _len; i++) {
				players[i].VerbConsumeAll();
			}
			
			//Notify subsystems of primary system restart.
			events.GetOnSystemRestart().Broadcast();
		}
		
		/** Updates the system and player states to prepare for the next Collect call. This is called automatically by `Collect()` if using automatic system management.
		 * @return {Undefined} */
		static Update = function() {
			//Updating internal time trackers and flags
			time += delta_time/1000;
			frame++;
			PointerSetBlockedThisFrame(false);
			
			//Desktop apps are not cached when losing focus unlike consoles/web
			if (INPUT_DESKTOP && !INPUT_WEB) {
				
				//Handle the game losing focus.
				if (os_is_paused()) {
					SetGameFocus(false);
					PointerSetBlockedByWindowDefocus(true);
					
					//On linux, the app continues to recieve some input for a few frames after focus loss
					//so have to clear IO to prevent false positive on focus regained check in the next update.
					if (INPUT_LINUX) {
						var _keyboardString = keyboard_string;
						io_clear();
						keyboard_string = _keyboardString;
					}
					
					//Enable the Windows IME
					if (INPUT_WINDOWS) {
						keyboard_virtual_show(undefined, undefined, undefined, undefined);
					}
					
					//Publish focus lost event to update internal input objects
					events.GetOnFocusLost().Broadcast();
				}
				
				//Handle the game regaining focus
				else {
					if (GameHasFocus()) {
						if (PointerIsBlockedByWindowDefocus()) {
							//Sustain the mouse block while a button is held
							PointerSetBlockedByWindowDefocus(false);//Temp turn it off
							PointerSetBlockedByWindowDefocus(kbm.GetMouseOutput() != undefined);
						}
					}
					
					//Check if game has regained focus
					else if (CheckFocusRegained()) {
						SetGameFocus(true);
						PointerSetBlockedByWindowDefocus(false);
						PointerSetBlockedThisFrame(false);
						
						//Disable Windows IME
						if (INPUT_WINDOWS) {
							keyboard_virtual_hide();
						}
						
						//Publish focus gained event to update internal input objects
						events.GetOnFocusGained().Broadcast();
					}
				}	
			}
			
			
			//Next track mouse movement and fix windows touchpad and touchscreen problems
			if (!INPUT_BLOCK_MOUSE_CHECKS) {
				pointer.UpdatePosition();
				if (PointerIsBlockedByUser() || (PointerIsBlockedByWindowDefocus() && !INPUT_MACOS) || (!INPUT_BAN_KBM && DeviceGetRebinding(kbm))) {
					PointerSetBlocked(true);
				}
				else {
					PointerSetBlocked(false);
					pointer.UpdateRoomPosition();
					pointer.UpdateGUIPosition();
				}
				
				pointer.UpdatePosition();
				systemFlags.SetBitState(Input_SystemFlags.pointerMoved, pointer.GetMoved());
				
				if (INPUT_WINDOWS) {
					tapPresses += kbm.CheckExtendedMouseButton(mb_left);
					tapReleases += kbm.CheckExtendedMouseButtonReleased(mb_left);
					
					if (tapReleases >= tapPresses) {
						//Resolve press/release desync where press fails to register on same frame as release
						systemFlags.SetBitState(Input_SystemFlags.tapClick, (tapPresses > tapReleases));
						tapPresses = 0;
						tapReleases = 0;
					}
					else {
						systemFlags.SetBitState(Input_SystemFlags.tapClick, false);
					}
				}
			}
			
			//Manage virtual buttons
			if (IsVirtualOrderDirty()) {
				SetVirtualOrderDirty(false);
				
				//Clean up destroyed buttons
				var _len = array_length(virtualButtons) - 1;
				for (var i = _len; i >= 0; i--) {
					var _button = virtualButtons[i];
					if (_button.IsDestroyed()) {
						array_delete(virtualButtons, i, 1);
					}
				}
				
				array_sort(virtualButtons, SortVirtualButtons);
			}
			
			
			//Update players
			lowestConnectedPlayerIndex = undefined;
			var i = 0; repeat (INPUT_MAX_PLAYERS) {
				var _player = players[i];
				UpdatePlayer(_player);
				
				if (lowestConnectedPlayerIndex == undefined) {
					if (_player.IsConnected()) {
						lowestConnectedPlayerIndex = i;
					}
				}
				i++;
			}
			events.GetOnUpdate().Broadcast();
		}
		
		/** Initiates a player update call
		 * @arg {Struct.InputPlayer} _player The player to update
		 * @return {Undefined} */
		static UpdatePlayer = function(_player) {
			var _anyVerbHeld = false;
			var _rawValues = _player.GetRawInputCache();
			var _clampValues = _player.GetClampedInputCache();
			
			//Writing cached input to the player's verbs
			var i = 0; repeat(verbCount) {
				var _verb = _player.GetVerb(i);
				var _index = _verb.GetIndex();
				var _clamp = _clampValues[_index];
				var _raw = _rawValues[_index];
				var _prevHeld = _verb.IsHeld();
				
				_verb.SetPreviouslyHeld(_prevHeld);
				_verb.SetValueRaw(_raw);
				_verb.SetValue(_clamp);
				
				if (_clamp > 0) {
					_anyVerbHeld = true;
					_verb.SetHeld(true);
					if (!_prevHeld) {
						_verb.SetPressFrame(frame);
					}
				}
				else {
					_verb.SetHeld(false);
				}
				
				i++;
			}
			_player.SetAnyInput(_anyVerbHeld);
			_player.Update();
			
			var _playerUpdate = events.GetOnPlayerUpdate();
			_playerUpdate.Broadcast(_player);
		}
		
		/** Register a callback to the specified input system event
		 * @deprecated
		 * @ignore
		 * @arg {Enum.InputEvent} _eventKey The event to follow.
		 * @arg {Struct|Id.Instance} _context The instance/struct registering with the event.
		 * @arg {Function} _function The callback function to register to the event.
		 * @return {Undefined} */
		static EventRegister = function(_eventKey, _context, _function) {
			events.Subscribe(_eventKey, _context, _function);
		}
	#endregion	
	
	
	//Main
	//Initialize all subsystems
	Initialize();
}