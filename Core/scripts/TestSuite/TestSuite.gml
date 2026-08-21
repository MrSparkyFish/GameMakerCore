/** TestSuite: Represents a series of related UnitTests
 * @arg {String} _name Name of the TestSuite
 * @arg {Struct} [_settings] A config struct for this suite.
 * @return {Struct.TestSuite} */
function TestSuite(_name, _settings = undefined) : TestGroup(_name) constructor {
	
	/** Add a fact test to this group
	 * @arg {String} _name The name of the test
	 * @arg {Function} _function The function that contains the test logic
	 * @arg {Struct} _options Configure options for this test
	 * @return {Undefined} */
	static AddFact = function(_name, _function, _options = undefined) {
		var _fact = new FactTest(_name, _function, _options);
		Add(_fact);
		return _fact;
	}
	
	/** Add a fact test to this group
	 * @arg {String} _name The name of the test
	 * @arg {Array<Any>} _data The array of data to supply this test.
	 * @arg {Function} _function The function that contains the test logic
	 * @return {Undefined} */	
	static AddTheory = function(_name, _data, _function) {
		var _theory = new TheoryTest(_name, _data, _function);
		Add(_theory);
		return _theory;
	}
	
	
	Configure(Config_GetConfig(self));
	Configure(_settings);
}