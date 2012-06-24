import com.haxepunk.Entity;
import com.haxepunk.utils.Draw;
import com.haxepunk.HXP;
import nme.geom.Point;

class Ball extends Entity {
	var vel:Point;
	var radius:Int;
	var scale:Float;
	var launched:Bool;
	public var dead:Bool;

	public function new () {
		super();

		x = HXP.width / 2;
		y = HXP.height / 2;
		width = 10;
		height = 10;
		scale = 1;
		centerOrigin();
		type = "ball";

		vel = new Point(0, 0);
		dead = false;
	}

	override public function update () : Void {
		if (!launched)
			return;

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
			dead = true;
		}
		else if (y - halfHeight < bw.top) {
			y = bw.top + halfHeight;
			vel.y = Math.abs(vel.y);
			bounceSize();
		}
		
		var maxVY = 10;
		var minVY = 5;
		var maxVX = 5;
		
		var dx = if (vel.x < 0) -1 else 1;
		var dy = if (vel.y < 0) -1 else 1;
		
		if (dx*vel.x > maxVX) vel.x = dx*maxVX;
		if (dx*vel.y > maxVY) vel.y = dy*maxVY;
		if (dy*vel.y < minVY) vel.y = dy*minVY;
	}

	public function launch () : Void {
		if (!launched) {
			vel.y = 8;
			vel.x = cast(world, BreakoutWorld).paddle.vel;
		}
		launched = true;
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
		else
			Audio.play("bounce");
		
		if (Std.is(e, Paddle))
			if (vel.y > 0) vel.y = -vel.y;
	}

	override public function moveCollideY (e:Entity) : Void {
		bounceSize();
		if (Std.is(e, Paddle)) {
			hitPaddle(e);
			Audio.play("bounce");
		} else {
			hitBrick(e);
			vel.y = -vel.y;
		}
	}

	// This needs a lot of tweaking to make it feel good, and currently the
	// ball keeps getting faster which is really bad.
	public function hitPaddle(e:Entity) : Void {
		var p = cast(e, Paddle);
		
		y = p.y - p.halfHeight - halfHeight;

		var maxVY = 20;
		var minVY = 5;
		
		var offx = (x - p.x)/p.halfWidth;
		var newvelx = vel.x + p.vel * 0.2 + offx * 5;
		var newvely = Math.sqrt(Math.max(vel.x*vel.x + vel.y*vel.y - newvelx*newvelx, 0));
		newvely = Math.min(maxVY, Math.max(minVY, newvely));

		vel.x = newvelx;
		vel.y = -newvely;
	}

	public function sign(x:Float) : Int {
		return if (x<0) -1 else if (x > 0) 1 else 0;
	}

	public function hitBrick(e:Entity) : Void {
		cast(e, Brick).hit();
		Audio.play("brick");
	}

	public function bounceSize () : Void {
		var ease = function (t) {
			return 0.5 * (Math.cos(x * 2 * Math.PI) - 1);
		}

		scale = 1.2;
		HXP.tween(this, {scale: 1.0}, 0.2, { ease: ease });
		
		Audio.play("bounce");
	}
}
