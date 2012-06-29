import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;


enum InputType {
	PITCH_CONTROLS_DIRECTION;
	PITCH_CONTROLS_POSITION;
}


class Paddle extends Entity {
	public var vel:Float;
	public var pitch:Float;
	
	public static inline var controls:InputType = PITCH_CONTROLS_POSITION;

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
	}

	override public function update () : Void {
		var dx = (if (Input.check(Key.RIGHT)) 1 else 0)
			- (if (Input.check(Key.LEFT)) 1 else 0);

		vel += 3 * dx;
		
		var oldPitch = pitch;
		pitch = Pitch.getPitch();
		
		var left = 0.0;
		var right = cast(HXP.width, Float);

		if (Std.is(world, BreakoutWorld)) {
			var bw = cast(world, BreakoutWorld);
			left = bw.left;
			right = bw.right;
		}

		var minPitch = 40.0;
		var maxPitch = 60.0;
		
		if (pitch > 20) {
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
		} else {
			pitch = oldPitch * 0.8;
			y += (HXP.height + 50 - y) * 0.2;
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
