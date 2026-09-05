//feather ignore all

/** Returns the total number of defined input verbs.
 * @return {Real} */
function Input_VerbCount() {
	//TODO: Return 0 for now
	return 0;
}

/** Returns the ASC used by the specified `IAbilitySystem` GMObject instance or `undefined` if not set
 * @arg {Id.Instance} instance The ID of the GMObject instance implementing `IAbilitySystem`
 * @return {Struct.InputSystemComponent} */
function InputSystem_GetInputSystemComponentFromInstance(instance) {
	//Make sure the provided id is valid
	if (is_undefined(instance) || (instance == noone)) {
		if (ABILITY_LOG_ERROR) {
			LogError(ExceptionMessage("InputSystem_GetInputSystemComponentFromInstance", $"Invalid instance Id provided. Instance id = {instance}"))
		}
		return;
	}
	
	//Make sure the instance still exists before trying to access it
	if (!instance_exists(instance)) {
		if (ABILITY_LOG_ERROR) {
			LogError(ExceptionMessage("InputSystem_GetInputSystemComponentFromInstance", $"Instance does not exist."))
		}
		return;			
	}
	
	//Make sure the instance is also implementing IAbilitySystem
	if (!variable_instance_exists(instance, "GetInputSystemComponent")) {
		if(ABILITY_LOG_ERROR) {
			LogError(ExceptionMessage("InputSystem_GetInputSystemComponentFromInstance", $"Instance is not implementing IAbilitySystem"));
		}
		return;
	}
	
	var f = variable_instance_get(instance, "GetInputSystemComponent");
	return (is_undefined(f)) ? f : method_call(method(instance, f));
}