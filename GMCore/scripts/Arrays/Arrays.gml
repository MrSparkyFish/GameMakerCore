//feather ignore all


/** Adds a value to the end of the specified array and returns the index where it was added.
 * @arg {Array<Any>} array The array to add to
 * @arg {Any} value The value to add.
 * @return {Real} */
function ArrayAdd(array, value) {
	array_push(array, value);
	return array_length(array) - 1;
}

/** Concatenates a source array to the end of a destination array.
 * @arg {Array<Any>} _dest The array to merge values into
 * @arg {Array<Any>} source The array to merge values from
 * @return {Undefined} */
function ArrayAddAll(_dest, source) {
	array_copy(_dest, array_length(_dest), source, 0, array_length(source));
}

/** Removes all the contents from the argument `array`.
 * @arg {Array<Any>} array The array to empty
 * @return {Undefined} */
function ArrayClear(array) {
	array_resize(array, 0);
}

/** Turns the specified target array into a deep copy of the source array.
 * @arg {Array<Any>} sourceArray The array containing the source values
 * @arg {Array<Any>} targetArray The array to populate.
 * @return {Array<Any>} */
function ArrayCloneDeep(sourceArray, targetArray) {
	//Don't do work if there's no work to do
	var _count = array_length(sourceArray);
	if (_count == 0) {
		return targetArray;
	}
	array_resize(targetArray, _count);
	array_copy(targetArray, 0, variable_clone(sourceArray), 0, array_length(sourceArray));
	return targetArray;
}

/** Turns the specified target array into a shallow copy of the source array.
 * @arg {Array<Any>} sourceArray The array containing the source values
 * @arg {Array<Any>} targetArray The array to populate.
 * @return {Array<Any>} */
function ArrayCloneShallow(sourceArray, targetArray) {
	//Don't do work if there's no work to do
	var _count = array_length(sourceArray);
	if (_count == 0) {
		return targetArray;
	}
	array_resize(targetArray, _count);
	array_copy(targetArray, 0, sourceArray, 0, _count);
	return targetArray;
}

/** Checks if an array contains all values found in an opposing array
 * @arg {Array<Any>} array The array to check
 * @arg {Array<Any>} values An array of values to check for 
 * @return {Bool} */
function ArrayContainsAllValues(array, values) {
	var len = array_length(values);
	for (var i = 0; i < len; i++) {
		if (!array_contains(array, values[i++])) {
			return false;
		}
	}
	return true;
}

/** Returns `true` if array A contains any of the values in array B.
 * @arg {Array<Any>} arrayA The array to check
 * @arg {Array<Any>} arrayB An array of values to check for
 * @return {Bool} */
function ArrayContainsAnyValue(arrayA, arrayB) {
	return (array_length(array_intersection(arrayA, arrayB)) > 0);
}

/** Checks the provided array to see if it contains an instance of the provided constructor
 * @arg {Array<Any>} array The array to check
 * @arg {String} _constructor The name of the constructor to check for instances of
 * @return {Bool} */
function ArrayContainsInstanceOf(array, _constructor) {
	return (ArrayFindInstanceOfIndex(array, _constructor) >= 0);
}

/** Checks if the specified `value` is an `Array`. If not, a new array containing `value` at index 0 is created and returned.
 * @arg {Any} value The value to return an array of.
 * @return {Array<Any>} */
function ArrayConvertValue(value) {
	return (!is_array(value)) ? [value] : value;
}

/** Returns `true` if the specified `arrayToCheck` has identical size and has the same index values as `arrayToCompare`
 * @arg {Array<Any>} arrayToCheck
 * @arg {Array<Any>} arrayToCompare
 * @return {Bool} */
function ArrayEqualsArray(arrayToCheck, arrayToCompare) {
	
	//Helper func
	///@ignore
	static arrayEquals = function(a, b) {
		if (a == b) {
			return true;
		}
		else if (is_struct(a) && is_struct(b)) {
			return StructEqualsStruct(a, b);
		}
		else if (is_array(a) && is_array(b)) {
			return ArrayEqualsArray(a, b);
		}
		return false;
	}
	
	
	//Test if array lengths match
	var _len = array_length(arrayToCheck);
	if (_len != array_length(arrayToCompare)) {
		return false;
	}
	
	//Loop through all elements until an index doesn't match
	for (var i = 0, _current; ((i < _len)); i++) {
		if (!arrayEquals(arrayToCheck[i], arrayToCheck[i])) {
			return false;
		};
	}	
	return true;
}

/** Searches the array for a struct that is a descendant of the specified constructor. If found, the struct is returned, otherwise, returns undefined.
 * @arg {Array<Any>} array The array to search
 * @arg {Function} construct The constructor function to get an instance from
 * @return {Struct} */
function ArrayFindInstanceOf(array, construct) {
	var len = array_length(array);
	for (var i = 0, result; i < len; i++) {
		result = array[i];
		if (is_instanceof(result, construct)) {
			return result;
		}
	}
}

/** Returns the first struct found in an array that was created from the name constructor function. Returns `undefined` if no matching struct can be found
 * @arg {Array<Struct>} array The array of structs to search through 
 * @arg {String} className The name of the constructor 
 * @return {Struct} */
function ArrayFindInstanceOfClass(array, className) {
	var len = array_length(array);
	for (var i = 0, result; i < len; i++) {
		result = array[i];
		if (instanceof(result) == className) {
			return result;
		}
	}
}

/** Returns the first array index holding a struct created from the specified constructor. Returns `-1` if no struct is found.
 * @arg {Array<Any>} array The array to search
 * @arg {Function} _constructor The constructor function Arrayto check for
 * @return {Real} */
function ArrayFindInstanceOfIndex(array, _constructor) {
	var i = 0; repeat(array_length(array)) {
		if (is_instanceof(array[i], _constructor)) {
			return i;
		}
		i++;
	}
	return -1;
}

/** Checks an array for a value that matches the provided predicate. If found, the value is returned. Otherwise, returns `undefined`.
 * @arg {Array<Any>} array The array to iterate through
 * @arg {Function} func The predicate function to execute on each array element. The predicate must accept an array element as its first argument.
 * @arg {Array<Any>} [args] `[=undefined]` Optional array of additional arguments to pass to `func` after passing the current value.
 * @arg {Bool} [includeIndex] `[=false]` Set `true` if your passed in function takes the current element index as its second argument.
 * @return {Any} */
function ArrayFindValue(array, func, args = undefined, includeIndex = false) {
	//Setup the parameters array to pass to the callback
	var params = array_create(1 + includeIndex);
	params = array_concat(params, args ?? []);
	
	var len = array_length(array);
	if (!includeIndex) {
		//Calling the function on each array element + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			if (method_call(func, params)) {
				return i;
			}
		}		
	}
	else {
		//Calling the function on each array element + index + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			params[1] = i;
			if (method_call(func, params)) {
				return array[i];
			}
		}		
	}	
}

/** Returns the index of the first array element that satisfies the provided predicate function. The predicate function must take a value from the array as
 * its first argument. Additional arguments can be passed to the function using the `args` array. Optionally include the current index with `includeIndex`.
 * Returns `-1` if no elements satisfied the predicate.
 * @arg {Array<Any>} array The array to iterate through
 * @arg {Function} func The function to execute on each array element. Must take the current array element as its first argument. If `includeIndex` is set to `true`, then the function must accept the current array index as its second argument. 
 * @arg {Array<Any>} [args] `[=undefined]` Optional array of additional arguments to pass to `func` after passing the current value.
 * @arg {Bool} [includeIndex] `[=false]` Set to true if your passed in function takes the current element index as its second argument.
 * @return {Real} */
function ArrayFindIndex(array, func, args = undefined, includeIndex = false) {
	//Setup the parameters array to pass to the callback
	var params = array_create(1 + includeIndex);
	params = array_concat(params, args ?? []);
	
	var len = array_length(array);
	if (!includeIndex) {
		//Calling the function on each array element + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			if (method_call(func, params)) {
				return i;
			}
		}		
	}
	else {
		//Calling the function on each array element + index + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			params[1] = i;
			if (method_call(func, params)) {
				return i;
			}
		}		
	}
	return -1;	
}

/** Finds and removes all copies of a value from the provided array. Returns the number of elements removed.
 * @arg {Array<Any>} array The array to remove values from
 * @arg {Any} value The object to find and remove.
 * @return {Real} */ 
function ArrayFilterValue(array, value) {
	var _count = 0;
	while(ArrayRemove(array, value)) {
		_count++;
	}
	return _count;
}

/** Removes all copies of a series of values from the specified array
 * @arg {Array<Any>} array The array to remove values from
 * @arg {Array<Any>} values Array of values that need to be removed
 * @return {Undefined} */
function ArrayFilterValues(array, values) {
	var _len = array_length(values);
	for (var i = 0; i < _len; i++) {
		ArrayFilterValue(array, values[i]);
	}
}

/** Removes the elements from the specified array that satisfy the provided predicate function. The predicate function must take a value from the array as
 * its first argument. Additional arguments can be passed to the function using the `args` array. Optionally include the current index with `includeIndex`.
 * @arg {Array<Any>} array The array to iterate through
 * @arg {Function} func The function to execute on each array element. Must take the current array element as its first argument. If `includeIndex` is set to `true`, then the function must accept the current array index as its second argument. 
 * @arg {Array<Any>} [args] `[=undefined]` Optional array of additional arguments to pass to `func` after passing the current value.
 * @arg {Bool} [includeIndex] `[=false]` Set to true if your passed in function takes the current element index as its second argument.
 * @return {Undefined} */
function ArrayFilterValuesSatisfyingCondition(array, func, args = undefined, includeIndex = false) {
	//Setup the parameters array to pass to the callback
	var params = array_create(1 + includeIndex);
	params = array_concat(params, args ?? []);
	
	var len = array_length(array);
	if (!includeIndex) {
		//Calling the function on each array element + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			if (method_call(func, params)) {
				array_delete(array, i, 1);
			}
		}		
	}
	else {
		//Calling the function on each array element + index + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			params[1] = i;
			if (method_call(func, params)) {
				array_delete(array, i, 1);
			}
		}		
	}
}

/** Returns `true` if all elements in the specified array returns `true` to the given predicate function. The function takes a value from the array as its 
 * first argument. Additional arguments can be passed to the function using the `args` array. Optionally include the current index with `includeIndex`.
 * @arg {Array<Any>} array The array to iterate through
 * @arg {Function} func The function to execute on each array element. Must take the current array element as its first argument. If `includeIndex` is set to `true`, then the function must accept the current array index as its second argument. 
 * @arg {Array<Any>} [args] [`=undefined]` Optional array of additional arguments to pass to `func` after passing the current value.
 * @arg {Bool} [includeIndex] `[=false]` Set to true if your passed in function takes the current element index as its second argument.
 * @return {Undefined} */
function ArrayForAllElements(array, func, args = undefined, includeIndex = false) {
	//Setup the parameters array to pass to the callback
	var params = array_create(1 + includeIndex);
	params = array_concat(params, args ?? []);
	
	var len = array_length(array);
	if (!includeIndex) {
		//Calling the function on each array element + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			if (!method_call(func, params)) {
				return false;
			}
		}		
	}
	else {
		//Calling the function on each array element + index + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			params[1] = i;
			if (!method_call(func, params)) {
				return false;
			}
		}		
	}
	return true;
}

/** Returns `true` if any elements in the specified array returns `true` to the given predicate function. The function takes a value from the array as its 
 * first argument. Additional arguments can be passed to the function using the `args` array. Optionally include the current index with `includeIndex`.
 * @arg {Array<Any>} array The array to iterate through
 * @arg {Function} func The function to execute on each array element. Must take the current array element as its first argument. If `includeIndex` is set to `true`, then the function must accept the current array index as its second argument. 
 * @arg {Array<Any>} [args] `[=undefined]` Optional array of additional arguments to pass to `func` after passing the current value.
 * @arg {Bool} [includeIndex] `[=false]` Set to true if your passed in function takes the current element index as its second argument.
 * @return {Undefined} */
function ArrayForAnyElements(array, func, args = undefined, includeIndex = false) {
	//Setup the parameters array to pass to the callback
	var params = array_create(1 + includeIndex);
	params = array_concat(params, args ?? []);
	
	var len = array_length(array);
	if (!includeIndex) {
		//Calling the function on each array element + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			if (method_call(func, params)) {
				return true;
			}
		}		
	}
	else {
		//Calling the function on each array element + index + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			params[1] = i;
			if (method_call(func, params)) {
				return true;
			}
		}		
	}
	return false;
}

/** Executes the specified function on each element in the array. The function takes a value from the array as its first argument. Additional 
 * arguments can be passed to the function using the `args` array. Optionally include the current index with `includeIndex`.
 * @arg {Array<Any>} array The array to iterate through
 * @arg {Function} func The function to execute on each array element. Must take the current array element as its first argument. If `includeIndex` is set to `true`, then the function must accept the current array index as its second argument. 
 * @arg {Array<Any>} [args] [`=undefined`] Optional array of additional arguments to pass to `func` after passing the current value.
 * @arg {Bool} [includeIndex] `[=false]` Set to true if your passed in function takes the current element index as its second argument.
 * @return {Undefined} */
function ArrayForEachElement(array, func, args = undefined, includeIndex = false) {
	//Setup the parameters array to pass to the callback
	var params = array_create(1 + includeIndex);
	params = array_concat(params, args ?? []);
	
	var len = array_length(array);
	if (!includeIndex) {
		//Calling the function on each array element + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			method_call(func, params);
		}		
	}
	else {
		//Calling the function on each array element + index + args
		for (var i = 0; i < len; i++) {
			params[0] = array[i];
			params[1] = i;
			method_call(func, params);
		}		
	}
}

/** Returns `true` if the argument array is empty. Returns `false` in all other situations
 * @arg {Array<Any>} array
 * @return {Bool} */
function ArrayIsEmpty(array) {
	return (array_length(array) <= 0);
}

/** Returns true if all index values provided are within bounds of the specified array
 * @arg {Array<Any>} array The array to check
 * @arg {Array<Real>} indexGroup An Array of index values to check
 * @return {Bool} */
function ArrayIsGroupIndexInBounds(array, indexGroup) {
	var i = 0; repeat(array_length(indexGroup)) {
		if (!ArrayIsIndexInBounds(array, indexGroup[i++])) {
			return false;
		}
	}
	return true;
}

/**Returns true if the provided index is a valid array index or false if the index is out of bounds.
 * @arg {Array<Any>} array The array to check
 * @arg {Real} _index The index to check
 * @return {Bool} */
function ArrayIsIndexInBounds(array, _index) {
	if (!is_array(array) || !is_numeric(_index)) {
		return false;
	}		
	
	//Return if the array is between 0 and its length
	return (max(_index, 0) < array_length(array));
}


/** Adds a value to the end of the specified array but only if the array doesn't already have the value. Returns `true` if the value was added.
 * @arg {Array<Any>} array
 * @arg {Any} value
 * @return {Bool} */
function ArrayPushUnique(array, value) {
	if (!array_contains(array, value)) {
		array_push(array, value);
		return true;
	}
	return false;
}

/** Find and remove the first copy of a value from the array. Returns `true` if the value was found and removed or `false` if the value isn't found.
 * @arg {Array<Any>} array The array to remove the value from 
 * @arg {Any} value The value to find and remove.
 * @return {Bool} */ 
function ArrayRemove(array, value) {
	var _index = array_get_index(array, value);
	if (_index >= 0) {
		array_delete(array, _index, 1);
		return true;
	}
	return false;
}

/** Removes the indicated array index. Optionally, set the index value to `undefined`. Returns `true` if the element was successfully removed and `false` if it wasn't
 * @arg {Array<Any>} array The Array to drop an index from.
 * @arg {Real} _index The index of the array to drop.
 * @arg {Bool} _preserve_size Set true to preserve the array's size by setting the value at `_index` to `undefined` instead of removing it.
 * @return {Bool} */
function ArrayRemoveByIndex(array, _index, _preserve_size) {
	//Check if array size should be preserved
	if (_preserve_size) {
		array[_index] = undefined;
	} 
	
	else {
		array_delete(array, _index, 1);
	}
	return true;
}

/** Removes all elements from the target array that are not common to the source array. Also removes duplicates.
 * @arg {Array<Any>} sourceArray The array containing the source values
 * @arg {Array<Any>} targetArray The array to populate.
 * @return {Array<Any>} */
function ArrayRemoveIntersection(sourceArray, targetArray) {
	var _intersection = array_intersection(sourceArray, targetArray);
	var _count = array_length(_intersection);
	array_resize(targetArray, _count);
	array_copy(targetArray, 0, _intersection, 0, _count);
	return targetArray;
}

/** Resizes an existing array. Optionally provide values to insert into the array if used to grow the original array size
 * @arg {Array<Any>} array The array to resize
 * @arg {Real} _newSize The new size of the array
 * @arg {Any} [_padding] Optional value to insert into empty array elements if growing the array size. Defaults to `undefined`
 * @return {Undefined} */
function ArrayResizePadded(array, _newSize, _padding = undefined) {
	_newSize = max(_newSize, 0);
	var _len = array_length(array);
	
	if (_newSize != _len) {
		array_resize(array, max(0, _newSize));
		
		if (_newSize > _len) {
			while (_len < _newSize) {
				array[_len++] = _padding;
			}
		}
	}
}	

/** Sort an array of `ISortable` objects in ascending order
 * @arg {Array<Struct.ISortable>} array The array to sort.
 * @return {Undefined} */
function ArraySortAscendingOrder(array) {
	/** Helper to sort by ascending order
	 * @ignore
	 * @arg {Struct.ISortable} _a
	 * @arg {Struct.ISortable} _b
	 * @return {Real} */
	static sort = function(_a, _b) {
		return _a.GetElementOrder() - _b.GetElementOrder();
	}
	
	array_sort(array, sort);
}

/** Sort an array of `ISortable` objects in descending order
 * @arg {Array<Struct.ISortable>} array The array to sort.
 * @return {Undefined} */
function ArraySortDescendingOrder(array) {
	/** Helper to sort by descending order
	 * @ignore
	 * @arg {Struct.ISortable} _a
	 * @arg {Struct.ISortable} _b
	 * @return {Real} */
	static sort = function(_a, _b) {
		return _b.GetElementOrder() - _a.GetElementOrder();
	}
	
	array_sort(array, sort);
}

/** Attempts to returns the value from the specified array at the specified index. If a value cannot be returned, the specified default value is returned instead.
 * @arg {Array<Any>} array The array to get a value from
 * @arg {Real} _index The index to return the value of
 * @arg {Any} [_default] `[=undefined]` The value to return if no element exists at the specified `_index`. 
 * @return {Any} */
function ArrayTryGetElement(array, _index, _default = undefined) {
	if (ArrayIsIndexInBounds(array, _index)) {
		return array[_index];
	}
	return _default;
}