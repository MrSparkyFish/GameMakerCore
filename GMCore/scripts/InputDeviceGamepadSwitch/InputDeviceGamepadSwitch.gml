//feather ignore all

/** InputDeviceGamepadSwitch: Used to represent a switch ProController, single Joy-con's, and Joy-con pairs.
 * @arg {Real} _gamepadIndex The index number to set for this gamepad
 * @arg {Real} [_description] Optionally set a custom description for the gamepad. Not recommended to set manually as some gamepads use their description as an encryption.
 * @arg {Struct.InputGamepadGUID} [_guid] The GUID gamepad product information. Automatically retrieved if left blank or set to `undefined`
 * @return {Struct.InputDeviceGamepadSwitch} */
function InputDeviceGamepadSwitch(_port, _description, _guid) : InputDeviceGamepad(_port, _description, _guid) constructor {
	
	
	#region Internal
		
		//Swich gamepad representation doesn't specify specific controller type (joycon-left, joycon-right, joycon-pair, pro-controller)
		//So we have to check GUID for unique situations and set the type accordingly using `IdentifySwitchType`. Additionally, depending
		//on specific types, the button map layout may be slightly different and needs to be adjusted to account for things like
		//zr/zl being in different spots on joycon-pair vs joycon-single vs joycon-single-horizontal.
		var _constants;
		///@ignore
		gpType = IdentifySwitchType();
		
		
		//Easier to just set full custom mappings for the problem buttons and then figure out which buttons need to go where.
		_constants = [gp_start, gp_stickl, gp_axislh, gp_axislv, gp_face1, gp_face2, gp_face3, gp_face4]; //Button mappings we want to keep
		ButtonNullifyAllMappings();	//Makes the button map go blank.
		ButtonResetMapGroup(_constants); //Restore the buttons we didn't want changed
		
		
		
		//Flip our A/B buttons if desired
		if (INPUT_NINTENDO_GAMEPADS_SWAP_AB) {
			ButtonSetMap(gp_face1, function(_index) {
				return gamepad_button_value(_index, gp_face2);
			});
			ButtonSetMap(gp_face2, function(_index) {
				return gamepad_button_value(_index, gp_face1);
			});	
		}
		//Flip our X/Y buttons if desired
		if (INPUT_NINTENDO_GAMEPADS_SWAP_XY) {
			ButtonSetMap(gp_face3, function(_index) {
				return gamepad_button_value(_index, gp_face4);
			});
			ButtonSetMap(gp_face4, function(_index) {
				return gamepad_button_value(_index, gp_face3);
			});				
		}
		
		
		//Pro-controllers, handheld mode, dual-joycons
		if (gpType == Input_GamepadType.nintendoSwitch) {
			
			_constants = [
				gp_stickr, gp_axisrh, gp_axisrv,							//On switch the right stick is only available when using handheld, pro-controller, or dual joycons
				gp_padu, gp_padd, gp_padl, gp_padr,							//Only Allow d-pad when using one of these controller types
				gp_shoulderl, gp_shoulderr, gp_shoulderlb, gp_shoulderrb,	//Switch triggers are always digital so treat them as buttons too
				gp_select													//Select is only available with generic switch controller type
			]; 
			ButtonResetMapGroup(_constants);
		}
		
		//Check other controller types for switch
		else {
			
			//Horizontal single joycon
			if (INPUT_SWITCH_JOYCON_HORIZONTAL_HOLDTYPE) {
				
				//Single Joy-Cons in horizontal report L/R/ZL/ZR as shoulder buttons even though they rest in the player's palm. No idea why, but we disallow that
				//Also it seems like GameMaker implements SL and SR weirdly so we circumvent that
				
				//left joy-con						
				if (gpType == Input_GamepadType.joyconLeft) {
					ButtonSetMap(gp_shoulderl, function(_deviceIndex) {
						return gamepad_button_value(_deviceIndex, 16);//leftSL index
					});
					ButtonSetMap(gp_shoulderr, function(_deviceIndex) {
						return gamepad_button_value(_deviceIndex, 17);//rightSL index
					});
				}
				
				//left joy-con	
				else {
					ButtonSetMap(gp_shoulderl, function(_deviceIndex) {
						return gamepad_button_value(_deviceIndex, 18);//leftSL index
					});
					ButtonSetMap(gp_shoulderr, function(_deviceIndex) {
						return gamepad_button_value(_deviceIndex, 19);//rightSL index
					});
				}
			}
			
			//Vertical single joycon
			else {
				
				if (gpType == Input_GamepadType.joyconLeft) {
					ButtonSetMap(gp_shoulderl, function(_deviceIndex) {
						return gamepad_button_value(_deviceIndex, 6);//leftSL index
					});
					ButtonSetMap(gp_shoulderr, function(_deviceIndex) {
						return gamepad_button_value(_deviceIndex, 8);//rightSL index
					});							
				}
				
				//right joycon
				else {
					ButtonSetMap(gp_shoulderl, function(_deviceIndex) {
						return gamepad_button_value(_deviceIndex, 7);//leftSL index
					});
					ButtonSetMap(gp_shoulderr, function(_deviceIndex) {
						return gamepad_button_value(_deviceIndex, 9);//rightSL index
					});						
				}
				
			}
			
		} 
		
		//Finally, modify to fit steam expectations.
		SteamTransform();
		SteamTransformQuirks();			
		
		
		
		/** Helps identify the specific switch controller type being used.
		 * @ignore
		 * @return {Real} */		
		static IdentifySwitchType = function() {
			//Quick check left only
			var _desc = string_lower(description);
			if (StringMatchesAny(_desc, ["joy-con (l)", "left joy-con"])) {
				return Input_GamepadType.joyconLeft;
			}
			//Quick check right only
			else if (StringMatchesAny(_desc, ["joy-con (r)", "right joy-con"])) {
				return Input_GamepadType.joyconRight;
			}
			//In depth check (slower)
			else if (StringContains(_desc, "joy-con")) {
				//Detectect left/right joycon identifier
				var _left = switch_controller_joycon_left_connected(index);
				var _right = switch_controller_joycon_right_connected(index);
				if (_left) {
					if (_right) {
						//Both joycons are being used in dual mode
						return Input_GamepadType.nintendoSwitch;
					}
					//Just the left is connected
					return Input_GamepadType.joyconLeft;
				}
				
				if (_right) {
					if (_left) {
						//Both joycons are being used in dual mode
						return Input_GamepadType.nintendoSwitch;
					}
					//Just the right is connected
					return Input_GamepadType.joyconRight;
				}
				
			}
			
			else {
				if (INPUT_LOG_WARNING) {
					LogWarning($"InputGamepad::IdentifySwitchType -> Invalid Left/Right Joy-Con state detected. Using default Switch gamepad type.");
				}
				
				return Input_GamepadType.nintendoSwitch;			
			}
		}
	#endregion
	
	
}