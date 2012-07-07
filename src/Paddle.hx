import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;


enum InputType {
	PITCH_CONTROLS_DIRECTION;
	PITCH_CONTROLS_POSITION;
	KEYBOARD;
}


class Paddle extends Entity {
	public static var maxIgnoredPitch:Float = 20.0;
	public static var minPitch:Float = 40.0;
	public static var maxPitch:Float = 60.0;

	public var vel:Float;
	public var pitch:Float;
	
	public var controls:InputType;

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

		controls = PITCH_CONTROLS_DIRECTION;
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
		
		var oldPitch = pitch;
		pitch = Pitch.getPitch();
		
		var left = 0.0;
		var right = cast(HXP.width, Float);

		if (Std.is(world, BreakoutWorld)) {
			var bw = cast(world, BreakoutWorld);
			left = bw.left;
			right = bw.right;
		}

		if (controls != KEYBOARD && pitch > maxIgnoredPitch) {
			if (pitch < minPitch) pitch = minPitch;
			if (pitch > maxPitch) pitch = maxPitch;
		
			pitch -= (minPitch + maxPitch) * 0.5;
			
			pitch /= (maxPitch - minPitch) * 0.5;
			
			if (controls == PITCH_CONTROLS_POSITION) {
				var target = (pitch * 0.5 + 0.5) * (right - left - width) + left + halfWidth;
				
				vel = (target - x);
				
				x += vel * 0.5;
				
				y += (HXP.height - 20 - y) * 0.5;
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
		else if (controls != KEYBOARD) {
			pitch = oldPitch * 0.8;

			if (controls == PITCH_CONTROLS_POSITION)
				y += (HXP.height + 50 - y) * 0.2;
		}
		else {
			var dx = (if (Input.check(Key.RIGHT)) 1 else 0)
				- (if (Input.check(Key.LEFT)) 1 else 0);

			vel += 3 * dx;
			vel *= 0.8;
			x += vel;

			var ball = cast(world.typeFirst("ball"), Ball);
			if (ball != null && Input.pressed(Key.SPACE))
				ball.launch();
		}

		width = Std.int(150 + 0.5 * G.mic.activityLevel);

		if (x - halfWidth < left) {
			x = left + halfWidth;
			vel = 0.9 * Math.abs(vel);
		}
		else if (x + halfWidth > right) {
			x = right - halfWidth;
			vel = -0.9 * Math.abs(vel);
		}
	}

	override public function render () : Void {
		super.render();

		Draw.rect(Std.int(x - halfWidth), Std.int(y - halfHeight),
		          width, height, 0x0000CC);
		
		Draw.rect(Std.int(x + pitch * (halfWidth-1) - 1), Std.int(y - halfHeight + 2), 2, height-4, 0xFFFFFF);
	}
}
