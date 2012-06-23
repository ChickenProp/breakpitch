import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

class Paddle extends Entity {
	var vel:Float;

	public function new () {
		super();

		x = HXP.width / 2;
		y = HXP.height - 50;
		width = 40;
		height = 10;
		centerOrigin();
		type = "paddle";

		vel = 0;
	}

	override public function update () : Void {
		var dx = (if (Input.check(Key.RIGHT)) 1 else 0)
			- (if (Input.check(Key.LEFT)) 1 else 0);

		vel += 3 * dx;
		vel *= 0.9;
		x += vel;

		var bw = cast(world, BreakoutWorld);
		if (x - halfWidth < bw.left) {
			x = bw.left + halfWidth;
			vel = 0.9 * Math.abs(vel);
		}
		else if (x + halfWidth > bw.right) {
			x = bw.right - halfWidth;
			vel = -0.9 * Math.abs(vel);
		}

	}

	override public function render () : Void {
		super.render();

		Draw.rect(Std.int(x - halfWidth), Std.int(y - halfHeight),
		          width, height, 0x0000CC);
	}
}
