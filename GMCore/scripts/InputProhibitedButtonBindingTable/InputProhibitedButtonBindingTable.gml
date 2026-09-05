//feather ignore all

/** InputProhibitedButtonBindingTable: This is a singleton data table used only by `InputDeviceKbm`. It contains all input button constants that Kbm devices are not allowed to detect. The singleton is instantiated once when a device is first created and should never be instatiated manually. You can, however, modify this struct in the IDE if you have bindings you do want/need to be able to detect or not detect.
 * @return {Struct.InputProhibitedButtonBindingTable} */
function InputProhibitedButtonBindingTable() constructor {
	//Custom buttons that should never be detected. You may add or remove keycodes here and InputDevices will handle the rest on their own.
	self[$ vk_alt] = true;
	self[$ vk_ralt] = true;
	self[$ vk_lalt] = true;
	
	
	#region DO NOT MODIFY
		//A majority of these buttons shouldn't be modified and should always be prohibited. 
		self[$ 0xFF] = true;							//Vendor key
		self[$ vk_lmeta] = true;						//Left windows/command key
		self[$ vk_rmeta] = true;						//Right windows/command key
		self[$ vk_numlock] = true;						//number lock
		self[$ vk_scrollock] = true;					//scroll lock
		
		if (INPUT_WINDOWS) {
			self[$ 0xE6] = true;						//OEM Key (steam deck power button)
		}
		
		if (INPUT_ANDROID) {
			self[$ 0x7C] = true;						//Screenshot
		}
		
		if (INPUT_WEB) {
			if (INPUT_APPLE) {
				self[$ vk_f10] = true;					//Apple Fullscreen
				self[$ vk_capslock] = true;				//Apple capslock
			}
			else {
				self[$ vk_f11] = true;					//Regular fullscreen
			}
		}
		
		if (INPUT_WEB || INPUT_WINDOWS) {
			//Complex character conversion
            self[$ 0x15] = true; 						//IME Kana/Hanguel
            self[$ 0x16] = true; 						//IME On
            self[$ 0x17] = true; 						//IME Junja
            self[$ 0x18] = true; 						//IME Final
            self[$ 0x19] = true; 						//IME Kanji/Hanja
            self[$ 0x1A] = true; 						//IME Off
            self[$ 0x1C] = true; 						//IME Convert
            self[$ 0x1D] = true; 						//IME Nonconvert
            self[$ 0x1E] = true;						//IME Accept
            self[$ 0x1F] = true; 						//IME Mode Change
            self[$ 0xE5] = true; 						//IME Process
            
			//Common Browser navigation
            self[$ 0xA6] = true; 						//Browser Back
            self[$ 0xA7] = true; 						//Browser Forward
            self[$ 0xA8] = true; 						//Browser Refresh
            self[$ 0xA9] = true; 						//Browser Stop
            self[$ 0xAA] = true; 						//Browser Search
            self[$ 0xAB] = true; 						//Browser Favorites
            self[$ 0xAC] = true; 						//Browser Start/Home
            
			//Common audio navigation
            self[$ 0xAD] = true; 						//Volume Mute
            self[$ 0xAE] = true; 						//Volume Down
            self[$ 0xAF] = true; 						//Volume Up
            self[$ 0xB0] = true; 						//Next Track
            self[$ 0xB1] = true; 						//Previous Track
            self[$ 0xB2] = true; 						//Stop Media
            self[$ 0xB3] = true; 						//Play/Pause Media
            
			//Common media/application
            self[$ 0xB4] = true; 						//Launch Mail
            self[$ 0xB5] = true; 						//Launch Media
            self[$ 0xB6] = true; 						//Launch App 1
            self[$ 0xB7] = true; 						//Launch App 2
            
			//Other
            self[$ 0xFB] = true; 						//Zoom			
		}
	#endregion
}