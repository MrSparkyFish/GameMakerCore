/** Throw a property error
 * @arg {String} _func The name of the function throwing the error
 * @arg {String} _desc Description of the error
 * @arg {Struct|Id.Instance} [_scope] Scope the function was called in if different from `self`
 * @return {Undefined} */
function Config_PropertyError(_func, _desc, _scope = undefined) {
	_scope ??= self;
	var _title = "Config Property Error!";
	var _description = ExceptionMessage(_scope, _func, _desc);
	ThrowException(_title, _description, _scope);
}


/** Returns the specified configuration manager. If the specified config doesn't exist, one is created.
 * @arg {String} [_configType] The name of the config manager that you want to retrieve.
 * @return {Struct.ConfigManager} */
function Config_GetManager(_configType = "$$default$$") {
	///@ignore
	static configManagers= {};
	if (!struct_exists(configManagers, _configType)) {
		configManagers[$ _configType] = new ConfigManager();
	}
	return configManagers[$ _configType];
}


/** Sets the configuration for a class from a file. Multiple configs can be set at the same time as long as they are all in the same file.
 * @arg {String} _filename The name of the config file to be loaded
 * @arg {String} [_configType] The name of the config manager that should store this config struct.
 * @return {Undefined} */
function Config_LoadConfig(_filename, _configType = "$$default$$") {
	var configManager = Config_GetManager(_configType);
	return configManager.LoadConfigsFromFile(_filename);
}


/** Returns the default configuration struct for a configurable object or `undefined` if no config struct exists
 * @arg {Struct.Configurable} _struct The struct or class name to get the default config for
 * @arg {String} [_configType] The name of the config manager that's holding the config for this 
 * @return {Struct} */ 
function Config_GetConfig(_struct, _configType = "$$default$$") {
	var configManager = Config_GetManager(_configType);
	return configManager.GetConfig(_struct);
}


/** Sets the default configuration struct for a class
 * @arg {Struct.Configurable|String} _struct The class that the config is being set for.
 * @arg {Struct} _config A struct of property values
 * @arg {String} [_configType] The name of the config manager that should store this config.
 * @return {Undefined} */
function Config_SetConfig(_struct, _config, _configType = "$$default$$") {
	var configManager = Config_GetManager(_configType);
	configManager.SetConfig(_struct, _config);
}