//feather ignore all
 
/** Unit tests for important Vector3 logic
 * @ignore
 * @return {Struct.Vector3TestSuite} */
function Vector3TestSuite() : TestSuite("Vector3 Test Suite") constructor {
	
	AddFact("Vector3.CreateFromArray", function() {
		var a = [2, 3, -1];
		var v = Vector3.CreateFromArray(a);
		var e = new Vector3(2, 3, -1);
		AssertStructEquals(v, e, $"Incorrect Vector3 instantiation from an array");
	});
	
	AddFact("Vector3.Up", function() {
		var r = Vector3.Up();
		var e = new Vector3(0, -1);
		AssertStructEquals(r, e, $"Incorrect Up Vector");
	});
	
	AddFact("Vector3.Down", function() {
		var r = Vector3.Down();
		var e = new Vector3(0, 1);
		AssertStructEquals(r, e, $"Incorrect Down Vector");
	});
	
	AddFact("Vector3.Right", function() {
		var r = Vector3.Right();
		var e = new Vector3(1, 0);
		AssertStructEquals(r, e, $"Incorrect Right Vector");
	});
	
	AddFact("Vector3.Left", function() {
		var r = Vector3.Left();
		var e = new Vector3(-1, 0);
		AssertStructEquals(r, e, $"Incorrect Left Vector");
	});
	
	AddFact("Vector3.Forwards", function() {
		var r = Vector3.Forwards();
		var e = new Vector3(0, 0, 1);
		AssertStructEquals(r, e, $"Incorrect Right Vector");
	});
	
	AddFact("Vector3.Backwards", function() {
		var r = Vector3.Backwards();
		var e = new Vector3(0, 0, -1);
		AssertStructEquals(r, e, $"Incorrect Left Vector");
	});
	
	AddFact("Vector3.NegativeInfinity", function() {
		var r = Vector3.NegativeInfinity();
		var e = new Vector3(-infinity, -infinity, -infinity);
		AssertStructEquals(r, e, $"Incorrect Left Vector");
	});
	
	AddFact("Vector3.PositiveInfinity", function() {
		var r = Vector3.PositiveInfinity();
		var e = new Vector3(infinity, infinity, infinity);
		AssertStructEquals(r, e, $"Incorrect Left Vector");
	});	
	
	AddFact("Vector3.Set", function() {
		var v = new Vector3(2, 3);
		v.Set(4, 6, 1);
		var e = new Vector3(4, 6, 1);
		AssertStructEquals(v, e, $"Incorrect add with vector logic");
	});
	
	AddFact("Vector3.SetFromArray", function() {
		var v = new Vector3(2, 3);
		v.SetFromArray([4, 6, 1]);
		var e = new Vector3(4, 6, 1);
		AssertStructEquals(v, e, $"Incorrect add with vector logic");
	});	
	
	AddFact("Vector3.ToArray", function() {
		var v = new Vector3(2, 3);
		var r = v.ToArray();
		var e = [2, 3, 0];
		AssertArrayEquals(v, e, $"Incorrect add with vector logic");
	});	
	
	AddFact("Vector3.Add (vector)", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Add(new Vector3(2, 3, -1));
		var e = new Vector3(4, 6, -2);
		AssertStructEquals(r, e, $"Incorrect add with vector logic");
	});
	
	AddFact("Vector3.Add (scalar)", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Add(2);
		var e = new Vector3(4, 5, 1);
		AssertStructEquals(r, e, $"Incorrect add with scalar logic");
	});
	
	AddFact("Vector3.Subtract (vector)", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Subtract(new Vector3(2, 3, -1));
		var e = new Vector3();
		AssertStructEquals(r, e, $"Incorrect subtract with vector logic");
	});	
	
	AddFact("Vector3.Subtract (scalar)", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Subtract(2);
		var e = new Vector3(0, 1, -3);
		AssertStructEquals(r, e, $"Incorrect subtract with scalar logic");
	});
	
	AddFact("Vector3.Multiply (vector)", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Multiply(new Vector3());
		var e = new Vector3();
		AssertStructEquals(r, e, $"Incorrect multiply with vector logic");
	});
	
	AddFact("Vector3.Multiply (scalar)", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Multiply(2);
		var e = new Vector3(4, 6, -2);
		AssertStructEquals(r, e, $"Incorrect multiply with scalar logic");
	});
	
	AddFact("Vector3.Divide (vector)", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Divide(new Vector3(2, 2, 2));
		var e = new Vector3(1, 1.5, -0.5);
		AssertStructEquals(r, e, $"Incorrect divide with vector logic");
	});
	
	AddFact("Vector3.Divide (scalar)", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Divide(2);
		var e = new Vector3(1, 1.5, -0.5);
		AssertStructEquals(r, e, $"Incorrect divide with scalar logic");
	});
	
	AddFact("Vector3.Dot", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Dot(new Vector3(1, 1, 1));
		var e = 4
		AssertEquals(r, e, $"Incorrect divide with scalar logic");
	});
	
	AddFact("Vector3.Cross", function() {
		var v = new Vector3(2, 3, -1);
		var b = new Vector3(4, -2, 5);
		var r = v.Cross(b);
		var e = new Vector3(13, -14, -16);
		AssertStructEquals(r, e, $"Incorrect Cross Product logic");
	});
	
	AddFact("Vector3.Inverse", function() {
		var v = new Vector3(2, 3, -1);
		var r = v.Inverse();
		var e = new Vector3(-2, -3, 1);
		AssertStructEquals(r, e, $"Incorrect Cross Product logic");
	});
	
	AddFact("Vector3.LessThan x", function() {
		var a = new Vector3(0, 11);
		var b = new Vector3(2, 10);
		var r = a.LessThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.LessThan y", function() {
		var a = new Vector3(2, 9);
		var b = new Vector3(2, 10);
		var r = a.LessThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.LessThan z", function() {
		var a = new Vector3(2, 10, -1);
		var b = new Vector3(2, 10);
		var r = a.LessThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.LessThanOrEqualTo less", function() {
		var a = new Vector3(2, 10, -1);
		var b = new Vector3(2, 10);
		var r = a.LessThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.LessThanOrEqualTo equal", function() {
		var a = new Vector3(2, 10);
		var b = new Vector3(2, 10);
		var r = a.LessThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.GreaterThan x", function() {
		var a = new Vector3(3);
		var b = new Vector3(2, 10);
		var r = a.GreaterThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.GreaterThan y", function() {
		var a = new Vector3(2, 11);
		var b = new Vector3(2, 10);
		var r = a.GreaterThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.GreaterThan z", function() {
		var a = new Vector3(2, 10, 1);
		var b = new Vector3(2, 10);
		var r = a.GreaterThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.GreaterThanOrEqualTo greater", function() {
		var a = new Vector3(2, 10, 1);
		var b = new Vector3(2, 10);
		var r = a.GreaterThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.GreaterThanOrEqualTo equal", function() {
		var a = new Vector3(2, 10);
		var b = new Vector3(2, 10);
		var r = a.GreaterThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector3.Equals", function() {
		var a = new Vector3(2, 10);
		var b = new Vector3(2, 10);
		var r = a.Equals(b);
		AssertIsTrue(r, $"Incorrect logic");
	});	
	
	AddFact("Vector3.Abs", function() {
		var a = new Vector3(-2, -10);
		var r = a.Abs();
		var e = new Vector3(2, 10);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.Angle", function() {
		var a = new Vector3();
		var r = a.Angle(new Vector3(0, 1));
		var e = 90;
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.AngleRadians", function() {
		var a = new Vector3();
		var r = a.AngleRadians(new Vector3(0, 1));
		var e = degtorad(90);
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.Ceil", function() {
		var a = new Vector3(1.1, 1.1);
		var r = a.Ceil();
		var e = new Vector3(2, 2)
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.Clamp", function() {
		var a = new Vector3(1.1, 1.1);
		var r = a.Clamp(new Vector3(0, 0), new Vector3(1, 1));
		var e = new Vector3(1, 1)
		AssertStructEquals(r, e, $"Incorrect logic");
	});	
	
	AddFact("Vector3.Distance", function() {
		var a = new Vector3(0, 0);
		var r = a.Distance(new Vector3(0, 1));
		var e = 1;
		AssertEquals(r, e, $"Incorrect logic");
	});	
	
	AddFact("Vector3.Floor", function() {
		var a = new Vector3(2.2, 1.1);
		var r = a.Floor();
		var e = new Vector3(2, 1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.Frac", function() {
		var a = new Vector3(2.23, 1.12, 0.1);
		var r = a.Frac();
		var e = new Vector3(0.23, 0.12, 0.1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});	
	
	AddFact("Vector3.Max scalar", function() {
		var a = new Vector3(2.23, 1.12, 1);
		var r = a.Max(3);
		var e = new Vector3(3, 3, 3);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.Max vector", function() {
		var a = new Vector3(2.23, 1.12, 1);
		var r = a.Max(new Vector3(2, 4));
		var e = new Vector3(2.23, 4, 1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.Min scalar", function() {
		var a = new Vector3(2.23, 1.12, 4);
		var r = a.Min(3);
		var e = new Vector3(2.23, 1.12, 3);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.Min vector", function() {
		var a = new Vector3(2.23, 1.12);
		var r = a.Min(new Vector3(2, 4, -1));
		var e = new Vector3(2, 1.12, -1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.Round", function() {
		var a = new Vector3(2.23, 1.77, 0.23);
		var r = a.Round();
		var e = new Vector3(2, 2);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector3.Sign", function() {
		var a = new Vector3(2.23, -1.77);
		var r = a.Sign();
		var e = new Vector3(1, -1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});	
	
	AddFact("Vector3.Lerp 1", function() {
		var v = new Vector3();
		var _lerp = v.Lerp(new Vector3(2, 10, 2), 1);
		var e = new Vector3(2, 10, 2);
		AssertStructEquals(_lerp, e, $"Lerp has incorrect logic.");
	});	
	
	AddFact("Vector3.Lerp 0", function() {
		var v = new Vector3();
		var _lerp = v.Lerp(new Vector3(2, 10, 2), 0);
		var e = new Vector3();
		AssertStructEquals(_lerp, e, $"Lerp has incorrect logic.");
	});		
	
	AddFact("Vector3.Lerp 0.5", function() {
		var v = new Vector3();
		var _lerp = v.Lerp(new Vector3(2, 10, 2), 0.5);
		var e = new Vector3(1, 5, 1);
		AssertStructEquals(_lerp, e, $"Lerp has incorrect logic.");
	});
	
	AddFact("Vector3.Magnitude", function() {
		var v = new Vector3(2, 3, -1);
		var m = v.Magnitude();
		var e = sqrt(sqr(2) + sqr(3) + sqr(-1));
		AssertEquals(m, e, $"Incorrect magnitude calculation logic");
	});
	
	AddFact("Vector3.ClampMagnitude", function() {
		var v = new Vector3(4, 3, -1);
		var r = v.ClampMagnitude(2);
		var _div = sqrt(26);
		var e = new Vector3(8/_div, 6/_div, -2/_div);
		AssertStructEquals(r, e, $"Incorrect magnitude clamp logic");
	});
	
	AddFact("Vector3.MoveTowardsPoint", function() {
		var v = new Vector3();
		var r = v.MoveTowardsPoint(new Vector3(10, 0, 0), 2);
		var e = new Vector3(2, 0, 0);
		AssertStructEquals(r, e, $"MoveTowardsPoint has incorrect logic.");
	});
	
	AddFact("Vector3.Normalize", function() {
		var v = new Vector3(12, 15, -7);
		var r = v.Normalize();
		var c = 1/sqrt(sqr(12) + sqr(15) + sqr(-7));
		var e = new Vector3(12*c, 15*c, -7*c);
		AssertStructEquals(r, e, $"Incorrect vector normalizing logic");
	});
	
	AddFact("Vector3.Project", function() {
		var v = new Vector3(2, 3, -1);
		var n = new Vector3(4, 7, -3);
		var r = v.Project(n);
		var e = new Vector3(64/37, 112/37, -48/37);
		AssertStructEquals(r, e, $"Incorrect vector projection logic");
	});
	
	AddFact("Vector3.Reflect", function() {
		var v = new Vector3(1, 1, 1);
		var ray = new Vector3(0, -1, 0);
		var reflect = ray.Reflect(v);
		var e = new Vector3(2, 1, 2);
		AssertStructEquals(reflect, e, $"Incorrect vector reflection logic");
	});
	
	AddFact("Vector3.Rotate", function() {
		var v = new Vector3(0, 1, 0);
		var rotate = v.Rotate(new Vector3(0, 0, 90));
		var e = new Vector3(1, 0, 0);
		AssertStructEquals(rotate, e, $"Incorrect rotation logic");
	});
	
	AddFact("Vector3.RotateAround", function() {
		var v = new Vector3(2, 3, -1);
		var p = new Vector3(1, 1, 0);
		var r = v.RotateAround(p, new Vector3(0, 0, 90));
		var e = new Vector3(3, 0, -1);
		AssertStructEquals(r, e, $"Incorrect logic for rotation or incorrectly calculated origin");
	});
	
	
	AddFact("Vector3.ShearX", function() {
		var v = new Vector3(2, 3);
		var s = v.ShearX(1, 1);
		var e = new Vector3(5, 3);
		AssertStructEquals(s, e, $"Incorrect logic for horizontal shear");
	});
	
	AddFact("Vector3.ShearY", function() {
		var v = new Vector3(2, 3, 1);
		var s = v.ShearY(2, 2);
		var e = new Vector3(2, 9, 1);
		AssertStructEquals(s, e, $"Incorrect logic for vertical shear");
	});	
	
	AddFact("Vector3.ShearZ", function() {
		var v = new Vector3(2, 3, 1);
		var s = v.ShearZ(2, 2);
		var e = new Vector3(2, 3, 11);
		AssertStructEquals(s, e, $"Incorrect logic for vertical shear");
	});	
	
	AddFact("Vector3.SmoothDamp", function() {
		var v = new Vector3(2, 3, -1);
		var t = new Vector3(12, 12, 12);
		var s = new Vector3(2, 9, 2);
		var rt = 2;//runtime 2 seconds
		var dt = 0;//deltaTime. Time between calls to smoothdamp
		var time = get_timer();
		var r;
		while (dt < rt) {
			dt = MathMultiplyOneThousand(get_timer() - time);
			r = Vector3.SmoothDamp(v, t, s, rt, infinity, dt);
		}
		math_set_epsilon(0.001);
		AssertStructEquals(r, t, $"Incorrect smooth damp logic. Vector did not end up at the target vector");
		MathResetEpsilon();
	});
}