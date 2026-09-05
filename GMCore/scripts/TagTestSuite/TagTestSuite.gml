/** TagTestSuite: Runs unit tests for TagContainer and TagRequirements
 * @ignore
 * @return {Struct.TagTestSuite} */
function TagTestSuite() : TestSuite() constructor {
	
	AddFact("TagContainer::AddTag", function() {
		var _t = Tag_RequestTag("Tag.Example.Test");
		var tags = new TagContainer();
		tags.AddTag(_t);
		
		AssertArrayNotEmpty(tags.tags, "Tags should have been added");
	});
	
	AddFact("TagContainer::AppendTags #1", function() {
		var _t = Tag_RequestTag("Tag.Example.Test");
		var tags = new TagContainer();
		var container = new TagContainer();
		container.AddTag(_t);
		tags.AppendTags(container);
		
		AssertArrayNotEmpty(tags.tags, "Tags should have been added from the container");
	});
	
	AddFact("TagContainer::AddTagFromContainer #2", function() {
		var _t = Tag_RequestTag("Tag.Example");
		var tags = new TagContainer();
		tags.AddTag(_t);
		
		_t = Tag_RequestTag("Tag.Example.Test");
		var container = new TagContainer();
		container.AddTag(_t);
		
		tags.AppendTags(container);
		
		AssertArrayContains(tags.tags, _t,  "Tags should not have been added from the container");
	});	
	
	AddFact("TagRequirements::CheckTagRequirements #1", function() {
		var require = new TagRequirements();
		var _t1 = Tag_RequestTag("Tag.Example");
		var _t2 = Tag_RequestTag("Action.Move");
		var ig = require.GetIgnoredTags();
		var re = require.GetRequiredTags();
		ig.AddTag(_t1);
		re.AddTag(_t2);
		
		var tags = new TagContainer();
		tags.AddTag(_t2);
		
		var b = require.MeetsRequirements(tags);
		
		AssertIsTrue(b, "TagContainer should pass requirements because it has all required tags and no ignored tags");
	});
	
	AddFact("TagRequirements::CheckTagRequirements #2", function() {
		var require = new TagRequirements();
		var _t1 = Tag_RequestTag("Tag.Example");
		var _t2 = Tag_RequestTag("Action.Move");
		var ig = require.GetIgnoredTags();
		var re = require.GetRequiredTags();
		ig.AddTag(_t1);
		re.AddTag(_t2);
		
		var tags = new TagContainer();
		tags.AddTag(_t1);
		
		var b = require.MeetsRequirements(tags);
		
		AssertIsFalse(b, "TagContainer should not pass requirements because it has an ignored tag");
	});
	
	AddFact("TagRequirements::CheckTagRequirements #3", function() {
		var require = new TagRequirements();
		var _t1 = Tag_RequestTag("Tag.Example");
		var _t2 = Tag_RequestTag("Action.Move");
		var ig = require.GetIgnoredTags();
		var re = require.GetRequiredTags();
		ig.AddTag(_t1);
		re.AddTag(_t2);
		
		var tags = new TagContainer();
		
		var b = require.MeetsRequirements(tags);
		
		AssertIsFalse(b, "TagContainer should not pass requirements because it doesn't have a required tag");
	});
	
	
	AddFact("TagContainerInherited::ApplyInheritance #1", function() {
		var inheritance = new TagContainerInherited();
		var _t = Tag_RequestTag("Tag.Example");
		inheritance.AddTag(_t);
		
		var container = new TagContainer();
		inheritance.ApplyTo(container);
		
		AssertArrayContains(container.tags, _t, "TagGet should have been added from the inheritance container");
	});
	
	
	AddFact("TagContainerInherited::ApplyInheritance #2", function() {
		var inheritance = new TagContainerInherited();
		var _t = Tag_RequestTag("Tag.Example");
		var _i = Tag_RequestTag("Action.Move");
		inheritance.AddTag(_t);
		inheritance.RemoveTag(_i);
		
		
		var parent = new TagContainerInherited();
		parent.AddTag(_t);
		parent.AddTag(_i);
		
		
		inheritance.UpdateInheritance(parent);
		
		var container = new TagContainer();
		inheritance.ApplyTo(container);
		
		var _bool = (array_contains(container.tags, _t) && !(array_contains(container.tags, _i)));
		AssertIsTrue(_bool, "TagGet t should have been added from the inheritance container and tag i should have been ignored");
	});
}