//feather ignore all
 
/** Unit tests for `BitMask_*` functions
 * @return {Struct.BitMaskTestSuite} */
function BitMaskTestSuite() : TestSuite("BitMask Test Suite") constructor {
	
	AddFact("BitMask.Shift (left)", function() {
		var mask = 1
		mask = BitMask_ShiftMask(mask, 5);
		AssertEquals(mask, 32, $"Left shift logic is incorrect");
	});
	
	AddFact("BitMask.Shift (right)", function() {
		var mask = 32;
		mask = BitMask_ShiftMask(mask, 5, false);
		AssertEquals(mask, 1, $"Right shift logic is incorrect");
	});
	
	AddFact("BitMask.MatchesAny", function() {
		var mask = (23);
		var maskB = (14);
		AssertIsTrue(BitMask_MatchesAny(mask, maskB), $"Logic for checking overlaping mask bits is incorrect");
	});
	
	AddFact("BitMask.MatchesAll (calling mask is smaller)", function() {
		var mask = (23);
		var maskB = (15);
		AssertIsTrue(BitMask_MatchesAll(mask, maskB), $"Logic for checking overlaping mask bits is incorrect");
	});
	
	AddFact("BitMask.MatchesAll (calling mask is larger)", function() {
		var mask = (15);
		var maskB = (23);
		AssertIsTrue(BitMask_MatchesAll(mask, maskB), $"Logic for checking overlaping mask bits is incorrect");
	});
	
	AddFact("BitMask.MatchesNone", function() {
		var mask = (23);
		var maskB = (8);
		AssertIsTrue(BitMask_MatchesNone(mask, maskB), $"Logic for checking overlaping mask bits is incorrect");
	});
	
	AddFact("BitMask.EnableBit", function() {
		var mask = 0;
		mask = BitMask_EnableBit(mask, 3);
		AssertEquals(mask, 8, $"Logic for enabling a bit at the specified index is incorrect");
	});
	
	AddFact("BitMask.EnableBitGroup", function() {
		var mask = 0;
		mask = BitMask_EnableBitGroup(mask, [0, 1, 2]);
		AssertEquals(mask, 7, $"Logic for enabling a bit at the specified index is incorrect");
	});
	
	AddFact("BitMask.EnableBitExclusive", function() {
		var mask = BitMask_EnableBitExclusive(2);
		AssertEquals(mask, 4, $"Logic for enabling a bit at the specified index is incorrect");
	});
	
	AddFact("BitMask.DisableBit", function() {
		var mask = (23);
		mask = BitMask_DisableBit(mask, 2);
		AssertEquals(mask, 19, $"Logic for disabling a bit at the specified index is incorrect");
	});
	
	AddFact("BitMask.DisableBitExclusive", function() {
		var mask = BitMask_DisableBitExclusive(2);
		AssertEquals(mask, -5, $"Logic for disabling a bit at the specified index is incorrect");
	});
	
	AddFact("BitMask.DisableBitGroup", function() {
		var mask = (23);
		mask = BitMask_DisableBitGroup(mask, [0, 1, 2]);
		AssertEquals(mask, 16, $"Logic for enabling a bit at the specified index is incorrect");
	});	
	
	AddFact("BitMask.ToggleBit", function() {
		var mask = (23);
		mask = BitMask_ToggleBit(mask, 2);
		AssertEquals(mask, 19, $"Logic for enabling a bit at the specified index is incorrect");
	});	
	
	AddFact("BitMask.IsBitActive", function() {
		var mask = (23);
		AssertIsTrue(BitMask_IsBitActive(mask, 2), $"Logic for enabling a bit at the specified index is incorrect");
	});	
}