//feather ignore all
 
/** Contains unit tests for important Vector4 logic
 * @return {Struct.Vector4TestSuite} */
function Vector4TestSuite() : TestSuite("Vector4 Test Suite") constructor {
	
	AddFact("Vector4.CreateFromArray", function() {
		var a = [2, 3, -1, -4];
		var v = Vector4.CreateFromArray(a);
		var e = new Vector4(2, 3, -1, -4);
		AssertStructEquals(v, e, $"Incorrect Vector4 instantiation from an array");
	});
	
	AddFact("Vector4.Set", function() {
		var v = new Vector4();
		v.Set(1, 1, 1, 1);
		var e = new Vector4(1, 1, 1, 1);
		AssertStructEquals(v, e, $"Incorrect Vector4 instantiation from an array");
	});
	
	AddFact("Vector4.SetFromArray", function() {
		var v = new Vector4();
		v.SetFromArray([1, 1, 1, 1]);
		var e = new Vector4(1, 1, 1, 1);
		AssertStructEquals(v, e, $"Incorrect Vector4 instantiation from an array");
	});	
	
	AddFact("Vector4.ToArray", function() {
		var v = new Vector4(2, 3);
		var r = v.ToArray();
		var e = [2, 3, 0, 0];
		AssertArrayEquals(v, e, $"Incorrect add with vector logic");
	});	
	
	AddFact("Vector4.Add (vector)", function() {
		var v = new Vector4(2, 3, -1, -4);
		var r = v.Add(new Vector4(2, 3, -1, -4));
		var e = new Vector4(4, 6, -2, -8);
		AssertStructEquals(r, e, $"Incorrect add with vector logic");
	});
	
	AddFact("Vector4.Add (scalar)", function() {
		var v = new Vector4(2, 3, -1, -4);
		var r = v.Add(2);
		var e = new Vector4(4, 5, 1, -2);
		AssertStructEquals(r, e, $"Incorrect add with scalar logic");
	});
	
	AddFact("Vector4.Subtract (vector)", function() {
		var v = new Vector4(2, 3, -1, -4);
		var r = v.Subtract(new Vector4(2, 3, -1, -4));
		var e = new Vector4();
		AssertStructEquals(r, e, $"Incorrect subtract with vector logic");
	});	
	
	AddFact("Vector4.Subtract (scalar)", function() {
		var v = new Vector4(2, 3, -1, -4);
		var r = v.Subtract(2);
		var e = new Vector4(0, 1, -3, -6);
		AssertStructEquals(r, e, $"Incorrect subtract with scalar logic");
	});
	
	AddFact("Vector4.Multiply (vector)", function() {
		var v = new Vector4(2, 3, -1, -4);
		var r = v.Multiply(new Vector4());
		var e = new Vector4();
		AssertStructEquals(r, e, $"Incorrect multiply with vector logic");
	});
	
	AddFact("Vector4.Multiply (scalar)", function() {
		var v = new Vector4(2, 3, -1, -4);
		var r = v.Multiply(2);
		var e = new Vector4(4, 6, -2, -8);
		AssertStructEquals(r, e, $"Incorrect multiply with scalar logic");
	});
	
	AddFact("Vector4.Divide (vector)", function() {
		var v = new Vector4(2, 3, -1, -4);
		var r = v.Divide(new Vector4(2, 2, 2, 2));
		var e = new Vector4(1, 1.5, -0.5, -2);
		AssertStructEquals(r, e, $"Incorrect divide with vector logic");
	});
	
	AddFact("Vector4.Divide (scalar)", function() {
		var v = new Vector4(2, 3, -1, -4);
		var r = v.Divide(2);
		var e = new Vector4(1, 1.5, -0.5, -2);
		AssertStructEquals(r, e, $"Incorrect divide with scalar logic");
	});
	
	AddFact("Vector4.Dot", function() {
		var v = new Vector4(2, 3, -1, 1);
		var r = v.Dot(new Vector4(1, 1, 1, 1));
		var e = 5
		AssertEquals(r, e, $"Incorrect divide with scalar logic");
	});
	
	AddFact("Vector4.Inverse", function() {
		var v = new Vector4(2, 3, -1);
		var r = v.Inverse();
		var e = new Vector4(-2, -3, 1);
		AssertStructEquals(r, e, $"Incorrect Cross Product logic");
	});	
	
	AddFact("Vector4.LessThan x", function() {
		var a = new Vector4(0, 11);
		var b = new Vector4(2, 10);
		var r = a.LessThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.LessThan y", function() {
		var a = new Vector4(2, 9);
		var b = new Vector4(2, 10);
		var r = a.LessThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.LessThan z", function() {
		var a = new Vector4(2, 10, -1);
		var b = new Vector4(2, 10);
		var r = a.LessThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.LessThan w", function() {
		var a = new Vector4(2, 10, 0, -1);
		var b = new Vector4(2, 10);
		var r = a.LessThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.LessThanOrEqualTo less", function() {
		var a = new Vector4(2, 10, 0, -1);
		var b = new Vector4(2, 10);
		var r = a.LessThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.LessThanOrEqualTo equal", function() {
		var a = new Vector4(2, 10);
		var b = new Vector4(2, 10);
		var r = a.LessThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.GreaterThan x", function() {
		var a = new Vector4(3);
		var b = new Vector4(2, 10);
		var r = a.GreaterThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.GreaterThan y", function() {
		var a = new Vector4(2, 11);
		var b = new Vector4(2, 10);
		var r = a.GreaterThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.GreaterThan z", function() {
		var a = new Vector4(2, 10, 1);
		var b = new Vector4(2, 10);
		var r = a.GreaterThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.GreaterThan w", function() {
		var a = new Vector4(2, 10, 0, 1);
		var b = new Vector4(2, 10);
		var r = a.GreaterThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.GreaterThanOrEqualTo greater", function() {
		var a = new Vector4(2, 10, 0, 1);
		var b = new Vector4(2, 10);
		var r = a.GreaterThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.GreaterThanOrEqualTo equal", function() {
		var a = new Vector4(2, 10);
		var b = new Vector4(2, 10);
		var r = a.GreaterThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector4.Equals", function() {
		var a = new Vector4(2, 10);
		var b = new Vector4(2, 10);
		var r = a.Equals(b);
		AssertIsTrue(r, $"Incorrect logic");
	});	
	
	AddFact("Vector4.Abs", function() {
		var a = new Vector4(-2, -10);
		var r = a.Abs();
		var e = new Vector4(2, 10);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.Angle", function() {
		var a = new Vector4();
		var r = a.Angle(new Vector4(0, 1));
		var e = 90;
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.AngleRadians", function() {
		var a = new Vector4();
		var r = a.AngleRadians(new Vector4(0, 1));
		var e = degtorad(90);
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.Ceil", function() {
		var a = new Vector4(1.1, 1.1);
		var r = a.Ceil();
		var e = new Vector4(2, 2)
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.Clamp", function() {
		var a = new Vector4(1.1, 1.1);
		var r = a.Clamp(new Vector4(0, 0), new Vector4(1, 1));
		var e = new Vector4(1, 1)
		AssertStructEquals(r, e, $"Incorrect logic");
	});	
	
	AddFact("Vector4.Distance", function() {
		var a = new Vector4(0, 0);
		var r = a.Distance(new Vector4(0, 1));
		var e = 1;
		AssertEquals(r, e, $"Incorrect logic");
	});	
	
	AddFact("Vector4.Floor", function() {
		var a = new Vector4(2.2, 1.1);
		var r = a.Floor();
		var e = new Vector4(2, 1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.Frac", function() {
		var a = new Vector4(2.23, 1.12, 0.1);
		var r = a.Frac();
		var e = new Vector4(0.23, 0.12, 0.1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});	
	
	AddFact("Vector4.Max scalar", function() {
		var a = new Vector4(2.23, 1.12, 1);
		var r = a.Max(3);
		var e = new Vector4(3, 3, 3, 3);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.Max vector", function() {
		var a = new Vector4(2.23, 1.12, 1, 2);
		var r = a.Max(new Vector4(2, 4));
		var e = new Vector4(2.23, 4, 1, 2);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.Min scalar", function() {
		var a = new Vector4(2.23, 1.12, 4);
		var r = a.Min(3);
		var e = new Vector4(2.23, 1.12, 3);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.Min vector", function() {
		var a = new Vector4(2.23, 1.12);
		var r = a.Min(new Vector4(2, 4, -1));
		var e = new Vector4(2, 1.12, -1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.Round", function() {
		var a = new Vector4(2.23, 1.77, 0.23);
		var r = a.Round();
		var e = new Vector4(2, 2);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector4.Sign", function() {
		var a = new Vector4(2.23, -1.77);
		var r = a.Sign();
		var e = new Vector4(1, -1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});				
	
	AddFact("Vector4.Lerp 1", function() {
		var v = new Vector4();
		var _lerp = v.Lerp(new Vector4(2, 10, 2, 0), 1);
		var e = new Vector4(2, 10, 2, 0);
		AssertStructEquals(_lerp, e, $"Lerp has incorrect logic.");
	});	
	
	AddFact("Vector4.Lerp 0", function() {
		var v = new Vector4();
		var _lerp = v.Lerp(new Vector4(2, 10, 2, 0), 0);
		var e = new Vector4();
		AssertStructEquals(_lerp, e, $"Lerp has incorrect logic.");
	});		
	
	AddFact("Vector4.Lerp 0.5", function() {
		var v = new Vector4();
		var _lerp = v.Lerp(new Vector4(2, 10, 2, 0), 0.5);
		var e = new Vector4(1, 5, 1, 0);
		AssertStructEquals(_lerp, e, $"Lerp has incorrect logic.");
	});
	
	AddFact("Vector4.Magnitude", function() {
		var v = new Vector4(2, 3, -1, -4);
		var m = v.Magnitude();
		var e = sqrt(sqr(2) + sqr(3) + sqr(-1) + sqr(-4));
		AssertEquals(m, e, $"Incorrect magnitude calculation logic");
	});
	
	AddFact("Vector4.ClampMagnitude", function() {
		var v = new Vector4(4, 3, -1, -4);
		var r = v.ClampMagnitude(2);
		var _div = sqrt(sqr(4) + sqr(3) + sqr(-1) + sqr(-4));
		var e = new Vector4(8/_div, 6/_div, -2/_div, -8/_div);
		AssertStructEquals(r, e, $"Incorrect magnitude clamp logic");
	});
	
	AddFact("Vector4.MoveTowardsPoint", function() {
		var v = new Vector4();
		var r = v.MoveTowardsPoint(new Vector4(10, 0, 0, 0), 2);
		var e = new Vector4(2, 0, 0, 0);
		AssertStructEquals(r, e, $"MoveTowardsPoint has incorrect logic.");
	});
	
	AddFact("Vector4.Normalize", function() {
		var v = new Vector4(12, 15, -7, 4);
		var r = v.Normalize();
		var c = 1/sqrt(sqr(12) + sqr(15) + sqr(-7) + sqr(4));
		var e = new Vector4(12*c, 15*c, -7*c, 4*c);
		AssertStructEquals(r, e, $"Incorrect vector normalizing logic");
	});
	
	AddFact("Vector4.Project", function() {
		var v = new Vector4(2, 3, -1, -4);
		var n = new Vector4(4, 7, -3, -4);
		var r = v.Project(n);
		var e = new Vector4(32/15, 56/15, -24/15, -32/15);
		AssertStructEquals(r, e, $"Incorrect vector projection logic");
	});	
	
	AddFact("Vector4.ProjectOnPlane", function() {
		var v = new Vector4(2, 3, -1, -4);
		var n = new Vector4(4, 7, -3, -4);
		var r = v.ProjectOnPlane(n);
		var e = new Vector4(2 - 32/15, 3 - 56/15, -1 + 24/15, -4 + 32/15);
		AssertStructEquals(r, e, $"Incorrect vector projection logic");
	});	
	
}