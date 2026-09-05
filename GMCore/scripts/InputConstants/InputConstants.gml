//feather ignore all
 
//Runtime on web, constant on native as of 2024.2
//Tested and confirmed in VM bytecode disassembly
#macro INPUT_WINDOWS  		(os_type == os_windows)
#macro INPUT_MACOS    		(os_type == os_macosx)
#macro INPUT_LINUX    		(os_type == os_linux)
#macro INPUT_IOS      		(os_type == os_ios || os_type == os_tvos)
#macro INPUT_ANDROID  		(os_type == os_android)
#macro INPUT_XBOX     		(os_type == os_xboxseriesxs)
#macro INPUT_PS4      		(os_type == os_ps4)
#macro INPUT_PS5      		(os_type == os_ps5)
#macro INPUT_PLAYSTATION 	(INPUT_PS4 || INPUT_PS5)
#macro INPUT_SWITCH  		(os_type == os_switch)
#macro INPUT_CONSOLE  		(INPUT_XBOX || INPUT_PS4 || INPUT_PS5 || INPUT_SWITCH)
#macro INPUT_APPLE    		(INPUT_MACOS || INPUT_IOS)
#macro INPUT_OPERAGX  		(os_type == os_operagx)
#macro INPUT_OPERAGXMOBILE 	(PlatformOnOperaGXMobile())
#macro INPUT_WEB      		((os_browser != browser_not_a_browser) || INPUT_OPERAGX)
#macro INPUT_DESKTOP  		(INPUT_WINDOWS || INPUT_MACOS || INPUT_LINUX || (INPUT_OPERAGX && !INPUT_OPERAGXMOBILE))
#macro INPUT_MOBILE   		(INPUT_ANDROID || INPUT_IOS || (INPUT_OPERAGX && INPUT_OPERAGXMOBILE))
#macro INPUT_IDE			(GM_build_type == "run")

/** Returns `true` if the game is being run on OperaGX Mobile
 * @ignore
 * @return {Bool} */
function PlatformOnOperaGXMobile() {
	if (os_type != os_operagx) {
		return false;
	}
	
	//If we're using operagx, figure out if we're on mobile.
	var _map = os_get_info();
	var _onMobile = _map[? "mobile"];
	ds_map_destroy(_map);
	
	return _onMobile;
}