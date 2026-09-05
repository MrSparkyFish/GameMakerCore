//feather ignore all

/** ExampleStateChart: An example of what a concrete StateChart looks like. This class is also used for `StateMachineTestSuite` unit tests.
 * @return {Struct.ExampleStateChart} */
function ExampleStateChart() : StateChart("Test1") constructor {
	SetName(instanceof(self));
	
	//Note: It is recommended that states be defined using the var keyword to prevent creating duplicate references to the same state definition
	//Additionally, StateMachines should be instantiated as a singleton since they're data objects only. 
	
	#region Defining the first root State; "Test1"
		
		//Setting up our first root state. This is also the initial state of the machine as we indicated prevously.
		var test1 = AddState(new State("Test1"), true);//This is a top-level root state so we set the 2nd argument to true
		
		//Lets add a basic task to state test1.
		var task = new Task("Task1");
		
		//Since we're using an abstract task, we're redefining its execution method just for this example. 
		//Ordinarily, this execute method will instantiate a task runner to execute the async logic
		task.Execute = function() {
			show_debug_message("Instantiating a concrete `ITaskRunner`");
		}
		test1.GetTasks().Add(task);
		
		//Since this state will have substates we should indicate which substate we want to enter first.
		test1.SetFirst("Test1Sub1");
		
		//Here we bind a function to the `Action` delegate that gets executed everytime "Test1" becomes the active state (and before any substates are entered).
		test1.GetOnEnter().Bind(function() {
			show_debug_message("Entered State 'Test1'");
		});
		
		//Here we bind a function to the `Action` delegate that gets executed everytime "Test1" stops being the active state (and after any substates are exited).
		test1.GetOnExit().Bind(function() {
			show_debug_message("Exited State 'Test1'");
		});
		
		
		
		//SUBSTATE 1//
		//Defining our first substate of root state Test1.
		var test1Sub1 = AddState(new State("Test1Sub1"));//Substates also need to be added to the machine. This is a substate of another state, so we ignore the second argument.
		
		//Don't forget to add the substate as child of the parent using the correct `AddChild()` method. Do Not Use `SetParent()`.
		var es = test1Sub1;//Avoid automatic type casting
		test1.AddChild(es);	
		
		
		test1Sub1.DefineEvents({
			"Event.Test.Definition" : function() {
				show_debug_message("Executing Defined Event for state Test1Sub1");
			}
		})		
		
		
		//Set up our entry method. This is executed after our parent's (Test1) entry method
		test1Sub1.GetOnEnter().Bind(function() {
			show_debug_message("Entered State 'Test1Sub1'");
		});
		
		//Set up our exit method. This is executed before our parent's (Test1) exit method
		test1Sub1.GetOnExit().Bind(function() {
			show_debug_message("Exited State 'Test1Sub1'");
		});
		
		//Set up an event for (11 = test1, sub1) that this sub state can respond to. When the event is fired, we should transition to substate 2.
		var transition11 = new StateTransition("Test1Sub2");
		transition11.SetEvent(Tag_RequestTag("Event.Test.1"));//This isn't an eventless transition, so specify the event tag that triggers it. 
		
		//Add the transition to the substate
		test1Sub1.AddTransition(transition11);
		
		
		//SUBSTATE 2//
		//This state is a final state, so "Test1" is done when we get here.
		var test1Sub2 = new FinalState("Test1Sub2");
		AddFinal(test1Sub2); //Add to the machine
		
		test1Sub2.GetOnEnter().Bind(function() {
			show_debug_message("Entered FinalState 'Test1Sub2'");
		});
		
		test1Sub2.GetOnExit().Bind(function() {
			show_debug_message("Exited FinalState 'Test1Sub2'");
		});
		
		//Add our 2nd substate to the root state
		var esFinal = test1Sub2;//New var to avoid auto typecasting.
		test1.AddChild(esFinal);
		
		//When reaching a final state, the event "Event.Done.State.[parentId]" is automatically generated, so we can define this event now and add it to our parent state (state "Test1").
		var transition1Done = new StateTransition("Test2");//After event "Event.Done.State.Test1" is resolved, we transition to state "Test2".
		transition1Done.SetEvent(Tag_RequestTag("Event.Done.State.Test1"));
		transition1Done.GetOnTransition().Bind(function(){
			show_debug_message("Transition Taken for event 'Event.Done.State.Test1'")
		})
		
		//Add the transition to the parent of the final state so the parent can react to it.
		test1.AddTransition(transition1Done);
		
	#endregion
	
	
	#region Setting up root state 2; "Test2"
		
		var test2 = AddState(new State("Test2"), true);//This is a root machine state
		
		//Here, we use the other method for indicating initial state which is more convenient when you don't need to bind a callback.
		//For simplicity, we'll stick to this method for the rest of the document.
		test2.SetFirst("Test2Sub1");
		
		
		test2.GetOnEnter().Bind(function() {
			show_debug_message("Entered State 'Test2'");
		});
		
		test2.GetOnExit().Bind(function() {
			show_debug_message("Exited State 'Test2'");
		});
		
		//SUBSTATE 1//
		//Substate 1 is a final state, which means state "Test2" will be finished when we reach it
		var test2Sub1 = new FinalState("Test2Sub1");
		
		test2Sub1.GetOnEnter().Bind(function() {
			show_debug_message("Entered FinalState 'Test2Sub1'");
		});
		
		test2Sub1.GetOnExit().Bind(function() {
			show_debug_message("Exited FinalState 'Test2Sub1'");
		});
		
		//Once again, set up a transition for the final state's done event in our root
		var transition2Done = new StateTransition("Test3");
		transition2Done.SetEvent(Tag_RequestTag("Event.Done.State.Test2"));
		test2.AddTransition(transition2Done);
		
		transition2Done.GetOnTransition().Bind(function() {
			show_debug_message("Transition Taken for event 'Event.Done.State.Test2'");
		});
		
		//Add our substate to the parent and to the machine
		var esFinal1 = test2Sub1;
		test2.AddChild(esFinal1);
		AddFinal(test2Sub1);
		
	#endregion
	
	
	#region Setting up root state 3; "Test3"
		
		var test3 = AddState(new State("Test3"), true);//This is a root machine state
		test3.SetFirst("Test3Sub1");
		
		
		test3.GetOnEnter().Bind(function() {
			show_debug_message("Entered State 'Test3'");
		});
		
		test3.GetOnExit().Bind(function() {
			show_debug_message("Exited State 'Test3'");
		})
		
		
		//SUBSTATE 1//
		var test3Sub1 = new State("Test3Sub1");
		test3Sub1.GetOnEnter().Bind(function() {
			show_debug_message("Entered State 'Test3Sub1'");
		});
		test3Sub1.GetOnExit().Bind(function() {
			show_debug_message("Exited State 'Test3Sub1'");
		});
		
		//This transition will exit both the substate and it's parent root state. 
		//This is because it's targeting a root state that's different from the current root state.
		var transition31 = new StateTransition("Test4");
		transition31.GetOnTransition().Bind(function() {
			show_debug_message("Eventless Transition Taken from State 'Test3Sub1'");
		});
		
		transition31.SetEvent(Tag_RequestTag("Event.Test.Continue"));
		
		//Add the transition to the substate
		test3Sub1.AddTransition(transition31);
		
		//Add the substate to the root state and to the machine
		var es31 = test3Sub1;
		test3.AddChild(es31);
		AddState(test3Sub1);
		
	#endregion
	
	
	#region Setting up root state 4; "Test4"
		
		var test4 = AddState(new State("Test4"), true);//This is a root machine state
		test4.SetFirst("Test4Sub1");
		
		
		//Set up an on enter only
		test4.GetOnEnter().Bind(function() {
			show_debug_message("Entered State 'Test4'");
		});
		
		test4.GetOnExit().Bind(function() {
			show_debug_message("Exited State 'Test4'");
		});
		
		//SUBSTATE 1//
		var test4Sub1 = AddState(new State("Test4Sub1"));
		
		//Set up an onEnter method
		test4Sub1.GetOnEnter().Bind(function() {
			show_debug_message("Entered State 'Test4Sub1'");
		});
		
		test4Sub1.GetOnExit().Bind(function() {
			show_debug_message("Exited State 'Test4Sub1'");
		});
		
		//This transition is "eventless" since we do not set a triggering event (we don't call `SetEvent`), 
		//Since this transition is eventless AND it doesn't have a guard condition, it is always active and will always be taken when the state is entered.
		var transition41 = new StateTransition("Test5");
		transition41.GetOnTransition().Bind(function() {
			show_debug_message("Eventless Transition Taken from State 'Test4Sub1'");
		});
		
		//Add the transition to the substate
		test4Sub1.AddTransition(transition41);
		
		//Add the substate as a child
		var es41 = test4Sub1;
		test4.AddChild(es41);
		
		
	#endregion
	
	
	#region Setting up root state 5; "Test5"
		
		var test5 = AddState(new State("Test5"), true);//This is a root machine state
		test5.SetFirst("Test5P");
		
		//OnEnter for test5
		test5.GetOnEnter().Bind(function() {
			show_debug_message("Entered State 'Test5'");
		});
		
		test5.GetOnExit().Bind(function() {
			show_debug_message("Exited State 'Test5'");
		});
		
		var test5Transition = new StateTransition("Finished");
		test5Transition.SetEvent("Event.Done.State.Test5P");
		test5.AddTransition(test5Transition);
		
		
		
		//History State Setup//
		var ts = test5
		var test5History = AddHistory(new HistoryState("Test5History", ts));//Add the history to the machine so it can be targeted by transitions. History states require a parent state
		
		
		//We want a deep history since so that we can record our parallel substate too.
		test5History.SetDeepHistory();
		
		
		
		#region Setting up parent state 5P
			//This substate is a parallel state meaning all its substates will be active at the same time. 
			//It also acts as a root state.
			var test5P = AddParallel(new ParallelState("Test5P"));//This is a parent state, not a machine root state so we still ignore the second arg.
			
			test5P.GetOnEnter().Bind(function() {
				show_debug_message("Entered ParallelState 'Test5P'");
			});
			
			test5P.GetOnExit().Bind(function() {
				show_debug_message("All regions have finished. Exiting ParallelState 'Test5P'");
			});
			
			//Add as a child to the previous root
			var es5P = test5P;
			test5.AddChild(es5P);
			
			
			#region Setting up substate 1 as another parent substate
				
				//First region child of test5Sub1 parallel state which is also a parent state itself 
				var test5PSub1 = AddState(new State("Test5PSub1"));//This is a parent state, not a machine root state so we still ignore the second arg.
				test5PSub1.SetFirst("Test5PSub1Final");
				
				test5PSub1.GetOnEnter().Bind(function() {
					show_debug_message("Entered State region 'Test5PSub1' of ParallelState 'Test5P'");
				});
				
				//Add the new root as a child of the previous root
				var es5PSub1 = test5PSub1;
				test5P.AddChild(es5PSub1);
				
				
				
				//SUBSTATE 1//
				//Can continue chaining more State and ParalleState but for simplicity, just ending with a FinalState
				var test5PSub1Final = AddFinal(new FinalState("Test5PSub1Final"));
				
				test5PSub1Final.GetOnEnter().Bind(function() {
					show_debug_message("Entered FinalState 'Test5PSub1Final'");
				});
				
				//Add it as a child to the previous root
				var es5PFinal1 = test5PSub1Final;
				test5PSub1.AddChild(es5PFinal1);
				
				
			#endregion
			
			
			#region Setting up substate 2 as another parent substate
				
				var test5PSub2 = AddState(new State("Test5PSub2"));//This is a parent state, not a machine root state so we still ignore the second arg.
				test5PSub2.SetFirst("Test5PSub2Final");
				
				test5PSub2.GetOnEnter().Bind(function() {
					show_debug_message("Entered State region 'Test5PSub2' of ParallelState 'Test5P'");
				});
				
				test5PSub2.GetOnExit().Bind(function() {
					show_debug_message("Exited State region 'Test5PSub2' of ParallelState 'Test5P'");
				});
				
				//Add the new parent as a child of the previous parent
				var es5PSub2 = test5PSub2;
				test5P.AddChild(es5PSub2);
				
				
				
				//SUBSTATE 1//
				//Can continue chaining more State and ParalleState but for simplicity, just ending with a FinalState
				var test5PSub2Final = AddFinal(new FinalState("Test5PSub2Final"));	//Still needs to be added to the machine
				
				test5PSub2Final.GetOnEnter().Bind(function() {
					show_debug_message("Entered FinalState 'Test5PSub2Final2'");
				});
				test5PSub2Final.GetOnExit().Bind(function() {
					show_debug_message("Exited FinalState 'Test5PSub2Final2'");
				});
				
				//Add it as a child to the previous root
				var es5PFinal2 = test5PSub2Final;
				test5PSub2.AddChild(es5PFinal2);
				
			#endregion
			
		#endregion
		
	#endregion
	
	
	#region Finished state of the machine.
		
		var finished = new FinalState("Finished");
		finished.GetOnEnter().Bind(function() {
			show_debug_message("Entered Top-Level final state. Machine stopping.");
		});
		AddFinal(finished);
		
	#endregion
}







