//feather ignore all


global.currentTest = undefined;



function TestInitialize() {
	
	/** Applies the proper scope to test execution.
	 * @ignore Internal use only
	 * @arg {Struct} _events Maps events to functions
	 * @arg {Id.Instance,Struct} _scope The scope to use for the function call
	 * @return {Undefined} */
	static applyScope = function(_events, _scope) {
		var _names = struct_get_names(_events)
		var _len = array_length(_names);
		for (var i = 0; i < _len; i++) {
			var _name = _names[i];
			_events[$ _name] = method(_scope, _events[$ _name]);
		}
	}
	
	
	
	var _test = global.currentTest;
	applyScope(_test.events, self);
	_test.startTime = get_timer();
	
}

/** Sends a test to the global scope
 * @arg {Struct.Test} _test
 * @return {Undefined} */
function TestPush(_test) {
	if (!is_undefined(global.currentTest)) {
		throw (LogError($"Function::TestPush -> Trying to push a test while another is still running!"));
	}
	
	global.currentTest = _test;
}

/** Pop a test from the global context. Test can only be popped if it isn't running
 * @return {Struct.Test} */
function TestPop() {
	var _test = global.currentTest;
	
	if (is_undefined(_test)) {
		throw LogError("Function:TestPop -> There is no test to pop");
	}
	
	global.currentTest = undefined;
	return _test;
}

/** Returns the current running test
 * @return {Struct.Test} */
function TestCurrent() {
	return global.currentTest;
}


/** Runs the given event of the current test
 * @return {Undefined} */
function TestRunEvent(_eventName) {
	var _test = global.currentTest;
	if (is_undefined(_test)) {
		return;
	}
	
	var _func = _test.events[$ _eventName];
	if (is_callable(_func)) {
		try {
			_func();
		}
		catch (_error) {
			_test.AddDiagnostic(_error, "Exception");
		}
	}
}

/** Forcibly end a running test and set the result outcome manually
 * @arg {Enum.test_result} _forceResult
 * @return {Undefined} */
function TestEnd(_forceResult = TestResult.unset) {
	var _timeStamp = get_timer();
	var _test = global.currentTest;
	
	_test.result = _forceResult;
	_test.endTime = _timeStamp;
	
	TestRunEvent("ev_cleanup");
	instance_destroy(self);
	
	_test.PostRun();
	room_goto(rmRunTest);
}