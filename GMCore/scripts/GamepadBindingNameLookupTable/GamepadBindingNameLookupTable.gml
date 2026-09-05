/** GamepadBindingNameLookupTable: Contains a complete list of gamepad button names mapped to their input values
* @return {Struct.GamepadBindingNameLookupTable} */
function GamepadBindingNameLookupTable() constructor {
	self[$ -gp_axislh] = "thumbstick l left";
	self[$ gp_axislh] = "thumbstick l right";
	self[$ -gp_axislv] = "thumbstick l up";
	self[$ gp_axislv] = "thumbstick l down";
	self[$ gp_stickl] = "thumbstick l click";
	
	self[$ -gp_axisrh] = "thumbstick r left";
	self[$ gp_axisrh] = "thumbstick r right";
	self[$ -gp_axisrv] = "thumbstick r up";
	self[$ gp_axisrv] = "thumbstick r down";
	self[$ gp_stickr] = "thumbstick r click";
	
	self[$ gp_shoulderl ] = "shoulder l";
	self[$ gp_shoulderr ] = "shoulder r";
	self[$ gp_shoulderlb] = "trigger l";
	self[$ gp_shoulderrb] = "trigger r";
	
	self[$ gp_padu] = "dpad up";
	self[$ gp_padd] = "dpad down";  
	self[$ gp_padl] = "dpad left";  
	self[$ gp_padr] = "dpad right";  
	
	self[$ gp_face1] = "face south";
	self[$ gp_face2] = "face east";
	self[$ gp_face3] = "face west";
	self[$ gp_face4] = "face north";
	
	self[$ gp_select] = "select";
	self[$ gp_start ] = "start";
	self[$ gp_home  ] = "home";
	
	self[$ gp_paddler ] = "paddle r";
	self[$ gp_paddlel ] = "paddle l";
	self[$ gp_paddlerb] = "paddle rb";
	self[$ gp_paddlelb] = "paddle lb";
	
	self[$ gp_extra1] = "extra 1";
	self[$ gp_extra2] = "extra 2";
	self[$ gp_extra3] = "extra 3";
	self[$ gp_extra4] = "extra 4";
	self[$ gp_extra5] = "extra 5";
	self[$ gp_extra6] = "extra 6";
	
	self[$ gp_touchpadbutton] = "touchpad";
}	