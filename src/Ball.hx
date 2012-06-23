import com.haxepunk.Entity;
import com.haxepunk.utils.Draw;
import com.haxepunk.HXP;
import nme.geom.Point;

class Ball extends Entity {
	var vel:Point;
	var radius:Int;
	var scale:Float;

	public function new () {
		super();

		x = HXP.width / 2;
		y = HXP.height / 2;
		width = 10;
		height = 10;
		scale = 1;
		centerOrigin();

		vel = new Point(5, 7);
	}

	override public function update () : Void {
		moveBy(vel.x, vel.y, "solid");

		var bw = cast(world, BreakoutWorld);

		if (x + halfWidth > bw.right) {
			x = bw.right - halfWidth;
			vel.x = - Math.abs(vel.x);
			bounceSize();
		}
		else if (x - halfWidth < bw.left) {
			x = bw.left + halfWidth;
			vel.x = Math.abs(vel.x);
			bounceSize();
		}

		if (y + halfHeight > bw.bottom) {
			y = bw.bottom - halfHeight;
			vel.y = - Math.abs(vel.y);
			bounceSize();
		}
		else if (y - halfHeight < bw.top) {
			y = bw.top + halfHeight;
			vel.y = Math.abs(vel.y);
			bounceSize();
		}
		
		var maxVY = 20;
		var minVY = 5;
		var maxVX = 10;
		
		var dx = if (vel.x < 0) -1 else 1;
		var dy = if (vel.y < 0) -1 else 1;
		
		if (dx*vel.x > maxVX) vel.x = dx*maxVX;
		if (dx*vel.y > maxVY) vel.y = dy*maxVY;
		if (dy*vel.y < minVY) vel.y = dy*minVY;
	}


	override public function render () : Void {
		super.render();

		Draw.rect(Std.int(x - halfWidth*scale),
		          Std.int(y - halfHeight*scale),
		          Std.int(width * scale), Std.int(height * scale),
		          0xFF0000);
	}

	override public function moveCollideX (e) : Void {
		bounceSize();
		vel.x = -vel.x;

		if (Std.is(e, Brick))
			hitBrick(e);
	}

	override public function moveCollideY (e:Entity) : Void {
		bounceSize();
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
		var maxVX = 8;
		
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

	public function bounceSize () : Void {
		var ease = function (t) {
			return 0.5 * (Math.cos(x * 2 * Math.PI) - 1);
		}

		scale = 1.2;
		HXP.tween(this, {scale: 1.0}, 0.2, { ease: ease });
	}
}
