//feather ignore all

/** Abstract superclass for object hierarchies that need to dynamically change default property values at instantiation time. For example,
 * `TestFramework` in `oTestRunner` wants to change its default `TestGroup` config for its `TestFramework` subobject. By making it configurable 
 * we can more easily change the setup of that class for just that instance of `TestFramework`.
 * ***
 * Inherits:
 * * `PropertyHolder`
 * @return {Struct.Configurable} */
function Configurable() : PropertyHolder() constructor {
	//Interface Implementation
	Implement(Configurable);
	
	/** Configures the current instance. Needs to be explicitly called to configure properly. Will not configure unless a configuration for this instance
	 *  has been previously set using `Config_SetConfig()`. 
	 * @arg {Struct} _configuration A struct with members and values named after this instances properties.
	 * @return {Undefined} */
	static Configure = function(_configuration) {
		//Make sure that _configuration is a struct
		if (is_struct(_configuration)) {
			struct_foreach(_configuration, function(name, value) {
				SetPropertyValue(name, value);
			});
		}
	}
}