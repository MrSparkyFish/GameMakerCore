//Feather ignore all

/** StateMachineTestSuite: Functional testing of the StateMachine system.
 * @ignore
 * @return {Struct.StateMachineTestSuite} */
function StateMachineTestSuite() : TestSuite() constructor {
	StateSetChart(new ExampleStateChart(), "ExampleStateMachine");
	config = {printPolicy : TestPrintPolicy.never};
	
	AddFact("Attempt State Event", function() {
		var fsm = new StateMachine(StateGetChart("ExampleStateMachine"));
		
		fsm.TriggerEvent("Event.Test.Definition");
		
		AssertIsTrue(fsm.GetEventProcessor().IsStateActive("Test1Sub1"), "Triggering a non-transitional event should not change the active state configuration")
	}, config);	
	
	AddFact("Attempt Transitioning Event", function() {
		var fsm = new StateMachine(StateGetChart("ExampleStateMachine"));
		
		fsm.TriggerEvent("Event.Test.1");//Takes us to Test3Sub1
		
		AssertIsTrue(fsm.GetEventProcessor().IsStateActive("Test3Sub1"), "Triggering a transitional event should change the active state configuration");
	}, config);	
	
	AddFact("Attempt Transition Machine to a Top-Level Final State", function() {
		var fsm = new StateMachine(StateGetChart("ExampleStateMachine"));
		
		fsm.TriggerEvent("Event.Test.1");			//Takes us to Test3Sub1
		fsm.TriggerEvent("Event.Test.Continue");	//Takes us to Toplevel final state and ends machine processing
		
		AssertIsFalse(fsm.GetEventProcessor().IsRunning(), "The machine should have entered a top level final state and stopped running");		
	}, config);
}