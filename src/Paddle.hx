import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import nme.geom.Point;


enum InputType {
	PITCH_CONTROLS_DIRECTION;
	PITCH_CONTROLS_POSITION;
	KEYBOARD;
}


class Paddle extends Entity {
	public static var maxIgnoredPitch:Int = 20;
	public static var minPitch:Int = 56;
	public static var maxPitch:Int = 113;
	public static var medPitch:Int = 80;

	public var vel:Float;
	public var pitch:Float;
	
	public var controls:InputType;
	public var recentering:Bool;
	public var needsCalibration:Bool;

	public function new () {
		super();

		x = HXP.width / 2;
		y = HXP.height - 50;
		width = 150;
		height = 10;
		centerOrigin();
		type = "solid";

		vel = 0;
		pitch = 0;

		controls = PITCH_CONTROLS_POSITION;
		recentering = false;
		needsCalibration = true;
	}

	override public function update () : Void {
		if (Main.debugMode && Input.pressed(Key.I)) {
			y = HXP.height - 50;
			if (controls == PITCH_CONTROLS_DIRECTION)
				controls = PITCH_CONTROLS_POSITION;
			else if (controls == PITCH_CONTROLS_POSITION)
				controls = KEYBOARD;
			else
				controls = PITCH_CONTROLS_DIRECTION;
		}

		doMotion();

		width = Std.int(150 + 0.5 * G.mic.activityLevel);

		var left = 0.0;
		var right = cast(HXP.width, Float);

		if (Std.is(world, BreakoutWorld)) {
			var bw = cast(world, BreakoutWorld);
			left = bw.left;
			right = bw.right;
		}

		if (x - halfWidth < left) {
			x = left + halfWidth;
			vel = 0.9 * Math.abs(vel);
		}
		else if (x + halfWidth > right) {
			x = right - halfWidth;
			vel = -0.9 * Math.abs(vel);
		}
	}

	public function doMotion () : Void {
		if (recentering)
			doRecentering();
		else if (Std.is(world, BreakoutWorld)
		    && cast(world, BreakoutWorld).ballsLeft == 0)
			doMotionLost();
		else if (controls == KEYBOARD)
			doMotionKeyboard();
		else
			doMotionMic();
	}

	public function doRecentering () : Void {
		var p = new Point(HXP.width/2 - x, HXP.height - 50 - y);
		if (p.length > 5)
			p.normalize(5);
		x += p.x;
		y += p.y;

		if (Math.abs(x - HXP.width/2) < 0.01
		    && Math.abs(y - HXP.height + 50) < 0.01)
		{
			recentering = false;
			waitForCalibration();
		}
	}

	public function doMotionLost () : Void {
		x += vel;
		vel *= 0.8;
		drop();
	}

	public function doMotionKeyboard () : Void {
		var dx = (if (Input.check(Key.RIGHT)) 1 else 0)
			- (if (Input.check(Key.LEFT)) 1 else 0);

		vel += 3 * dx;
		vel *= 0.8;
		x += vel;

		var ball = cast(world.typeFirst("ball"), Ball);
		if (ball != null && Input.pressed(Key.SPACE))
			ball.launch();
	}

	public function doMotionMic () : Void {
		// In keyboard mode, we don't care if we're calibrated, so check
		// here.
		if (needsCalibration)
			return;

		pitch = Pitch.getPitch();

		if (pitch <= maxIgnoredPitch) {
			if (controls == PITCH_CONTROLS_POSITION)
				drop();
			return;
		}

		if (pitch < minPitch) pitch = minPitch;
		if (pitch > maxPitch) pitch = maxPitch;

		// rescale pitch to [-1, 1].
		if (pitch < medPitch)
			pitch = (1 - medPitch/pitch) / (Math.sqrt(2) - 1);
		else
			pitch = (pitch/medPitch - 1) / (Math.sqrt(2) - 1);

		if (controls == PITCH_CONTROLS_POSITION) {
			var left = 0.0;
			var right = cast(HXP.width, Float);

			if (Std.is(world, BreakoutWorld)) {
				var bw = cast(world, BreakoutWorld);
				left = bw.left;
				right = bw.right;
			}

			var target = (pitch * 0.5 + 0.5) * (right - left - width) + left + halfWidth;

			vel = (target - x);

			x += vel * 0.5;

			y += (HXP.height - 50 - y) * 0.5;
		} else {
			vel += pitch * 40;

			var max = 20;

			if (vel < -max) vel = -max;
			if (vel > max) vel = max;

			vel *= 0.8;
			x += vel;
		}

		var ball = cast(world.typeFirst("ball"), Ball);
		if (ball != null)
			ball.launch();
	}

	public function drop () : Void {
		y += (HXP.height + 50 - y) * 0.2;
	}

	public function waitForCalibration () : Void {
		needsCalibration = true;
		world.add(new Activator());
	}

	override public function render () : Void {
		super.render();

		Draw.rect(Std.int(x - halfWidth), Std.int(y - halfHeight),
		          width, height, 0x0000CC);
		
		Draw.rect(Std.int(x + pitch * (halfWidth-1) - 1), Std.int(y - halfHeight + 2), 2, height-4, 0xFFFFFF);
	}

	public function calibrate (pitch:Int) {
		medPitch = pitch;
		minPitch = Std.int(pitch / Math.sqrt(2));
		maxPitch = Std.int(pitch * Math.sqrt(2));
		needsCalibration = false;
	}

	public function recenter () : Void {
		recentering = true;
	}
}
