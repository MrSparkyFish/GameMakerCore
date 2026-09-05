//feather ignore all
 
/** TaskContainer: Represents a collection of `Task` objects.
 * ***
 * Implements: `ICollection`
 * @return {Struct.TaskContainer} */
function TaskContainer() constructor {
	Implement(ICollection);
	
	///@ignore List of Tasks held by this container
	tasks = [];
	
	
	/** Ensure this container contains the specified task. Returns `true` if this container changed as a result of the call. Returns `false` if this container 
	 * does not permit duplicates and already contains the specified task.
	 * @arg {Struct.Task} _task The `Task` to add
	 * @return {Bool} */
	static Add = function(_task) {
		return ArrayPushUnique(tasks, _task);
	}
	
	/** Add all the tasks in the specified container into this container
	 * @arg {Struct.TaskContainer} _container The container to add
	 * @return {Undefined} */
	static AddAll = function(_container) {
		array_foreach(_container.tasks, Add);
	}
	
	/** Removes all tasks from this container.
	 * @return {Undefined} */
	static Clear = function() {
		ArrayClear(tasks);
	}
	
	/** Returns `true` if this container contains the specified task
	 * @arg {Struct.Task} _task The task to look for
	 * @return {Bool} */
	static Contains = function(_task) {
		return array_contains(tasks, _task);
	}
	
	/** Returns `true` if the specified container contains the same tasks of this container.
	 * @arg {Struct.TaskContainer} _container
	 * @return {Bool} */
	static Equals = function(_container) {
		return ArrayContainsAllValues(tasks, _container.tasks);
	}
	
	/** Returns `true` if this container has no tasks
	 * @return {Undefined} */
	static IsEmpty = function() {
		return ArrayIsEmpty(tasks);
	}
	
	/** Removes the specified task from this container. Returns `true` if the task was present and subsequently ended and removed.
	 * @arg {Struct.Task} _task The task to remove
	 * @return {Bool} */
	static Remove = function(_task) {
		ArrayRemove(tasks, _task);
	}
	
	/** Removes all the elements from the specified collection that are also in this collection
	 * @arg {Struct.TaskContainer} _container The container with tasks to remove
	 * @return {Undefined} */
	static RemoveAll = function(_container) {
		var otherTasks = _container.ToArray();
		var intersection = array_intersection(tasks, otherTasks);
		array_foreach(otherTasks, _container.Remove);
	}
	
	/** Keeps only the tasks of this container that are also in the specified container. All other tasks are removed.
	 * @arg {Struct.TaskContainer} _container The container to reference
	 * @return {Undefined} */
	static KeepIntersection = function(_container) {
		var keep = array_intersection(tasks, _container.ToArray());
		var len = array_length(tasks);
		for (var i = 0; i < len; i++) {
			if (!array_contains(keep, tasks[i])) {
				Remove(tasks[i]);
			}
		}
	}
	
	/** Returns the number of tasks in this container
	 * @return {Real} */
	static Count = function() {
		array_length(tasks);
	}
	
	/** Returns an array containing all the elements of this collection
	 * @return {Array<Struct.Task>} */
	static ToArray = function() {
		INLINE;
		return tasks;
	}	
}