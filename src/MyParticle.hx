import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
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
		oldx = x;
		oldy = y;
		x += vx;
		y += vy;
		vy += 0.2;

		// Todo: replace with collision check that avoids tunelling.
		if (G.paddle.collidePoint(G.paddle.x, G.paddle.y, x, y)) {
			G.score += value;
			value++;
			vy = - Math.abs(vy) * 0.5;
			y = G.paddle.top;
			if (value > 5)
				recycle();
		}

		if (oldy > HXP.height)
			recycle();
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
}
