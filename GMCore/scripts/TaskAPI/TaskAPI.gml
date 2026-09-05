//feather ignore all


#region Task
	
	/** Helper function to end the specified task. Useful with native funcs like `array_foreach`.
	 * @arg {Struct.Task} task The task to end
	 * @return {Undefined} */
	function Task_TaskEnded(task) {
		task.TaskEnded();
	}
	
#endregion