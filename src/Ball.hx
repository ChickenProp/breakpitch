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
		width = 10;
		height = 10;
		centerOrigin();

		vel = new Point(5, 7);
	}

	override public function update () : Void {
		moveBy(vel.x, vel.y, "solid");

		var bw = cast(world, BreakoutWorld);

		if (x + halfWidth > bw.right) {
			x = bw.right - halfWidth;
			vel.x = - Math.abs(vel.x);
		}
		else if (x - halfWidth < bw.left) {
			x = bw.left + halfWidth;
			vel.x = Math.abs(vel.x);
		}

		if (y + halfHeight > bw.bottom) {
			y = bw.bottom - halfHeight;
			vel.y = - Math.abs(vel.y);
		}
		else if (y - halfHeight < bw.top) {
			y = bw.top + halfHeight;
			vel.y = Math.abs(vel.y);
		}
	}


	override public function render () : Void {
		super.render();

		Draw.rect(Std.int(x - halfWidth), Std.int(y - halfHeight),
		          width, height, 0xFF0000);
	}

	override public function moveCollideX (e) : Void {
		vel.x = -vel.x;

		if (Std.is(e, Brick))
			hitBrick(e);
	}

	override public function moveCollideY (e:Entity) : Void {
		if (Std.is(e, Paddle))
			hitPaddle(e);
		else {
			hitBrick(e);
			vel.y = -vel.y;
		}
	}

	// This needs a lot of tweaking to make it feel good, and currently the
	// ball keeps getting faster which is really bad.
	public function hitPaddle(e:Entity) : Void {
		var p = cast(e, Paddle);
		var maxVY = 20;
		var minVY = 5;
		var maxVX = 20;

		var offx = (x - p.x)/p.halfWidth;
		var newvelx = vel.x + p.vel * 0.2 + offx * 5;
		var newvely = Math.sqrt(Math.max(vel.x*vel.x + vel.y*vel.y - newvelx*newvelx, 0));
		newvely = Math.min(maxVY, Math.max(minVY, newvely));
		newvelx = Math.min(maxVX, newvelx);

		vel.x = newvelx;
		vel.y = - sign(vel.y) * newvely;
	}

	public function sign(x:Float) : Int {
		return if (x<0) -1 else if (x > 0) 1 else 0;
	}

	public function hitBrick(e:Entity) : Void {
		cast(e, Brick).hit();
	}
}
