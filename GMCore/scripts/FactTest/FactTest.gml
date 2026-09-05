/** FactTest: Represents a single test case.
 * @arg {String} _name The name of the test
 * @arg {Function} _testFunc The function to test
 * @arg {Struct} [_settings] Optional settings for the test case
 * @return {Struct.FactTest} */
function FactTest(_name, _testFunc, _settings = undefined) : AsyncTest(_name) constructor {
	
	events = {
		ev_create : _testFunc
	}
	
	Configure(Config_GetConfig(self));
	Configure(_settings);
}