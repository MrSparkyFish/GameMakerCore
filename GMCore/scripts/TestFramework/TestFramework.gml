/** TestFramework: This class allows you to execute a series of TestSuites within the same run.
 * @arg {String} _name Name of the TestFramework
 * @arg {Struct} [_options] _options
 * @return {Struct.TestFramework} */
function TestFramework(_name, _options = undefined) : TestGroup(_name) constructor {	
	/** Add a new test suite to the framework run process
	 * @arg {Function} _suite The constructor function of the suite to add
	 * @return {Undefined} */
	static AddTestSuite = function(_suite) {
		try {
			Add(new _suite());
		}
		
		catch (exception) {
			AddDiagnostic(exception, "Exception");
			LogCritical($"TestFramework::AddTestSuite -> Internal Error during test instantiation (skipping suite [{script_get_name(_suite)}]) ");
		}
	}
	
	
	Configure(Config_GetConfig(self));
	Configure(_options);
}