//feather ignore all

/** Removes all member variables from the specified struct. Only recommended for anon structs.
 * @arg {Struct} _struct The struct to remove all members from
 * @return {Undefined} */
function StructClear(_struct) {
	with(_struct) {
		struct_foreach(self, function(name) {
			struct_remove(self, name);
		});
	}
}

/** Returns `true` if the specified `structToCheck` holds the equivalent values as `structToCompare`
 * @arg {Struct} structToCheck
 * @arg {Struct} structToCompare
 * @return {Bool} */
function StructEqualsStruct(structToCheck, structToCompare) {
	//Helper func
	///@ignore
	static structEquals = function(a, b) {
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
	
	// Fail if sizes mismatch
	var _size = struct_names_count(structToCheck);
	if (_size != struct_names_count(structToCompare)) {
		return false;
	}
	
	// Loop through all the struct elements
	var _names = struct_get_names(structToCompare);
	for (var i = 0, name; i < _size; i++) {
		name = _names[i];
		if (!structEquals(structToCheck[$ name], structToCompare[$ name])) {
			return false;
		}
	}
	return true;
}

/** Returns `true` if the specified structs are both instances of the same class
 * @arg {Struct} a
 * @arg {Struct} b
 * @return {Bool} */
function StructEqualsStructClass(a, b) {
	return (instanceof(a) == instanceof(b));
}

/** Returns `true` if all members of the specified struct returns `true` to the given predicate function. The function takes a value from the struct as its 
 * first argument. Additional arguments can be passed to the function using the `args` array. Optionally include the current index with `includeName`.
 * @arg {Struct} struct The array to iterate through
 * @arg {Function} func The function to execute on each member. Must take the current struct member as its first argument. If `includeName` is set to `true`, then the function must accept the member name as its second argument. 
 * @arg {Array<Any>} [args] Optional array of additional arguments to pass to `func` after passing the current value.
 * @arg {Bool} [includeName] `[=false]` Set to true if your passed in function takes the member name as its second argument.
 * @return {Undefined} */
function StructForAllMembers(struct, func, args = undefined, includeName = false) {
	var params = [];
	var names = struct_get_names(struct);
	var len = array_length(names);
	if (!includeName) {
		//Setup params to only insert 1 arg
		if (is_array(args)) {
			params = array_copy(params, 1, args, 0, array_length(args));
		}	
		for (var i = 0; i < len; i++) {
			params[0] = struct[$ names[i]];
			if (!method_call(func, params)) {
				return false;
			}
		}		
	}
	else {
		//Setup params to insert 2 args
		if (is_array(args)) {
			params = array_copy(params, 2, args, 0, array_length(args));
		}	
		for (var i = 0; i < len; i++) {
			params[0] = struct[$ names[i]];
			params[1] = names[i];
			if (!method_call(func, params)) {
				return false;
			}
		}		
	}
	return true;
}

/** Returns `true` if any member in the specified struct returns `true` to the given predicate function. The function takes a value from the struct as its 
 * first argument. Additional arguments can be passed to the function using the `args` array. Optionally include the current index with `includeName`.
 * @arg {Struct} struct The array to iterate through
 * @arg {Function} func The function to execute on each member. Must take the current struct member as its first argument. If `includeName` is set to `true`, then the function must accept the member name as its second argument. 
 * @arg {Array<Any>} [args] Optional array of additional arguments to pass to `func` after passing the current value.
 * @arg {Bool} [includeName] `[=false]` Set to true if your passed in function takes the member name as its second argument.
 * @return {Undefined} */
function StructForAnyMembers(struct, func, args = undefined, includeName = false) {
	var params = [];
	var names = struct_get_names(struct);
	var len = array_length(names);
	if (!includeName) {
		//Setup params to only insert 1 arg
		if (is_array(args)) {
			params = array_copy(params, 1, args, 0, array_length(args));
		}	
		for (var i = 0; i < len; i++) {
			params[0] = struct[$ names[i]];
			if (method_call(func, params)) {
				return true;
			}
		}		
	}
	else {
		//Setup params to insert 2 args
		if (is_array(args)) {
			params = array_copy(params, 2, args, 0, array_length(args));
		}	
		for (var i = 0; i < len; i++) {
			params[0] = struct[$ names[i]];
			params[1] = names[i];
			if (method_call(func, params)) {
				return true;
			}
		}		
	}
	return false;
}

/** Executes the specified function on each member in the struct. The function takes a member value as its first argument. Additional 
 * arguments can be passed to the function using the `args` array. Optionally include the member name with `includeName`.
 * @arg {Struct} struct The struct to iterate through
 * @arg {Function} func The function to execute on each struct member. Must take the current member value as its first argument. If `includeName` is set to `true`, then the function must accept the member name as its second argument. 
 * @arg {Array<Any>} [args] Optional array of additional arguments to pass to `func` after passing the current value. If no additional arguments are required, it is recommended to use `struct_foreach()` instead of this function.
 * @arg {Bool} [includeName] `[=false]` Set to true if your passed in function takes the member name as its second argument.
 * @return {Undefined} */
function StructForEachMember(struct, func, args = undefined, includeName = false) {
	var params = [];
	var names = struct_get_names(struct);
	var len = array_length(names);
	if (!includeName) {
		//Setup params to only insert 1 arg
		if (is_array(args)) {
			params = array_copy(params, 1, args, 0, array_length(args));
		}	
		for (var i = 0; i < len; i++) {
			params[0] = struct[$ names[i]];
			method_call(func, params);
		}		
	}
	else {
		//Setup params to insert 2 args
		if (is_array(args)) {
			params = array_copy(params, 2, args, 0, array_length(args));
		}	
		for (var i = 0; i < len; i++) {
			params[0] = struct[$ names[i]];
			params[1] = names[i];
			method_call(func, params);
		}		
	}
}

/** Creates and returns a struct from a collection of key/value arrays.
 * @arg {Array<Array>} _array_2d An array with the format [ [key, value], [key2, value2]...]
 * @return {Struct} */
function StructFromArray2D(_array_2d) {
	var _output = {};
	var _count = array_length(_array_2d);
	
	//Loop through each nested array
	for (var i = 0; i < _count; i++) {
		//Use nest index 0 as the key, and nest index 1 as the value for the struct member
		_output[$ _array_2d[i][0]] = _array_2d[i][1];
	} 
	
	return _output;
}

/** Returns a reference to the constructor function that created the specified struct.
 * @arg {Struct} _struct The struct to get the constructor for
 * @return {Function} */
function StructGetConstructor(_struct) {
	var func = asset_get_index(instanceof(_struct));
	return (func == -1) ? StructLiteral : func;
}

/** Returns `true` if struct `a` is a descendant of the constructor that created struct `b`.
 * @arg {Struct} a
 * @arg {Struct} b
 * @return {Bool} */
function StructIsDescendantOfStruct(a, b) {
	return (is_instanceof(a, StructGetConstructor(b)));
}

/** Merges a source struct into a destination struct. Key/value pairs on the destination struct are overwritten by the source. 
 * ***
 * Its highly recommended that the `_destination` struct is the same struct type as the `_source` struct unless the `_source` struct 
 * is an anonymous struct. This is because static struct members are not merged, therefore the `_destination` struct will not retain 
 * the same type as the `_source` struct.
 * @arg {Struct} _source The struct whose members will be merged into another struct 
 * @arg {Struct} _destination The struct who will recieve the merged members
 * @arg {Bool} [_add] Whether or not the destination struct should include new members from the source struct. `[=true]`
 * @return {Undefined} */
function StructMerge(_source, _destination, _add = true) {
	
	var _names = struct_get_names(_source);
	var _count = array_length(_names);
	
	//Loop through all source members
	var i = 0; repeat(_count) {
		//Merge each source member into the destination struct if the destination 
		//has a member with that name, or if _add is true.
		var _name = _names[i++];
		if (struct_exists(_destination, _name) || _add) {
			_destination[$ _name] = _source[$ _name];
		}
	}
}

/** Merges the members of a source struct into a destination struct but if the member is unique to the destination.
 * ***
 * Its highly recommended that the `_destination` struct is the same struct type as the `_source` struct unless the `_source` struct 
 * is an anonymous struct. This is because static struct members are not merged, therefore the `_destination` struct will not retain 
 * the same type as the `_source` struct.
 * @arg {Struct} source The struct whose members will be merged into another struct 
 * @arg {Struct} destination The struct who will recieve the merged members
 * @return {Undefined} */
function StructMergeUnique(source, destination) {
	
	///@ignore
	static helper = {
		destination : destination,
		
		///@arg {String} memberName
		///@arg {Any} memberValue
		SetUnique : function(memberName, memberValue) {
			StructSetMemberUnique(helper.destination, memberName, memberValue);
		}
	};
	
	helper.destination = destination;
	struct_foreach(source, helper.SetUnique);
}

/** Sets the value of a struct member but only if the member is unique. Returns `true` if the member was successfully set/added, otherwise, returns `false`.
 * @arg {Struct} _struct The struct to set the unique member to.
 * @arg {Any} _key, The key of the member to set
 * @arg {Any} _value The value to assign
 * @return {Bool} */
function StructSetMemberUnique(_struct, _key, _value) {
	//Always add the key/value pair if it doesn't already exist.
	if (!struct_exists(_struct, _key)) {
		_struct[$ _key] = _value;
		return true;
	}
	return false;
}

/** Returns an array containg all member values found in the provided struct. The final order of values in the array is not guaranteed.
 * @arg {Struct} _struct The source struct used to populate the array
 * @return {Array<Any>} */
function StructToArray(_struct) {
	var results = [];
	var keys = struct_get_names(_struct);
	var len = array_length(keys);
	for (var i = 0; i < len; i++) {
		array_push(results, _struct[$ keys[i]]);
	}
	return results;
}

/** Returns an array containing the all members of the specified struct that satisfy the given predicate function
 * @arg {Struct} struct The struct to populate the array with
 * @arg {Function} func A predicate function to execute on each struct member. Must take the current member value as its first argument. If `includeName` is set to `true`, then the function must accept the member name as its second argument. 
 * @arg {Array<Any>} [args] Optional array of additional arguments to pass to `func` after passing the current value. If no additional arguments are required, it is recommended to use `struct_foreach()` instead of this function.
 * @arg {Bool} [includeName] `[=false]` Set to true if your passed in function takes the member name as its second argument.
 * @return {Undefined} */
function StructToArrayExt(struct, func, args = undefined, includeName = false) {
	var results = [];
	var params = [];
	var names = struct_get_names(struct);
	var len = array_length(names);
	if (!includeName) {
		//Setup params to only insert 1 arg
		if (is_array(args)) {
			params = array_copy(params, 1, args, 0, array_length(args));
		}	
		for (var i = 0; i < len; i++) {
			params[0] = struct[$ names[i]];
			if (method_call(func, params)) {
				array_push(results, params[0]);
			}
		}		
	}
	else {
		//Setup params to insert 2 args
		if (is_array(args)) {
			params = array_copy(params, 2, args, 0, array_length(args));
		}	
		for (var i = 0; i < len; i++) {
			params[0] = struct[$ names[i]];
			params[1] = names[i];
			if (method_call(func, params)) {
				array_push(results, params[0]);
			}
		}		
	}
}

/** Returns an array or popoulates an existing array with all the member values of the specified struct that satisfies the condition provided by the predicate
 * function. The predicate function should take 1 argument - `memberValue<Any>` - and return `bool`. The final order of values in the array is not guaranteed.
 * @arg {Struct} _struct The struct to convert to an array
 * @arg {Function} _func The predicate function representing the condition
 * @arg {Array<Any>} [_outArray] Optional array to mutate. 
 * @return {Array<Any>} */
function StructToFilteredArray(_struct, _func, _outArray = []) {
	//Get all key keys and setup values array
	var _value;
	var _keys = struct_get_names(_struct);
	
	//Assign the keys values to the new array
	var i = 0; repeat(array_length(_keys)) {
		_value = _struct[$ _keys[i++]];
		if (_func(_value)) {
			array_push(_outArray, _value);
		}
	}
	return _outArray;	
}

/** Checks a struct for a specific key and if one exists, the key's value is returned. Otherwise, returns the specified `_default` value.
 * @arg {Struct} _struct The struct to check
 * @arg {Any} _key The struct key to try to get the value from
 * @arg {Any} _default `[=undefined]` The value to return if the function fails
 * @return {Any} */
function StructTryGetMember(_struct, _key, _default = undefined) {
	if (struct_exists(_struct, _key)) {
		return _struct[$ _key];
	}
	return _default;
}

/** Attempts to remove the specified struct member. Returns `true` if successful. Otherwise returns `false`
 * @arg {Struct} _struct The struct to remove a member from
 * @arg {Any} _key The key of the member to remove
 * @return {Bool} */
function StructTryRemoveMember(_struct, _key) {
	//Use a try statement because struct_remove throws an error if it doesn't exist
	return (struct_exists(_struct, _key)) ? is_undefined(struct_remove(_struct, _key)) : false;
}

/** Converts each member of a struct into its own struct (flattened object to a nested object).
 * @arg {Struct} _struct The struct to unflatten
 * @return {Struct} */
function StructUnflatten(_struct) {
	var _result = {};
	var _keys = struct_get_names(_struct);
	var _keys_count = array_length(_keys);
	
	//Loop through all keys
	for (var i = 0; i < _keys_count; i++) {
		//Split each key into its respective parts
		var _key = _keys[i];							//whole key
		var _parts = string_split(_key, ".");			//key split into parts
		var _obj = _result;								//The first nest is sent to the _result struct
		var _parts_count = array_length(_parts) - 1;	//Number of nests to make
		
		
		//Loop through all parts of a key
		for (var j = 0; j < _parts_count; j++) {
			//Nest a new struct for each key part
			var _part = _parts[j];
			if (!struct_exists(_obj, _part)) {
				_obj[$ _part] = _struct[$ _part] ?? {};	
			}
			
			//Sets the last created nest as the struct that should receive a new nest 
			//or as the struct to be given a value if this is the last iteration of the loop
			_obj = _obj[$ _part];
		}
		
		
		//Set the value of the final nested struct
		var _nested_key = _parts[_parts_count];
		var _value = _struct[$ _key];
		_obj[$ _nested_key] = _value;
	}
	
	return _result;	
}	