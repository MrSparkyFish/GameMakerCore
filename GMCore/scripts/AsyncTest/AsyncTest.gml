/** AsyncTest: Concrete Implementation of a UnitTest that allows for tests to be delay called
 * @arg {String} _testName The name of the test
 * @arg {Asset.GMObject} _testObject The object to run the async test
 * @arg {Struct} _events The function with the logic to test
 * @arg {Struct} [_testOptions] A configuration struct
 * @return {Struct.AsyncTest} */
function AsyncTest(_testName, _testObject = oAsyncTest, _events = undefined, _testOptions = undefined) : Test(_testName) constructor {
	///@ignore
	object = _testObject;
	///@ignore
	timeoutHandle = undefined;
	///@ignore
	timeoutSeconds = 6;								//How long this test can run before being forced to expire
	
	AddProperty("timeoutSeconds", timeoutSeconds, is_real);
	
	
	
	/** Hook method. Automatically called by test execution process. Should be redefined in subclasses. 
	 * @return {Undefined} */	
	PreRun = function() {
		
		CallStartHook();
		
		//Push this test to global
		TestPush(self);
		
		//If test should not run
		if (!CallTestFilter()) {
			//Set as skipped
			result = TestResult.skipped;
			
			//Skip test by going to PostRun() instead of Run()
			PostRun();
			return;
		}
		
		var _handler = instance_create_depth(0,0,0,object);
		
		//If there's currently an async test running, set a timeout function to expire it
		if (TestCurrent() != undefined) {
			timeoutHandle = call_later(timeoutSeconds, time_source_units_seconds, method(_handler, function() {
				TestEnd(TestResult.expired);
			}), false);
		}
	}
	
	/** Hook method. Automatically called by test execution process. Should be redefined in subclasses. 
	 * @return {Undefined} */	
	PostRun = function() {
		endTime = get_timer();
		
		//Cancel the timed call to the expiration function so this test doesn't end prematurely
		if (!is_undefined(timeoutHandle)) {
			call_cancel(timeoutHandle);
		}
		
		//Test Result setting
		if (result == TestResult.unset) {
			result = (HasDiagnostics("Exception")) ? TestResult.failed : TestResult.passed;
		}
		
		//Remove this test as the currently executing test
		TestPop();
		
		//Do end hook logic and finish test 
		CallEndHook();
		FinishRun();
	}
	
	
	Configure(Config_GetConfig(self));
	Configure(_testOptions);
}