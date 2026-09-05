#macro FRAMEWORK_SHOULD_CATCH 				false
#macro FRAMEWORK_END_GAME_ON_FINISH			false

show_debug_message($"Test Environment Launched{STRING_LINEBREAK}");
show_debug_log(true);

//Test settings
Config_SetConfig("Test", {
	printPolicy: TestPrintPolicy.fail,
});

//TestGroup settings
Config_SetConfig("TestGroup", {
	bailOnFail : false,
	printPolicy : TestPrintPolicy.never,
	passBag : false,
});

//Framework settings
Config_SetConfig("TestFramework", {
	startHook : function() {
		show_debug_message("Beginning Unit Tests");
	},
	
	endHook : function() {
		var message = "xUnit Framework Run Complete."
		if (FRAMEWORK_END_GAME_ON_FINISH) {
			message += " Ending Game.";
		}
		show_debug_message(message);
	}
});

framework = new TestFramework("Unit Test"); 
frameworkRunning = false;

//Add TestSuites like so -> framework.AddTestSuite(Constructor)

//Masks
framework.AddTestSuite(BitMaskTestSuite);

//GC
framework.AddTestSuite(DynamicGarbageCollectionTestSuite);

//Tags
framework.AddTestSuite(TagTestSuite);

//State Machine
framework.AddTestSuite(SimpleTransitionTestSuite);
framework.AddTestSuite(StateMachineTestSuite);

//Vectors
framework.AddTestSuite(Vector2TestSuite);
framework.AddTestSuite(Vector3TestSuite); 
framework.AddTestSuite(Vector4TestSuite); 
framework.AddTestSuite(QuaternionTestSuite);

//PubSub
//framework.AddTestSuite(PubSubTestSuite); -> No tests currently in this suite


//Input
//framework.AddTestSuite(InputTestSuite); -> No tests currently in this suite.

//Ability System
framework.AddTestSuite(AttributeTestSuite);







if (autoStartTest) {
	frameworkRunning = true;
	framework.StartTest();
}

//Additional test objects
if (createAdditionalObjects) {
	instance_create_depth(0,0,0, oAbilitySystemDemo);
}