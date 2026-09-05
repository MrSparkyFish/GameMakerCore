//feather ignore all


/** Converts the given ds_grid into an array.
 * @arg {Id.DsGrid} _grid The grid to convert to an array
 * @return {Array<Array>} */
function DsGridToArray(_grid) {
	
	var _width = ds_grid_width(_grid);
	var _height = ds_grid_height(_grid);
	var _output = array_create(_width);
	
	for (var _i = 0; _i < _width; _i++) {
		var _column = array_create(_height);
		_output[_i] = _column;
		
		
		for (var _j = 0; _j < _height; _j++) {
			_column[_j] = _grid[# _i, _j];
		}
	}	
	return _output;
}


/** Converts the given ds_list into an array.
 * @arg {Id.DsList} _list The list to convert to an array
 * @return {Array<Any>} */
function DsListToArray(_list) {
	
	var _output = [];
	var _size = ds_list_size(_list);
	
	repeat (_size) {
		--_size;
		_output[_size] = _list[| _size];
	}
	
	return _output;
}


/** Converts the given ds_map into an array.
 * @arg {Id.DsMap} _map The map to convert to an array
 * @return {Array<Any>} */
function DsMapToArray(_map) {
	
	var _output = array_create(ds_map_size(_map));
	var _keys = ds_map_keys_to_array(_map);
	
	var _length = array_length(_keys);
	for (var _i = 0, _j = 0; _i < _length; _i++) {
		
		var _key = _keys[_i];
		_output[_j*2] = _key;
		_output[_j*2 + 1] = _map[? _key];
	}
	
	return _output;
}


/** Converts the given ds_queue into an array.
 * @arg {Id.DsQueue} _queue The queue to convert to an array
 * @return {Array<Any>} */
function DsQueueToArray(_queue) {
	
	var _output = [];
	
	repeat (ds_queue_size(_queue)) {
		var _value =  ds_queue_dequeue(_queue);
		array_push(_output,_value);
		ds_queue_enqueue(_queue, _value);
	}
	
	return _output;
}


/** Converts the given ds_stack into an array.
 * @arg {Id.DsStack} _stack The stack to convert to an array
 * @return {Array<Any>} */
function DsStackToArray(_stack) {
	
	var _i = 0;
	var _output = [];
	repeat (ds_stack_size(_stack)) {
		_output[_i++] = ds_stack_pop(_stack);
	}
	
	repeat(_i) {
		ds_stack_push(_stack, _output[--_i]);
	}
	
	return _output;
}	






