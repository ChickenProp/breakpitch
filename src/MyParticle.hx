import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import nme.geom.Point;
using Lambda;

class MyParticle {
	public var x:Float;
	public var y:Float;
	public var oldx:Float;
	public var oldy:Float;
	public var vx:Float;
	public var vy:Float;
	public var color:Int;
	public var value:Int;
	public var dead:Bool;

	public var recycleNext:MyParticle;

	public function new () {}

	inline public function update () : Void {
		if (collides()) {
			x = collision.x;
			y = collision.y;
			vy = - Math.abs(vy) * 0.5;
			Audio.rainVolume += 0.1;
			G.score += value;
			value++;
			if (value > 5)
				recycle();
		}
		else {
			oldx = x;
			oldy = y;
			x += vx;
			y += vy;
			vy += 0.2;

			if (oldy > HXP.height)
				recycle();
		}
	}

	inline public function render () : Void {
		Draw.line(Std.int(oldx), Std.int(oldy), Std.int(x), Std.int(y), color);
	}

	// NB. does not remove from active list.
	public function recycle () : Void {
		recycleNext = recycleFirst;
		recycleFirst = this;
		dead = true;
	}

	public static var recycleFirst:MyParticle = null;
	public static var particles:Array<MyParticle> = [];

	public static function add(x:Float, y:Float, vx:Float, vy:Float, color:Int) {
		var p:MyParticle;
		if (recycleFirst != null) {
			p = recycleFirst;
			recycleFirst = p.recycleNext;
		}
		else
			p = new MyParticle();

		p.x = p.oldx = x;
		p.y = p.oldy = y;
		p.vx = vx;
		p.vy = vy;
		p.color = color;
		p.value = 1;
		p.dead = false;

		particles.push(p);
	}

	public static function updateAll () : Void {
		// We don't use a map() here or in renderAll() because
		// presumably that couldn't be inlined.
		for (i in 0...particles.length)
			particles[i].update();

		particles = particles.filter(function (p) { return !p.dead; }).array();
	}

	public static function renderAll () : Void {
		for (i in 0...particles.length)
			particles[i].render();
	}

	public static function clear () : Void {
		for (i in 0...particles.length) {
			particles[i].recycleNext = recycleFirst;
			recycleFirst = particles[i];
		}

		particles = [];
	}

	// We use the Liang-Barsky algorithm to check whether the particle
	// collides with the paddle. If it does, the variable "collision" is set
	// to the collision point. Call this before attempting to move the
	// particle, so that (x, y) is its original positions and it is trying
	// to move to (x+vy, y+vy). https://gist.github.com/3194723
	static var collision = new Point(0, 0);
	public function collides () : Bool {
		var left = G.paddle.left;
		var right = G.paddle.right;
		var top = G.paddle.top;
		var bottom = G.paddle.bottom;

		var p = [-vx, vx, -vy, vy];
		var q = [x - left, right - x, y - top, bottom - y];
		var u1 = Math.NEGATIVE_INFINITY;
		var u2 = Math.POSITIVE_INFINITY;

		for (i in 0...4) {
			if (p[i] == 0) {
				if (q[i] < 0)
					return false;
			}
			else {
				var t = q[i] / p[i];
				if (p[i] < 0 && u1 < t)
					u1 = t;
				else if (p[i] > 0 && u2 > t)
					u2 = t;
			}
		}

		if (u1 > u2 || u1 > 1 || u1 < 0)
			return false;

		collision.x = x + u1*vx;
		collision.y = y + u1*vy;

		return true;
	}
}
