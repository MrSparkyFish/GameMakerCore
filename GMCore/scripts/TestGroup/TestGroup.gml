
/** TestGroup: Represents a group of executable UnitTests
 * @arg {String} _name Name of the test group
 * @arg {Struct} _settings A config struct for this group. 
 * @return {Struct.TestGroup} */
function TestGroup(_name = undefined, _settings = undefined) : Test(_name) constructor {
	
	
	//Standard variables
	///@ignore
	tests = [];										//Tests the group will iterate through
	///@ignore
	bailOnFail = false;								//If the group should terminate if a single test fails
	///@ignore
	delaySeconds = 0.002;							//Time between test iterations
	///@ignore
	passBag = true;									//If diagnostic data should be passed through to each test
	///@ignore
	it = 0;											//Current test iteration
	
	
	AddProperty("bailOnFail", undefined, undefined, is_bool);
	AddProperty("delaySeconds", undefined, undefined, is_numeric);
	AddProperty("passBag", undefined, undefined, is_bool);
	
	
	
	/** Adds a test to this group of tests
	 * @arg {Struct.Test} _test The test to add to this TestGroup
	 * @return {Undefined} */
	static Add = function(_test) {
		if (!is_instanceof(_test, Test)) {
			ThrowInvalidType("Add", "_test", _test, "Test", self);
			return;
		}
		array_push(tests, _test);
	}		
	
	/** Removes the argument test from the group and returns true if removal was successful
	 * @return {Undefined} */
	static Remove = function(_test) {
		ArrayRemove(tests, _test);
	}
	
	//THIS METHOD MUST BE NON STATIC It gets passed around and will otherwise lose scope.
	/** Concrete Hook Method that executes the custom test logic. Does not start the test! Use RunTest to start Test execution.
	 * @ignore Internal use only
	 * @arg {Struct.Test} _test Current test being executed by the group.
	 * @return {Undefined} */	
	Run = function(_test = undefined) {
		//Stop iteration if the test failed and bailOnFail is set to true.
		if (!is_undefined(_test) && _test.IsFailed() && bailOnFail) {
			result = TestResult.bailed;
			PostRun();
		}
		
		//Otherwise Iterate and execute each test one at a time
		else if (it < array_length(tests)) {
			//Have to go to an emtpy room to avoid stacking up too many calls
			room_goto(rmRunTest);
			
			//Delay call to account for the room change and set this Run function to be the callback so we can continue iterating after the test 
			return call_later(delaySeconds, time_source_units_seconds, function() { 
				if (passBag) {
					tests[it++].StartTest(Run, dataBag);
				}
				else {
					tests[it++].StartTest(Run);
				}
			});
			
		}
		
		//If there's no more tests, end the run
		else {
			PostRun();
		}
	}
	
	
	Configure(Config_GetConfig(self));
	Configure(_settings);
}