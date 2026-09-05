/** KbmBindingNameLookupTable: Contains a list of all keyboard and mouse button names mapped to their input values
 * @return {Struct.KbmBindingNameLookupTable}*/
function KbmBindingNameLookupTable() constructor {
	self[$ mb_left] = "mouse button left";
    self[$ mb_middle] = "mouse button middle";
    self[$ mb_right] = "mouse button right";
    self[$ mb_side1] = "mouse button forward";
    self[$ mb_side2] = "mouse button back";
    self[$ mb_wheel_up] = "mouse wheel up";
    self[$ mb_wheel_down] = "mouse wheel down";
    
    self[$ vk_backtick] = "`";
    self[$ vk_hyphen] = "-";
    self[$ vk_equals] = "=";
    self[$ vk_semicolon] = ";";
    self[$ vk_apostrophe] = "'";
    self[$ vk_comma] = "]";
    self[$ vk_period] = ".";
    self[$ vk_rbracket] = "]";
    self[$ vk_lbracket] = "[";
    self[$ vk_fslash] = "/";
    self[$ vk_bslash] = "\\";

    self[$ vk_scrollock] = "scroll lock";
    self[$ vk_capslock] = "caps lock";
    self[$ vk_numlock] = "num lock";
    self[$ vk_lmeta] = "left meta";
    self[$ vk_rmeta] = "right meta";
    self[$ vk_clear] = "clear";
    self[$ vk_menu] = "menu";
	
    self[$ vk_printscreen] = "print screen";
    self[$ vk_pause] = "pause break";
    
    self[$ vk_escape] = "escape";
    self[$ vk_backspace] = "backspace";
    self[$ vk_space] = "space";
    self[$ vk_enter] = "enter";
    
    self[$ vk_up] = "arrow up";
    self[$ vk_down] = "arrow down";
    self[$ vk_left] = "arrow left";
    self[$ vk_right] = "arrow right";
    
    self[$ vk_tab] = "tab";
    self[$ vk_ralt] = "right alt";
    self[$ vk_lalt] = "left alt";
    self[$ vk_alt] = "alt";
    self[$ vk_rshift] = "right shift";
    self[$ vk_lshift] = "left shift";
    self[$ vk_shift] = "shift";
    self[$ vk_rcontrol] = "right ctrl";
    self[$ vk_lcontrol] = "left ctrl";
    self[$ vk_control] = "ctrl";
	
    self[$ vk_f1] = "f1";
    self[$ vk_f2] = "f2";
    self[$ vk_f3] = "f3";
    self[$ vk_f4] = "f4";
    self[$ vk_f5] = "f5";
    self[$ vk_f6] = "f6";
    self[$ vk_f7] = "f7";
    self[$ vk_f8] = "f8";
    self[$ vk_f9] = "f9";
    self[$ vk_f10] = "f10";
    self[$ vk_f11] = "f11";
    self[$ vk_f12] = "f12";
	
    self[$ vk_divide] = "numpad /";
    self[$ vk_multiply] = "numpad *";
    self[$ vk_subtract] = "numpad -";
    self[$ vk_add] = "numpad +";
    self[$ vk_decimal] = "numpad .";
	
    self[$ vk_numpad0] = "numpad 0";
    self[$ vk_numpad1] = "numpad 1";
    self[$ vk_numpad2] = "numpad 2";
    self[$ vk_numpad3] = "numpad 3";
    self[$ vk_numpad4] = "numpad 4";
    self[$ vk_numpad5] = "numpad 5";
    self[$ vk_numpad6] = "numpad 6";
    self[$ vk_numpad7] = "numpad 7";
    self[$ vk_numpad8] = "numpad 8";
    self[$ vk_numpad9] = "numpad 9";
	
	self[$ vk_0] = "0";
	self[$ vk_1] = "1";
	self[$ vk_2] = "2";
	self[$ vk_3] = "3";
	self[$ vk_4] = "4";
	self[$ vk_5] = "5";
	self[$ vk_6] = "6";
	self[$ vk_7] = "7";
	self[$ vk_8] = "8";
	self[$ vk_9] = "9";
	
	self[$ vk_a] = "A";
	self[$ vk_b] = "B";
	self[$ vk_c] = "C";
	self[$ vk_d] = "D";
	self[$ vk_e] = "E";
	self[$ vk_f] = "F";
	self[$ vk_g] = "G";
	self[$ vk_h] = "H";
	self[$ vk_i] = "I";
	self[$ vk_j] = "J";
	self[$ vk_k] = "K";
	self[$ vk_l] = "L";
	self[$ vk_m] = "M";
	self[$ vk_n] = "N";
	self[$ vk_o] = "O";
	self[$ vk_p] = "P";
	self[$ vk_q] = "Q";
	self[$ vk_r] = "R";
	self[$ vk_s] = "S";
	self[$ vk_t] = "T";
	self[$ vk_u] = "U";
	self[$ vk_v] = "V";
	self[$ vk_w] = "W";
	self[$ vk_x] = "X";
	self[$ vk_y] = "Y";
	self[$ vk_z] = "Z";	
	
    self[$ vk_delete] = "delete";
    self[$ vk_insert] = "insert";
    self[$ vk_home] = "home";
    self[$ vk_pageup] = "page up";
    self[$ vk_pagedown] = "page down";
    self[$ vk_end] = "end";
	
    //Name newline character after Enter
    self[$ 10] = self[$ vk_enter];
    
    //Reset F11 and F12 keycodes on linux/macOS platforms
    if (INPUT_LINUX || INPUT_MACOS) {
        self[$ 128] = "f11";
        self[$ 129] = "f12";
    }
	  
    //F13 to F32 on Windows and Web
    if (INPUT_WINDOWS || INPUT_WEB) {
        for(var _i = (vk_f1 + 12); _i < (vk_f1 + 32); _i++) {
			self[$ _i] = "f" + string(_i);
		}
    }
	
	
}