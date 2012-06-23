import com.haxepunk.Entity;
import com.haxepunk.utils.Draw;
import com.haxepunk.HXP;
import nme.geom.Point;

class Ball extends Entity, implements hxop.Overload<hxop.ops.PointOps> {
	var vel:Point;
	var radius:Float;

	public function new () {
		super();

		x = HXP.width / 2;
		y = HXP.height / 2;
		radius = 10;

		vel = new Point(5, 7);
	}

	override public function update () : Void {
		x += vel.x;
		y += vel.y;

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

		vel *= 0.9999;
	}


	override public function render () : Void {
		super.render();

		Draw.circle(Std.int(x), Std.int(y), Std.int(radius), 0xCC0000);
	}
}
