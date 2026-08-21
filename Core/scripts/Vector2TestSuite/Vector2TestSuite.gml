//feather ignore all

/** Unit tests for important Vector2 logic.
 * @ignore
 * @return {Struct.Vector2TestSuite} */
function Vector2TestSuite() : TestSuite("Vector2. Test Suite") constructor {
	
	AddFact("Vector2.CreateFromArray", function() {
		var a = [2, 3];
		var v = Vector2.CreateFromArray(a);
		var e = new Vector2(2, 3);
		AssertStructEquals(v, e, $"Incorrect Vector2 instantiation from an array");
	});
	
	AddFact("Vector2.Up", function() {
		var r = Vector2.Up();
		var e = new Vector2(0, -1);
		AssertStructEquals(r, e, $"Incorrect Up Vector");
	});
	
	AddFact("Vector2.Down", function() {
		var r = Vector2.Down();
		var e = new Vector2(0, 1);
		AssertStructEquals(r, e, $"Incorrect Down Vector");
	});
	
	AddFact("Vector2.Right", function() {
		var r = Vector2.Right();
		var e = new Vector2(1, 0);
		AssertStructEquals(r, e, $"Incorrect Right Vector");
	});
	
	AddFact("Vector2.Left", function() {
		var r = Vector2.Left();
		var e = new Vector2(-1, 0);
		AssertStructEquals(r, e, $"Incorrect Left Vector");
	});
	
	AddFact("Vector2.NegativeInfinity", function() {
		var r = Vector2.NegativeInfinity();
		var e = new Vector2(-infinity, -infinity);
		AssertStructEquals(r, e, $"Incorrect Left Vector");
	});
	
	AddFact("Vector2.PositiveInfinity", function() {
		var r = Vector2.PositiveInfinity();
		var e = new Vector2(infinity, infinity);
		AssertStructEquals(r, e, $"Incorrect Left Vector");
	});
	
	AddFact("Vector2.Set", function() {
		var v = new Vector2(2, 3);
		v.Set(4, 6);
		var e = new Vector2(4, 6);
		AssertStructEquals(v, e, $"Incorrect add with vector logic");
	});
	
	AddFact("Vector2.SetFromArray", function() {
		var v = new Vector2(2, 3);
		v.SetFromArray([4, 6]);
		var e = new Vector2(4, 6);
		AssertStructEquals(v, e, $"Incorrect add with vector logic");
	});
	
	AddFact("Vector2.ToArray", function() {
		var v = new Vector2(2, 3);
		var r = v.ToArray();
		var e = [2, 3];
		AssertArrayEquals(v, e, $"Incorrect add with vector logic");
	});
	
	AddFact("Vector2.Add (vector)", function() {
		var v = new Vector2(2, 3);
		var r = v.Add(v);
		var e = new Vector2(4, 6);
		AssertStructEquals(r, e, $"Incorrect add with vector logic");
	});
	
	AddFact("Vector2.Add (scalar)", function() {
		var v = new Vector2(2, 3);
		var r = v.Add(2);
		var e = new Vector2(4, 5);
		AssertStructEquals(r, e, $"Incorrect add with scalar logic");
	});
	
	AddFact("Vector2.Subtract (vector)", function() {
		var v = new Vector2(2, 3);
		var r = v.Subtract(v);
		var e = new Vector2();
		AssertStructEquals(r, e, $"Incorrect subtract with vector logic");
	});	
	
	AddFact("Vector2.Subtract (scalar)", function() {
		var v = new Vector2(2, 3);
		var r = v.Subtract(2);
		var e = new Vector2(0, 1);
		AssertStructEquals(r, e, $"Incorrect subtract with scalar logic");
	});
	
	AddFact("Vector2.Multiply (vector)", function() {
		var v = new Vector2(2, 3);
		var r = v.Multiply(v);
		var e = new Vector2(4, 9);
		AssertStructEquals(r, e, $"Incorrect multiply with vector logic");
	});
	
	AddFact("Vector2.Multiply (scalar)", function() {
		var v = new Vector2(2, 3);
		var r = v.Multiply(2);
		var e = new Vector2(4, 6);
		AssertStructEquals(r, e, $"Incorrect multiply with scalar logic");
	});
	
	AddFact("Vector2.Divide (vector)", function() {
		var v = new Vector2(2, 3);
		var r = v.Divide(v);
		var e = new Vector2(1, 1);
		AssertStructEquals(r, e, $"Incorrect divide with vector logic");
	});
	
	AddFact("Vector2.Divide (scalar)", function() {
		var v = new Vector2(2, 3);
		var r = v.Divide(2);
		var e = new Vector2(1, 1.5);
		AssertStructEquals(r, e, $"Incorrect divide with scalar logic");
	});
	
	AddFact("Vector2.Inverse", function() {
		var v = new Vector2(1, 1);
		var r = v.Inverse();
		var e = new Vector2(-1, -1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Dot", function() {
		var v = new Vector2(1, 1);
		var r = v.Dot(new Vector2(1, 1));
		var e = 2;
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Cross", function() {
		var v = new Vector2(1, 1);
		var r = v.Cross(new Vector2(1, 1));
		var e = 0;
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.LessThan x", function() {
		var a = new Vector2(0, 11);
		var b = new Vector2(2, 10);
		var r = a.LessThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector2.LessThan y", function() {
		var a = new Vector2(2, 9);
		var b = new Vector2(2, 10);
		var r = a.LessThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector2.LessThanOrEqualTo less", function() {
		var a = new Vector2(2, 9);
		var b = new Vector2(2, 10);
		var r = a.LessThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector2.LessThanOrEqualTo equal", function() {
		var a = new Vector2(2, 10);
		var b = new Vector2(2, 10);
		var r = a.LessThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector2.GreaterThan x", function() {
		var a = new Vector2(3);
		var b = new Vector2(2, 10);
		var r = a.GreaterThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector2.GreaterThan y", function() {
		var a = new Vector2(2, 11);
		var b = new Vector2(2, 10);
		var r = a.GreaterThan(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector2.GreaterThanOrEqualTo greater", function() {
		var a = new Vector2(2, 11);
		var b = new Vector2(2, 10);
		var r = a.GreaterThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector2.GreaterThanOrEqualTo equal", function() {
		var a = new Vector2(2, 10);
		var b = new Vector2(2, 10);
		var r = a.GreaterThanOrEqualTo(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector2.Equals", function() {
		var a = new Vector2(2, 10);
		var b = new Vector2(2, 10);
		var r = a.Equals(b);
		AssertIsTrue(r, $"Incorrect logic");
	});
	
	AddFact("Vector2.Abs", function() {
		var a = new Vector2(-2, -10);
		var r = a.Abs();
		var e = new Vector2(2, 10);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Angle", function() {
		var a = new Vector2();
		var r = a.Angle(new Vector2(0, 1));
		var e = 270;
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.AngleRadians", function() {
		var a = new Vector2();
		var r = a.AngleRadians(new Vector2(0, 1));
		var e = degtorad(270);
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Ceil", function() {
		var a = new Vector2(1.1, 1.1);
		var r = a.Ceil();
		var e = new Vector2(2, 2);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Clamp", function() {
		var a = new Vector2(1.1, 1.1);
		var r = a.Clamp(new Vector2(0, 0), new Vector2(1, 1));
		var e = new Vector2(1, 1)
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.DirectionRadians", function() {
		var a = new Vector2(1, 1);
		var r = a.DirectionRadians();
		var e = degtorad(315);
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Distance", function() {
		var a = new Vector2(0, 0);
		var r = a.Distance(new Vector2(0, 1));
		var e = 1;
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Direction", function() {
		var a = new Vector2(1, 1);
		var r = a.Direction();
		var e = 315;
		AssertEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Flip", function() {
		var a = new Vector2(2, 1);
		var r = a.Flip();
		var e = new Vector2(1, 2);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Floor", function() {
		var a = new Vector2(2.2, 1.1);
		var r = a.Floor();
		var e = new Vector2(2, 1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Frac", function() {
		var a = new Vector2(2.23, 1.12);
		var r = a.Frac();
		var e = new Vector2(0.23, 0.12);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Max scalar", function() {
		var a = new Vector2(2.23, 1.12);
		var r = a.Max(3);
		var e = new Vector2(3, 3);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Max vector", function() {
		var a = new Vector2(2.23, 1.12);
		var r = a.Max(new Vector2(2, 4));
		var e = new Vector2(2.23, 4);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Min scalar", function() {
		var a = new Vector2(2.23, 1.12);
		var r = a.Min(3);
		var e = new Vector2(2.23, 1.12);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Min vector", function() {
		var a = new Vector2(2.23, 1.12);
		var r = a.Min(new Vector2(2, 4));
		var e = new Vector2(2, 1.12);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Round", function() {
		var a = new Vector2(2.23, 1.77);
		var r = a.Round();
		var e = new Vector2(2, 2);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Sign", function() {
		var a = new Vector2(2.23, -1.77);
		var r = a.Sign();
		var e = new Vector2(1, -1);
		AssertStructEquals(r, e, $"Incorrect logic");
	});
	
	AddFact("Vector2.Lerp 0", function() {
		var a = new Vector2();
		var b = new Vector2(2, 10);
		var r = a.Lerp(b, 0);
		AssertStructEquals(r, a, $"Lerp of 0 should return the first input");
	});
	
	AddFact("Vector2.Lerp 1", function() {
		var a = new Vector2();
		var b = new Vector2(2, 10);
		var r = a.Lerp(b, 1);
		AssertStructEquals(r, b, $"Lerp of 1 should return the second input");
	});
	
	AddFact("Vector2.Lerp 0.5", function() {
		var v = new Vector2();
		var r = v.Lerp(new Vector2(2, 10), 0.5);
		var e = new Vector2(1, 5);
		AssertStructEquals(r, e, $"Lerp has incorrect logic.");
	});
	
	AddFact("Vector2.Magnitude", function() {
		var v = new Vector2(2, 3);
		var m = v.Magnitude();
		var e = sqrt(sqr(2) + sqr(3));
		AssertEquals(m, e, $"Incorrect magnitude calculation logic");
	});
	
	AddFact("Vector2.MagnitudeSqr", function() {
		var v = new Vector2(2, 3);
		var m = v.MagnitudeSqr();
		var e = (sqr(2) + sqr(3));
		AssertEquals(m, e, $"Incorrect magnitude calculation logic");
	});
	
	AddFact("Vector2.ClampMagnitude", function() {
		var v = new Vector2(4, 3);
		var r = v.ClampMagnitude(2);
		var e = new Vector2(1.6, 1.2);
		AssertStructEquals(r, e, $"Incorrect magnitude clamp logic");
	});
	
	AddFact("Vector2.MoveTowardsPoint", function() {
		var v = new Vector2();
		var t = new Vector2(1, 0);
		var r = v.MoveTowardsPoint(t, 2);
		var e = new Vector2(1, 0);
		AssertStructEquals(r, e, $"MoveTowardsPoint has incorrect logic.");
	});
	
	AddFact("Vector2.Normalize", function() {
		var v = new Vector2(12, 15);
		var r = v.Normalize();
		var c = 1/sqrt(sqr(12) + sqr(15));
		var e = new Vector2(12*c, 15*c);
		AssertStructEquals(r, e, $"Incorrect vector normalizing logic");
	});
	
	AddFact("Vector2.PerpendicularClockwise", function() {
		var v = new Vector2(0, 1);
		var r = v.PerpendicularClockwise();
		var e = new Vector2(1, 0);
		AssertStructEquals(r, e, $"Incorrect logic for returning a vector perpendicular (clockwise) to another vector");
	});
	
	AddFact("Vector2.PerpendicularCounterClockwise", function() {
		var v = new Vector2(0, 1);
		var r = v.PerpendicularCounterClockwise();
		var e = new Vector2(-1, 0)
		AssertStructEquals(r, e, $"Incorrect logic for returning a vector prependicular (counterclockwise) to another vector");
	});
	
	AddFact("Vector2.Project", function() {
		var v = new Vector2(2, 3);
		var n = new Vector2(4, 7);
		var r = v.Project(n);
		var e = new Vector2(116/65, 203/65);
		AssertStructEquals(r, e, $"Incorrect vector projection logic");
	});
	
	AddFact("Vector2.Reflect", function() {
		var v = new Vector2(1, 1).Normalize();
		var ray = new Vector2(0, -1);
		var reflect = ray.Reflect(v);
		var e = new Vector2(1, 0);
		AssertStructEquals(reflect, e, $"Incorrect vector reflection logic");
	});
	
	AddFact("Vector2.Rotate", function() {
		var v = new Vector2(0, 1);
		var rotate = v.Rotate(90);
		var e = new Vector2(1, 0);
		AssertStructEquals(rotate, e, $"Incorrect rotation logic");
	});
	
	AddFact("Vector2.RotateAround", function() {
		var v = new Vector2(2, 3);
		var p = new Vector2(1, 1);
		var r = v.RotateAround(p, 75);
		var e = new Vector2(3.19067, 0.55171);
		AssertStructEquals(r, e, $"Incorrect logic for rotation or incorrectly calculated origin");
	});
	
	AddFact("Vector2.ShearX", function() {
		var v = new Vector2(2, 3);
		var s = v.ShearX(1);
		var e = new Vector2(5, 3);
		
		AssertStructEquals(s, e, $"Incorrect logic for horizontal shear");
	});
	
	AddFact("Vector2.ShearY", function() {
		var v = new Vector2(2, 3);
		var s = v.ShearY(2);
		var e = new Vector2(2, 7);
		AssertStructEquals(s, e, $"Incorrect logic for vertical shear");
	});
	
	AddFact("Vector2.Shear X then Y", function() {
		var v = new Vector2(2, 3);
		v = v.ShearX(2);
		var s = v.ShearY(2);
		var e = new Vector2(8, 19);
		AssertStructEquals(s, e, $"Incorrect logic for horizontal and vertical shear, or incorrect shearing order for horizontal shear then vertical shear");
	});
	
	AddFact("Vector2.SmoothDamp", function() {
		var v = new Vector2(2, 3);
		var t = new Vector2(12, 12);
		var s = new Vector2(2, 2);
		var rt = 2;//runtime 2 seconds
		var dt = 0;//deltaTime. Time between calls to smoothdamp
		var time = get_timer();
		var r;
		while (dt < rt) {
			dt = MathMultiplyOneThousand(get_timer() - time);
			r = Vector2.SmoothDamp(v, t, s, rt, infinity, dt);
		}
		AssertStructEquals(r, t, $"Incorrect smooth damp logic. Vector did not end up at the target vector"); 
	});
}
