//feather ignore all
 
/** TestSuite for all classes/functions associated with the Attributes module
 * @return {Struct.AttributeTestSuite} */
function AttributeTestSuite() : TestSuite() constructor {
	
	
	#region AttributeData
		
		AddFact("AttributeData GetBaseValue", function() {
			var data = new AttributeData(1);
			var value = data.GetBaseValue();
			AssertEquals(value, 1, "Base Value should have been initialized to 1");
		})
		
		
		AddFact("AttributeData GetCurrentValue", function() {
			var data = new AttributeData(1);
			var value = data.GetCurrentValue();
			AssertEquals(value, 1, "Current Value should have been initialized to 1");
		})
		
		
		AddFact("AttributeData SetBaseValue", function() {
			var data = new AttributeData();
			data.SetBaseValue(1);
			var value = data.GetBaseValue();
			AssertEquals(value, 1, "Base Value should have been set to 1");			
		})
		
		
		AddFact("AttributeData SetCurrentValue", function() {
			var data = new AttributeData();
			data.SetCurrentValue(1);
			var value = data.GetCurrentValue();
			AssertEquals(value, 1, "Current Value should have been set to 1");			
		})
		
		
	#endregion
	
	
	#region Attribute
		
		AddFact("Attribute GetAttributeData", function() {
			var set = new AttributeSetDemo();
			var attribute = new Attribute("hp", AttributeSetDemo);
			var data = attribute.GetAttributeData(set);
			AssertIsInstanceOf(data, AttributeData, "Should have returned AttributeData");
		})
		
		
		AddFact("Attribute GetValue", function() {
			var set = new AttributeSetDemo();
			var attribute = new Attribute("hp", AttributeSetDemo);
			var value = attribute.GetValue(set);
			AssertEquals(value, 10, "Demo attribute set initializes hp to 10.");		
		})
		
		
		AddFact("Attribute SetValue", function() {
			var set = new AttributeSetDemo();
			var attribute = new Attribute("hp", AttributeSetDemo);
			attribute.SetValue(set, 20);
			var value = attribute.GetValue(set);
			AssertEquals(value, 20, "Hp should have been set to 20.");				
		})
		
	#endregion
	
	
	#region AttributeSet
		
		AddFact("AttributeSet GetOwningAbilitySystemComponent", function() {
			var data = new AttributeSet();
			var asc = data.GetOwningAbilitySystemComponent();
			AssertIsUndefined(asc, "Should return undefined because the ASC was never set.");
		})
		
	#endregion
	
}