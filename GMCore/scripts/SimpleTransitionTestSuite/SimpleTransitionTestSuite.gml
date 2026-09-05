//feather ignore all
 
/** SimpleTransitionTestSuite: SimpleTransition Unit Tests
 * @return {Struct.SimpleTransitionTestSuite} */
function SimpleTransitionTestSuite() : TestSuite() constructor {
	
	
	AddFact("SimpleTransition: IsTypeInternal 1", function() {
		var transition = new SimpleTransition();
		transition.SetType(State_TransitionType.internal);
		AssertIsFalse(transition.IsTypeInternal(), "SimpleTransition should not be internal since only 1 of 3 criteria is met!");
	});
	
	AddFact("SimpleTransition: IsTypeInternal 2", function() {
		var transition = new SimpleTransition();
		transition.SetParent(new State());
		transition.SetType(State_TransitionType.internal);
		AssertIsFalse(transition.IsTypeInternal(), "SimpleTransition should not be internal since only 2 of 3 criteria is met!");
	});
	
	AddFact("SimpleTransition: IsTypeInternal 3", function() {
		var transition = new SimpleTransition();
		transition.SetParent(new ParallelState());
		transition.SetType(State_TransitionType.internal);
		AssertIsFalse(transition.IsTypeInternal(), "SimpleTransition should not be internal since parallel states are not atomic");		
	});
	
	AddFact("SimpleTransition: IsTypeInternal 4", function() {
		var transition = new SimpleTransition();
		var state = new State("State");
		var child = new State("Child");
		state.AddChild(child);
		transition.SetParent(state);
		array_push(transition.GetTargets(), child);
		transition.SetType(State_TransitionType.internal);
		AssertIsTrue(transition.IsTypeInternal(), "SimpleTransition should be internal as all conditions are met");		
	});
	
	
	AddFact("SimpleTransition: GetTransitionDomain 1", function() {
		var transition = new SimpleTransition();
		AssertIsUndefined(transition.GetTransitionDomain(), "Domain should be undefined since the transition is target-less"); 
	});
	
	
	AddFact("SimpleTransition: GetTransitionDomain 2", function() {
		var transition = new SimpleTransition();
		transition.SetParent(new State());
		AssertIsUndefined(transition.GetTransitionDomain(), "Domain should be undefined since we're at machine level"); 
	});
	
	AddFact("SimpleTransition: GetTransitionDomain 3", function() {
		var transition = new SimpleTransition();
		var state = new State("State");
		var child = new State("Child");		
		var child2 = new State("Child2");
		state.AddChild(child);
		child.AddChild(child2);
		array_push(transition.GetTargets(), child2);
		transition.SetParent(child);
		AssertIsTrue(transition.GetTransitionDomain() == state, "Domain should be the upper parent since we're targeting a child state"); 
	});
}