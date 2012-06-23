import com.haxepunk.Entity;
import com.haxepunk.utils.Draw;
import com.haxepunk.HXP;
import nme.geom.Point;

class Ball extends Entity {
	var vel:Point;
	var radius:Int;

	public function new () {
		super();

		x = HXP.width / 2;
		y = HXP.height / 2;
		radius = 10;
		mask = new com.haxepunk.masks.Circle(radius, 0, 0);

		vel = new Point(5, 7);
	}

	override public function update () : Void {
		moveBy(vel.x, vel.y, "paddle");

		var bw = cast(world, BreakoutWorld);

		if (x + radius > bw.right) {
			x = bw.right - radius;
			vel.x = - Math.abs(vel.x);
		}
		else if (x - radius < bw.left) {
			x = bw.left + radius;
			vel.x = Math.abs(vel.x);
		}

		if (y + radius > bw.bottom) {
			y = bw.bottom - radius;
			vel.y = - Math.abs(vel.y);
		}
		else if (y - radius < bw.top) {
			y = bw.top + radius;
			vel.y = Math.abs(vel.y);
		}
	}


	override public function render () : Void {
		super.render();

		Draw.circle(Std.int(x), Std.int(y), radius, 0xFF0000);
	}

	override public function moveCollideX (e) : Void {
		trace("collide x");
	}

	override public function moveCollideY (e) : Void {
		trace("collide y");
	}
}
