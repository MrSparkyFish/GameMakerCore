/** InputPlugIn: Represents a plugin definition
 * @arg {
 * @return {Struct.InputPlugIn} */
function InputPlugIn(_name, _author, _version, _targetVersion, _plugInSystem) constructor {
	
	
	//Could make the `Initialize()` function make SystemComponents for the relevant system. One component for each possible player. 
	//Then they'd only be instantiated when this plug-in is inserted into the inputsystem. Can also included a getter for each component
	
	
	name = _name;
	author = _author;
	version = _version;
	targetVersion = _targetVersion;
	plugInSystem = _plugInSystem;		
	
	
	
	
	/** Call to initialize the new plug in with the specified `InputSystem`
	 * @arg {Struct.InputSystem} _inputSystem
	 * @return {Undefined} */
	static Initialize = function(_inputSystem) {
		if (!is_callable(plugInSystem)) {
			ThrowInvalidType("Initialize", "_inputSystem", _inputSystem, "instance of InputSystem", self);
		}
		LogInfo($"Using plug-in {name} version {version} by {author}.\nIntended for Input version {targetVersion}.");
		return new plugInSystem(_inputSystem);
	}
}