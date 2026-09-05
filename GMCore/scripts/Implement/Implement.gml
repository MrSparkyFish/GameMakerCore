//feather ignore all

//If true, allows the `Implement` function to ensure its calling struct has all of the required interface members. Set to false for a performance boost.
#macro INTERFACE_SAFETY_CHECK true 

/** Use this function to ensure that the calling struct has all the members defined by an interface. The calling struct must have been created by a 
 * constructor function. Since interface implementation in GM is implicit, this function is used as a debugging tool to ensure that structs have the 
 * required interface members. You can pass up to 16 interface functions (separated by commas) into this function to verify.
 * @return {Undefined} */
function Implement() {
	INLINE;
	//Don't do work if we're skipping this implementation check
	if (!INTERFACE_SAFETY_CHECK) {
		return;
	}
	
	///@ignore Map of classes to their interfaces
	static implemented = {};
	
	var name = instanceof(self);
	var interface = implemented[$ name];
	if (!is_struct(interface)) {
		interface = {};
		implemented[$ name] = interface;
		
		for (var i = 0; i < argument_count; i++) {
			with(interface) {
				argument[i]();
			}
		}
	}
	
	//Implement missing interface members for this class instance 
	struct_foreach(interface, function(name, value) {
		self[$ name] ??= value;
	});	
}
