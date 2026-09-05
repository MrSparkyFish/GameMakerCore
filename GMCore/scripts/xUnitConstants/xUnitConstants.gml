//feather ignore all

 
//Represents the result of the test
enum TestResult {
	unset,
	passed,
	failed,
	skipped,
	bailed,
	expired
}

//How the test should log/print results
enum TestPrintPolicy {
	never,				
	always,
	fail,
	pass,
}

//current state of the test
enum TestStates {
	none,
	active,
	finished,
	idle
}