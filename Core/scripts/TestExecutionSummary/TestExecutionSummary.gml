/** TestResultSummary: A struct of data that displays generic test execution results
 * @arg {Struct.Test} _test 
 * @return {Struct.TestExecutionSummary} */
function TestExecutionSummary(_test) constructor {
	TestClass = instanceof(_test);
	TestName = _test.GetName() ?? undefined;
	Result = _test.GetResultString() ?? undefined;
	RunTime = $"{_test.GetTime()/1000} milliseconds";
	Diagnostics = _test.diagnostics;
}