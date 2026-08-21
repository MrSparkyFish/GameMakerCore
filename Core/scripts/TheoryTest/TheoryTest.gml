/** Represents a series of test cases. Executes the specified test function once for each element in the specified array
 * @arg {String} _name The name of the test
 * @arg {Array<Array>} _data The array of elements to execute the test on.
 * @arg {Function} _testFunc The function to test
 * @arg {Struct} [_settings] Optional test settings
 * @return {Struct.TheoryTest} */
function TheoryTest(_name, _data, _testFunc, _settings = undefined) : AsyncTest(_name, , , _settings) constructor {
	///@ignore
	testData = _data;
	///@ignore
	testFunction = _testFunc;
	///@ignore
	iteration = 0;
	
	events = {
		
		ev_create : function() {
			var _test = TestCurrent();
			var _data = _test.testData;
			var _testFunc = _test.testFunction;
			var _len = array_length(_data);
			for (var i = 0; i < _len; i++) {
				_test.iteration = i;
				method_call(_testFunc, _data[i]);
			}
			_test.iteration = 0;
		}
	}
	
	Configure(Config_GetConfig(self));	
}