//feather ignore all

/** ConfigManager: Stores the default config structs for Configurable classes.
 * @return {Struct.ConfigManager} */
function ConfigManager() constructor {
	///@ignore
	configs = {};
	
	
	/** Returns the class based configuration for the argument struct or `undefined` if no config has been set for the class.
	 * @arg {Struct|String} _struct The struct or constructor name to get the class config for.
	 * @return {Struct} */
	static GetConfig = function(_struct) {
		var _class = (is_string(_struct)) ? _struct : instanceof(_struct);
		return StructTryGetMember(configs, _class);
	}
	
	
	/** Sets the configuration for the class type of the struct argument.
	 * @arg {Struct.Configurable|String} _struct The struct or class name to set the class config for
	 * @arg {Struct} _data The config struct to set for the class. A config is any data struct (contains no methods or functions)
	 * @arg {Bool} [_overwrite] Whether the config is overwritten (true) or just updated (false). Default is false.
	 * @return {Undefined} */
	static SetConfig = function(_struct, _data, _overwrite = false) {
		//Get the name of the struct in string form
		var _class = (is_string(_struct)) ? _struct : instanceof(_struct);
		
		
		//Overwrite/set the config value for the class
		if (!struct_exists(configs, _class) || _overwrite) {
			configs[$ _class] = _data;
		}
	}
	
	
	/** Loads a config file and merges the loaded configuration structs with the manager.
	 * @arg {String} _filename The name of the file to get the configs from
	 * @return {Undefined} */
	static LoadConfigsFromFile = function(_filename) {
		//Send warning and end method if configs file isn't found
		if (!file_exists(_filename)) {
			return LogWarning("loadConfigFromFile :: config file doesn't exist");
		}
		
		//Load, read, then parse the config file data
		var _buffer = buffer_load(_filename);
		var _json_string = buffer_read(_buffer, buffer_string);
		var _struct = json_parse(_json_string);
		
		//Unflatten and merge the configs
		var _configs = StructUnflatten(_struct);
		StructMerge(configs, _configs);
		
		//Delete the buffer
		buffer_delete(_buffer);
	}
}