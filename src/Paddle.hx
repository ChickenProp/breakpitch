import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

class Paddle extends Entity {
	public var vel:Float;

	public function new () {
		super();

		x = HXP.width / 2;
		y = HXP.height - 50;
		width = 100;
		height = 10;
		centerOrigin();
		type = "paddle";

		vel = 0;
	}

	override public function update () : Void {
		/*var dx = (if (Input.check(Key.RIGHT)) 1 else 0)
			- (if (Input.check(Key.LEFT)) 1 else 0);

		vel += 3 * dx;*/
		vel *= 0.9;
		x += vel;

		var left = 0;
		var right = HXP.width;
		
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
		
		var scale = 1.0 + 0.02 * G.mic.activityLevel;
		
		var w = Std.int(halfWidth * scale);

		Draw.rect(Std.int(x - w), Std.int(y - halfHeight),
		          w*2, height, 0x0000CC);
	}
}
