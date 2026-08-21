//feather ignore all

/** Quaternion Unit Test Suite
 * @return {Struct.QuaternionTestSuite} */
function QuaternionTestSuite() : TestSuite() constructor {
	
	AddFact("Quaternion.CreateFromDirections", function() {
		var right = Vector3.Right();
		var up = Vector3.Up();
		var forward = Vector3.Forwards();
		var quaternion = Quaternion.CreateFromDirections(right, up, forward);
		var expected = new Quaternion(0, 0, 0, 0.70711);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});
	
	AddFact("Quaternion.CreateFromEulerAngles (XYZ no singularity)", function() {
		var angles = new Vector3(67, 347, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.XYZ);
		var expected = new Quaternion(0.3670205, 0.4182554, -0.7390804, 0.3796295);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (XYZ north-pole singularity)", function() {
		var angles = new Vector3(67, 90, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.XYZ);
		var expected = new Quaternion(0.2988362, -0.6408564, 0.2988362, -0.6408564);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (XYZ south-pole singularity)", function() {
		var angles = new Vector3(67, 270, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.XYZ);
		var expected = new Quaternion(0.706676, 0.0246777, -0.706676, -0.0246777);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (XZY no singularity)", function() {
		var angles = new Vector3(67, 347, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.XZY);
		var expected = new Quaternion(0.2060445, 0.4182554, -0.7390804, 0.4861772);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});		
	
	AddFact("Quaternion.CreateFromEulerAngles (XZY north-pole singularity)", function() {
		var angles = new Vector3(67, 347, 90);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.XZY);
		var expected = new Quaternion(-0.4545195, 0.4545195, -0.5416752, -0.5416752);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (XZY south-pole singularity)", function() {
		var angles = new Vector3(67, 347, 270);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.XZY);
		var expected = new Quaternion(0.3210198, 0.3210198, -0.6300368, 0.6300368);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});			
	
	AddFact("Quaternion.CreateFromEulerAngles (YXZ no singularity)", function() {
		var angles = new Vector3(67, 347, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.YXZ);
		var expected = new Quaternion(0.3670205, 0.4182554, -0.6737879, 0.4861772);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (YXZ north-pole singularity)", function() {
		var angles = new Vector3(67, 90, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.YXZ);
		var expected = new Quaternion(0.2988362, -0.6408564, 0.706676, 0.0246777);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (YXZ south-pole singularity)", function() {
		var angles = new Vector3(67, 270, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.YXZ);
		var expected = new Quaternion(0.706676, 0.0246777, -0.2988362, 0.640856);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (YZX no singularity)", function() {
		var angles = new Vector3(67, 347, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.YZX);
		var expected = new Quaternion(0.3670205, -0.5169016, -0.6737879, 0.3796295);	
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (YZX north-pole singularity)", function() {
		var angles = new Vector3(67, 347, 90);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.YZX);
		var expected = new Quaternion(-0.3210198, -0.3210198, -0.6300368, -0.6300368);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (YZX south-pole singularity)", function() {
		var angles = new Vector3(67, 347, 270);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.YZX);
		var expected = new Quaternion(0.4545195, -0.4545195, -0.5416752, 0.5416752);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (ZXY no singularity)", function() {
		var angles = new Vector3(67, 347, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.ZXY);
		var expected = new Quaternion(0.2060445, -0.5169016, -0.7390804, 0.3796295);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (ZXY north-pole singularity)", function() {
		var angles = new Vector3(90, 347, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.ZXY);
		var expected = new Quaternion(0.2988362, -0.6408564, -0.6408564, 0.2988362);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (ZXY south-pole singularity)", function() {
		var angles = new Vector3(270, 347, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.ZXY);
		var expected = new Quaternion(0.4353384, -0.5572077, 0.5572077, -0.4353384);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});			
	
	AddFact("Quaternion.CreateFromEulerAngles (ZYX no singularity)", function() {
		var angles = new Vector3(67, 347, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.ZYX);
		var expected = new Quaternion(0.2060445, -0.5169016, -0.6737879, 0.4861772);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (ZYX north-pole singularity)", function() {
		var angles = new Vector3(67, 90, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.ZYX);
		var expected = new Quaternion(-0.706676, 0.0246777, 0.706676, 0.0246777);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});	
	
	AddFact("Quaternion.CreateFromEulerAngles (ZYX south-pole singularity)", function() {
		var angles = new Vector3(67, 270, 243);
		var quaternion = Quaternion.CreateFromEulerAngles(angles, QuaternionRotationOrder.ZYX);
		var expected = new Quaternion(-0.2988362, -0.6408564, -0.2988362, 0.6408564);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");		
	});		
	
	AddFact("Quaternion.CreateFromAngleAxis", function() {
		var angle = 90
		var axis = new Vector3(1, 0, 0);
		var quaternion = Quaternion.CreateFromAngleAxis(90, axis);
		var expected = new Quaternion(0.70711, 0, 0, 0.70711);	
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");
	});
	
	AddFact("Quaternion.CreateFromArray", function() {
		var array = [0, 0, 0, 1];
		var quaternion = Quaternion.CreateFromArray(array);
		var expected = new Quaternion();
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");
	});
	
	AddFact("Quaternion.CreateFromLookRotation", function() {
		var forward = Vector3.Forwards();
		var up = Vector3.Up();
		var quaternion = Quaternion.CreateFromLookRotation(forward, up);
		var expected = new Quaternion(0, 0, 1, 0);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");				
	});
	
	AddFact("Quaternion.CreateFromToRotation", function() {
		var from = new Vector3(0, 1, 0);
		var to = new Vector3(1, 1, 1);
		var quaternion = Quaternion.CreateFromToRotation(from, to);
		var expected = new Quaternion(0.32505, 0, -0.32505, 0.88807);
		AssertStructEquals(quaternion, expected, $"Quaternion Values not instantiated correctly.");			
	});
	
	AddFact("Quaternion.CreateFromVector", function() {
		var v = new Vector4(0.25, 0.25, 0.25, 0.25);
		var q = Quaternion.CreateFromVector(v);
		var e = new Quaternion(0.25, 0.25, 0.25, 0.25);
		AssertStructEquals(q, e, $"Quaternion Values not instantiated correctly.");	
	});
	
	AddFact("Quaternion.CreateFromMatrix", function() {
		var m = matrix_build_identity();
		var q = Quaternion.CreateFromMatrix(m);
		var e = new Quaternion();
		AssertStructEquals(q, e, $"Quaternion Values not instantiated correctly.");	
	});
	
	AddFact("Quaternion.ToArray", function() {
		var q = new Quaternion();
		var r = q.ToArray();
		var e = [0, 0, 0, 1];
		AssertArrayEquals(r, e, $"Quaternion Values not correctly converted to an array.");	
	});
	
	AddFact("Quaternion.ToAngleAxis", function() {
		var q = new Quaternion();
		var r = q.ToAngleAxis();
		AssertIsTrue((r.GetAngle() == 0) && (r.GetAxis().Equals(new Vector3(1, 0, 0))), $"Quaternion not correctly converted to angle axis.");	
	});
	
	AddFact("Quaternion.GetEulersAngles (YXZ no singularity)", function() {
		var q = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var a = q.GetEulersAngles();
		var expected = new Vector3(64.3061289, 65.1697554, 360-50.4649763);
		AssertStructEquals(a, expected, $"Incorrect Quaternion to Euler angle conversion");
	});
	
	AddFact("Quaternion.GetEulersAngles (YXZ north-pole singularity)", function() {
		var q = new Quaternion(0.5, -0.5, 0.5, 0.5);//Second angle in YXZ sequence points up to create singularity
		var a = q.GetEulersAngles();
		var e = new Vector3(90, 360-90, 0);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});
	
	AddFact("Quaternion.GetEulersAngles (YXZ south-pole singularity)", function() {
		var q = new Quaternion(-0.5, -0.5, -0.5, 0.5);//Second angle in YXZ sequence points down to create singularity
		var a = q.GetEulersAngles();
		var e = new Vector3(360-90, 360-90, 0);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});
	
	AddFact("Quaternion.GetEulersAngles (YZX no singularity)", function() {
		var q = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var a = q.GetEulersAngles(QuaternionRotationOrder.YZX);
		var expected = new Vector3(72.9719082, 112.6823358, 360-19.5347807);
		AssertStructEquals(a, expected, $"Incorrect Quaternion to Euler angle conversion");
	});	
	
	AddFact("Quaternion.GetEulersAngles (YZX north-pole singularity)", function() {
		var q = new Quaternion(0.5, 0.5, 0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.YZX);
		var e = new Vector3(0, 90, 90);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});
	
	AddFact("Quaternion.GetEulersAngles (YZX south-pole singularity)", function() {
		var q = new Quaternion(0.5, -0.5, -0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.YZX);
		var e = new Vector3(0, 360-90, 360-90);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});			
	
	AddFact("Quaternion.GetEulersAngles (XYZ no singularity)", function() {
		var q = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var a = q.GetEulersAngles(QuaternionRotationOrder.XYZ);
		var expected = new Vector3(78.5775066, 23.1713617, 360-113.2855485);
		AssertStructEquals(a, expected, $"Incorrect Quaternion to Euler angle conversion");
	});
	
	AddFact("Quaternion.GetEulersAngles (XYZ north-pole singularity)", function() {
		var q = new Quaternion(0.5, 0.5, 0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.XYZ);
		var e = new Vector3(90, 90, 0);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});
	
	AddFact("Quaternion.GetEulersAngles (XYZ south-pole singularity)", function() {
		var q = new Quaternion(0.5, -0.5, -0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.XYZ);
		var e = new Vector3(90, 360-90, 0);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});
	
	AddFact("Quaternion.GetEulersAngles (XZY no singularity)", function() {
		var q = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var a = q.GetEulersAngles(QuaternionRotationOrder.XZY);
		var expected = new Vector3(360-58.9861083, 132.725908, 360-57.612947);
		AssertStructEquals(a, expected, $"Incorrect Quaternion to Euler angle conversion");
	});	
	
	AddFact("Quaternion.GetEulersAngles (XZY north-pole singularity)", function() {
		var q = new Quaternion(-0.5, 0.5, 0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.XZY);
		var e = new Vector3(360-90, 0, 90);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});
	
	AddFact("Quaternion.GetEulersAngles (XZY south-pole singularity)", function() {
		var q = new Quaternion(0.5, 0.5, -0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.XZY);
		var e = new Vector3(90, 0, 360-90);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});	
	
	AddFact("Quaternion.GetEulersAngles (ZXY no singularity)", function() {
		var q = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var a = q.GetEulersAngles(QuaternionRotationOrder.ZXY);
		var expected = new Vector3(360-27.3266472, 78.1742077, 360-71.9014844);
		AssertStructEquals(a, expected, $"Incorrect Quaternion to Euler angle conversion");
	});		
	
	AddFact("Quaternion.GetEulersAngles (ZXY north-pole singularity)", function() {
		var q = new Quaternion(0.5, 0.5, 0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.ZXY);
		var e = new Vector3(90, 0, 90);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});
	
	AddFact("Quaternion.GetEulersAngles (ZXY south-pole singularity)", function() {
		var q = new Quaternion(0.5, -0.5, -0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.ZXY);
		var e = new Vector3(90, 0, 360-90);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});		 
	
	AddFact("Quaternion.GetEulersAngles (ZYX no singularity)", function() {
		var q = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var a = q.GetEulersAngles(QuaternionRotationOrder.ZYX);
		var expected = new Vector3(360-68.3664826, 60.4061177, 360-137.3835297);
		AssertStructEquals(a, expected, $"Incorrect Quaternion to Euler angle conversion");
	});	
	
	AddFact("Quaternion.GetEulersAngles (ZYX north-pole singularity)", function() {
		var q = new Quaternion(0.5, 0.5, -0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.ZYX);
		var e = new Vector3(0, 90, 360-90);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});
	
	AddFact("Quaternion.GetEulersAngles (ZYX south-pole singularity)", function() {
		var q = new Quaternion(0.5, -0.5, 0.5, 0.5);
		var a = q.GetEulersAngles(QuaternionRotationOrder.ZYX);
		var e = new Vector3(0, 360-90, 90);
		AssertStructEquals(a, e, $"Incorrect Quaternion to Euler angle conversion")
	});			
	
	AddFact("Quaternion to Euler, then back to Quaternion", function() {
		//Quaternion to euler
		var q = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var a = q.GetEulersAngles();
		
		//Euler back to Quaternion
		var r = Quaternion.CreateFromEulerAngles(a).Negate();
		var e = q.Clone();
		AssertStructEquals(r, e, $"Converting a Quatertion to Euler angles then back to Quaternion did not yield the original Quaternion");
	});
	
	AddFact("Quaternion from Euler, then back to Euler", function() {
		var a = new Vector3(67, 347, 243);
		var q = Quaternion.CreateFromEulerAngles(a);
		var r = q.GetEulersAngles();
		AssertStructEquals(r, a, $"Converting Euler angles to a Quaternion then back to Euler angles did not yield the original Euler angles");
	});
	
	AddFact("Quaternion.Multiply", function() {
		var q1 = new Quaternion(0.21, 0.60, -0.57, 0.52);
		var q2 = new Quaternion(0.59, 0.69, -0.39, 0.13);
		var p = q1.Multiply(q2);
		var expected = new Quaternion(0.4934, 0.1824, -0.486, -0.6926);
		AssertStructEquals(p, expected, $"Product is not the expected result");
	});	
	
	AddFact("Quaternion.RotateVector", function() {
		var q = new Quaternion(0.21, 0.60, -0.57, 0.52);
		var v = new Vector3(3, 0, -7);
		var p = q.RotateVector(v);
		var expected = new Vector3(-3.8016, 5.2944, -3.9328);
		AssertStructEquals(p, expected, $"Product is not the expected result");
	});
	
	AddFact("Quaternion.Conjugate", function() {
		var q = new Quaternion(3, -1, 8, 3);
		var r = q.Conjugate();
		var e = new Quaternion(-3, 1, -8, 3);
		AssertStructEquals(r, e, $"Conjugate is not the expected result");
	});
	
	AddFact("Quaternion.Inverse (unit)", function() {
		var q = new Quaternion(1, 0, 0, 0);
		var r = q.Inverse();
		var e = new Quaternion(1, 0, 0, 0).Conjugate();
		AssertStructEquals(r, e, $"Inverse of a unit Quaternion should be the same as its conjugate");
	});
	
	AddFact("Quaternion.Inverse (non-unit)", function() {
		var q = new Quaternion(1, -2, 3, -4);
		var r = q.Inverse();
		var _sqrMag = sqr(q.x) + sqr(q.y) + sqr(q.z) + sqr(q.w);
		var e = new Quaternion(-1/_sqrMag, 2/_sqrMag, -3/_sqrMag, -4/_sqrMag);
		AssertStructEquals(r, e, $"Incorrect inverse form");
	});
	
	AddFact("Quaternion.Slerp 0", function() {
		var q1 = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var q2 = new Quaternion(0.592001, 0.692356, -0.391347, 0.130442);
		var qs = q1.Slerp(q2, 0);
		AssertStructEquals(qs, q1, $"Slerp quaternion should be equal to the first input quaternion.");
	});
	
	AddFact("Quaternion.Slerp 1", function() {
		var q1 = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var q2 = new Quaternion(0.592001, 0.692356, -0.391347, 0.130442);
		var qs = q1.Slerp(q2, 1);
		AssertStructEquals(qs, q2, $"Slerp quaternion should be equal to the second input quaternion.");
	});
	
	AddFact("Quaternion.Slerp 0.5", function() {
		var q1 = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var q2 = new Quaternion(0.592001, 0.692356, -0.391347, 0.130442);
		var qs = q1.Slerp(q2, 0.5);
		var expected = new Quaternion(0.422933, 0.677851, -0.497325, 0.338099);
		AssertStructEquals(qs, expected, $"Slerp quaternion should be the rotation in between quaternion 1 & 2.");
	});
	
	AddFact("Quaternion.Normalize", function() {
		var q = new Quaternion(1, -2, 3, -4);
		var r = q.Normalized();
		var m = sqrt(sqr(q.x) + sqr(q.y) + sqr(q.z) + sqr(q.w));
		var e = new Quaternion(1/m, -2/m, 3/m, -4/m);
		AssertStructEquals(r, e, $"Incorrect normalization logic");
	});
	
	AddFact("Quaternion.Angle", function() {
		var q1 = new Quaternion(0.21, 0.60, -0.57, 0.52);
		var q2 = new Quaternion(0.59, 0.69, -0.39, 0.13);
		var a = q1.Angle(q2);
		var expected = 68.25;
		AssertStructEquals(a, expected, $"Incorrect angle difference");
	});
	
	AddFact("Quaternion.RotateTowards", function() {
		var q1 = new Quaternion(0.2112608, 0.6036022, -0.563362, 0.5231219);
		var q2 = new Quaternion(0.592001, 0.692356, -0.391347, 0.130442);		
		var d = 37;
		var qf = q1.RotateTowards(q2, d);
		var expected = new Quaternion(0.4408143911369578, 0.6817182314914755, -0.4888929979270054, 0.31925939609764564);
		AssertStructEquals(qf, expected, $"Incorrect final rotation.");
	});
}