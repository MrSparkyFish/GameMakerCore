//Feather ignore all

/** UnitTest: Abstract class that represents the testing algorithm.
 * @arg {String} _testName Name to give the test
 * @return {Struct.UnitTest} */
function Test(_testName = undefined) : Configurable() constructor {
	
	///@ignore
	static resultStrings = ["Unset", "Passed", "Failed", "Skipped", "Bailed", "Expired"]; 
	
	///@ignore
	diagnostics = {};								//Struct containing various diagnostic messages
	///@ignore
	state = TestStates.none;						//Current state of the test
	///@ignore
	result = TestResult.unset;						//Test conclusion
	///@ignore
	startTime = 0;									//Test started timestamp
	///@ignore
	endTime = -1;									//Test finished timestamp. Default to -1 so we know if 
	///@ignore
	dataBag = undefined;							//A container that collects test results and carries them between tests
	///@ignore
	testName = _testName; 							//Name of the test
	///@ignore
	callback = undefined;							//Callback to invoke after the test finishes
	
	//Configurable variables (Properties)
	///@ignore
	startHook = undefined;							//Optional method to call at the start of every test. Should take two arguments (_scope, _resultData).
	///@ignore
	endHook = undefined;							//Optional method to call at the end of every test. Should take two arguments (_scope, _resultData).
	///@ignore
	testFilter = undefined;							//Predicate function to call before test execution that takes no args and should return true if a test should run or false if it shouldn't.
	///@ignore
	printPolicy = TestPrintPolicy.always;			//How test results should be printed/logged
	
	AddProperty("startHook", function() {
		return (is_callable(startHook) || is_undefined(startHook));
	});
	AddProperty("endHook", function() {
		return (is_callable(endHook) || is_undefined(endHook));
	});
	AddProperty("testFilter", function() {
		return (is_callable(testFilter) || is_undefined(testFilter));
	});
	AddProperty("printPolicy");
	
	
	/** Adds an Exception Struct to the exceptions diagnostics struct
	 * @arg {Struct|String} _struct The Exception Struct to add (see manual) or a string of info to add.
	 * @return {Undefined} */
	static AddDiagnostic = function(_struct, _name) {
		diagnostics[$ _name] ??= [];
		ArrayAdd(diagnostics[$ _name], _struct);
	}
	
	/** Calls the testFilter to determine if the test can run (true) or not (false). Returns true by default.
	 * @return {Bool} */
	static CallTestFilter = function() {
		if (is_callable(testFilter)) {
			return testFilter();
		}
		return true;
	}	
	 
	/** Helper function that calls the endHook (if configured)
	 * @return {Undefined} */
	static CallEndHook = function() {
		if (is_callable(endHook)) {
			endHook(self, dataBag);
		}
	}		
	
	 /** Helper function that calls the startHook (if configured)
	 * @return {Undefined} */
	static CallStartHook = function() {
		if (is_callable(startHook)) {
			startHook(self, dataBag);
		}
	}	
	
	/** Returns an Array of diagnostic structs or if the named array isn't found, returns the diagnostics struct
	 * @arg {String} _name The name of the diagnostics array to get
	 * @return {Struct|Array|Any} */
	static GetDiagnostics = function(_name = undefined) {
		if (struct_exists(diagnostics, _name)) {
			return diagnostics[$ _name];
		}
		
		else {
			return diagnostics;
		}
	}	
	
	/** Checks if the current test generated any diagnostics of a specific name 
	 * @arg {String} [_name] The diagnostic to check for.
	 * @return {Bool} */
	static HasDiagnostics = function(_name = undefined) {
		var _bool = (struct_exists(diagnostics, _name)) ? (array_length(diagnostics[$ _name]) > 0) : (struct_names_count(diagnostics) > 0);
		return _bool;
	}	
	
	/** Returns a struct containing the summary of this Test's execution
	 * @return {Struct.TestExecutionSummary} */
	static GetExecutionSummary = function() {
		var _summary = new TestExecutionSummary(self);
		return _summary;
	}
	
	/** Returns the result conclusion enum value
	 * @return {Real} */
	static GetResult = function() {
		return result;
	}	
	
	/** Returns the total amount of time it took for the Test to execute (in micro seconds)
	 * @return {Real} */
	static GetTime = function() {
		return endTime - startTime;		//Total is default micro seconds
	}		
	
	
	/** Returns the name of this test
	 * @return {String} */
	static GetName = function() {
		return testName;
	}	
	
	/** Returns the result conclusion as a string
	 * @return {String} */
	static GetResultString = function() {
		return resultStrings[result];
	}
	
	/** Returns the currently set test_states enum value
	 * @return {Real} */
	static GetState = function() {
		return state;
	}
	
	/** Sets the test_states of this test
	 * @arg {Enum.test_states} _state 
	 * @return {Undefined} */
	static SetState = function(_state) {
		state = _state;
	}
	
	/** Returns if the test is actively being executed
	 * @return {Bool} */
	static GetActive = function() {
		return (state == TestStates.active);
	}	
	
	/** Returns true if this test has finished
	 * @return {Bool} */
	static IsFinished = function() {
		return (state == TestStates.finished)
	}
	
	/** Returns if this test execution is a failure.
	 * @return {Undefined} */
	static IsFailed = function() {
		return ((result == TestResult.failed) || (result == TestResult.expired));
	}	
	
	/** Returns if this test execution was skipped or not.
	 * @return {Bool} */
	static IsSkipped = function() {
		return (result == TestResult.skipped);
	}	
	
	
	/** Resets this test to a neutral state
	 * @ignore Used internally only
	 * @return {Undefined} */
	static ResetTest = function() {
		state = TestStates.none;
		diagnostics = {};
	}
	
	
	/** Concrete Hook method. Automatically called by test execution process. 
	 * @ignore
	 * @return {Undefined} */
	static PreRun = function() {
		CallStartHook();
		CallTestFilter();
		
		state = TestStates.active;
		startTime = get_timer();
		Run();
	}
	
	/** Hook method. Automatically called by test execution process. Should be redefined in subclasses to perform the actual test logic.
	 * @return {Undefined} */
	static Run = function() {
		PostRun();
	}	
	
	/** Concrete Hook method. Automatically called by test execution process.
	 * @ignore
	 * @return {Undefined} */
	static PostRun = function() {
		endTime = get_timer();
		
		//Determine what test results should be set
		if (result == TestResult.unset) {
			result = (HasDiagnostics("Exception")) ? TestResult.failed : TestResult.passed;
		}
		
		CallEndHook();
		FinishRun();
	}
	
	/** Hook method. Automatically called by test execution process. Should be redefined in subclasses to perform the actual clean up logic.
	 * @return {Undefined} */
	static CleanUp = function() {
		return
	}
	
	/** Concrete Hook method. Automatically called by test execution process. 
	 * @ignore
	 * @return {Undefined} */	
	static FinishRun = function() {
		state = TestStates.finished;
		CleanUp();
		
		//Gather data from the actual execution
		if (is_array(dataBag)) {
			array_push(dataBag, GetExecutionSummary());
		}
		
		if (is_callable(callback)) {
			callback(self);
		}
		
		switch (printPolicy) {
			case TestPrintPolicy.always: 
				LogDebug($"{json_stringify(dataBag, true)}");
			break;
			
			case TestPrintPolicy.fail:
				if (IsFailed()) {
					LogDebug($"{json_stringify(dataBag, true)}");
				}
			break;
			
			case TestPrintPolicy.pass:
				if (result == TestResult.passed) {
					LogDebug($"{json_stringify(dataBag, true)}");
				}
			break;
			
			default:
			break;
		}
		
		if (instance_exists(oTestRunner)) {
			oTestRunner.frameworkRunning = false;
		}
		
		if (is_instanceof(self, TestFramework) && FRAMEWORK_END_GAME_ON_FINISH) {
			game_end();
		}
	}
	
	
	/** Call to start test execution.
	 * @arg {Function} _callback Callback function that should be executed when the test finishes
	 * @arg {Array} _resultBag Array where the test will store its execution summary
	 * @return {Undefined} */
	static StartTest = function(_callback = undefined, _resultBag = undefined) {
		_resultBag ??= [];
		dataBag = _resultBag;
		
		if (GetActive()) {
			throw LogError($"{instanceof(self)}::RunTest -> Test is already running");
		}
		
		callback = _callback;
		ResetTest();
		
		if (FRAMEWORK_SHOULD_CATCH) {
			try {
				PreRun();
			}
			
			catch(_exception) {
				AddDiagnostic(_exception, "Exception");
				FinishRun();
			}
		}
		
		else {
			PreRun();
		}
	}
	
	Configure(Config_GetConfig(self));
}