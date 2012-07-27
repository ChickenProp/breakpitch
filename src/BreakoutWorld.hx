import com.haxepunk.World;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import nme.display.BitmapData;
import nme.geom.ColorTransform;
import nme.geom.Point;
using Lambda;

class BreakoutWorld extends World {
	public var width:Int;
	public var height:Int;
	public var left(getLeft, null):Float;
	public var right(getRight, null):Float;
	public var top(getTop, null):Float;
	public var bottom(getBottom, null):Float;

	public var level:Int;
	public var seeds:Array<Int>;
	public var paddle:Paddle;
	public var ball:Ball;
	public var ballsLeft:Int;

	public var fadeAlpha:Float;

	public function new (level:Int) {
		super();
		this.level = level;
		width = 550;
		height = 450;
		ballsLeft = 3;

		seeds = [8, 10, 4, 5, 6, 7, 9, 26, 11, 14];

		addGraphic(G.emitter).layer = HXP.BASELAYER - 1;

		// Draw.line draws on the edges of the buffer if it's supposed
		// to be offscreen, so we make it large enough that we can't see
		// stuff drawn on the edges.
		blurBuffer = new BitmapData(HXP.width + 20, HXP.height + 20,
		                            true, 0x00000000);
		colorTransform = new ColorTransform(1, 1, 1, 0.8);
		bbOffset = new Point(-10, -10);
	}

	override public function update () : Void {
		super.update();

		if (Main.debugMode) {
			// Reset doesn't reset properly if we're not on a fixed
			// level (i.e. one with a specified seed). Oh well.
			if (Input.check(Key.R))
				HXP.world = new BreakoutWorld(level);
			if (Input.pressed(Key.UP))
				HXP.world = new BreakoutWorld(level + 1);
			if (Input.pressed(Key.DOWN))
				HXP.world = new BreakoutWorld(level - 1);
			if (Input.pressed(Key.F))
				HXP.world = new FFTWorld();

			if (Input.pressed(Key.F6)) {
				var bricks = [];
				getClass(Brick, bricks);
				for (b in bricks)
					cast(b, Brick).hit();
			}
		}

		var bricks = [];
		getClass(Brick, bricks);
		if (bricks.length == 0)
			win();

		if (ball.dead) {
			remove(ball);
			ballsLeft--;

			if (ballsLeft == 0) {
				var newworld = function () {
					HXP.world = new BreakoutWorld(0);
				};
				var stayblank = function () {
					HXP.tween(this, {fadeAlpha: 1}, 0.5,
					         { complete: newworld });
				};
				HXP.tween(this, {fadeAlpha: 1}, 0.5,
				          { complete: stayblank });
			}
			else
				placeBall();
		}

		MyParticle.updateAll();
	}

	public function win () : Void {
		Audio.play("win");
		level++;
		ballsLeft++;
		addBricks(getSeed());
	}

	public function getSeed () : Int {
		if (level < seeds.length)
			return seeds[level];
		else {
			var disallowed = [0, 1, 16, 17]; // these look bad.
			while(true) {
				var seed = Std.random(32);
				if (disallowed.indexOf(seed) == -1)
					return seed;
			}
			return 0;
		}
	}

	override public function begin () : Void {
		G.score = 0;
		add(new ScoreDisplay());
		paddle = G.paddle = new Paddle();
		add(paddle);
		placeBall();
		MyParticle.clear();

		var seed:Int = 0;
		if (level < seeds.length)
			seed = seeds[level];
		else {
			var disallowed = [0, 1, 16, 17]; // these look bad.
			while(disallowed.indexOf(seed) != -1)
				seed = Std.random(32);
		}
		addBricks(seed);

		fadeAlpha = 1;
		HXP.tween(this, {fadeAlpha: 0}, 0.5);
	}

	public function placeBall () : Void {
		ball = new Ball();
		add(ball);
		paddle.recenter();
	}

	var blurBuffer:BitmapData;
	var colorTransform:ColorTransform;
	var bbOffset:Point;
	override public function render () : Void {
		Draw.rect(Std.int( (HXP.width - width)/2 ),
		          HXP.height - height,
		          width, height,
		          0xCCCCFF);

		for (i in 0 ... ballsLeft-1) {
			Draw.rect(10 + 20*i, 10, 10, 10, 0xFF0000);
		}

		super.render();

		// The particles and the ball leave a trail behind. We do this
		// by drawing them onto a seperate buffer which gets partially
		// erased every frame, and copying the buffer onto the
		// screen. We want particles to be on top of other stuff, so
		// this gets called after drawing everything else. But the ball
		// isn't the same colour as its trail, so we draw it twice, once
		// onto the blur buffer and once onto the real thing; that one
		// has to happen after copying the blur buffer. Since Ball
		// doesn't know about the blur buffer, we have to do all the
		// rendering for it here instead of in the Ball class.
		blurBuffer.colorTransform(blurBuffer.rect, colorTransform);
		Draw.setTarget(blurBuffer, bbOffset);
		MyParticle.renderAll();
		Draw.rect(Std.int(ball.left), Std.int(ball.top),
		          ball.width, ball.height, 0xFF8080);
		HXP.buffer.copyPixels(blurBuffer, blurBuffer.rect, bbOffset,
		                      null, null, true);
		Draw.resetTarget();
		Draw.rect(Std.int(ball.left), Std.int(ball.top),
		          ball.width, ball.height, 0xFF0000);

		Draw.rect(0, 0, HXP.width, HXP.height,
		          Main.kClearColor, fadeAlpha);
	}

	// Each level is horizontally and vertically symmetric. Each row has
	// either 10 or 11 blocks (staggered), and there are seven rows. The
	// top-left corner is indexed by i,j where y is a function of j and x is
	// a function of i and j%2. j takes values 0 to 3, and i takes values 0
	// to 4 or 0 to 5 depending on j%2.
	public function addBricks (seed:Int) : Void {
		for (j in 0 ... 4) {
			for (i in 0 ... 5 + j%2) {
				if (seed & ((i+1)*(j+1)) != 0)
					addBrickSymmetric(i, j);
			}
		}
	}

	public function addBrickSymmetric(i:Int, j:Int) : Void {
		// offsets: half-{width,height} plus offsets based on i,j.
		var xoff = 25 + i*50 + (1 - j%2)*25;
		var yoff = 10 + j*20;

		var btop = top;
		var bbot = btop + 7*20;

		var color = Std.random(0x1000000);
		addBrick(left + xoff, btop + yoff, color);
		if (i != 5)
			addBrick(right - xoff, btop + yoff, color);
		if (j != 3)
			addBrick(left + xoff, bbot - yoff, color);
		if (j != 3 && i != 5)
			addBrick(right - xoff, bbot - yoff, color);
	}

	public function addBrick(x:Float, y:Float, color:Int) : Void {
		var dropheight = top + 7*20;
		var b = new Brick(x, y-dropheight, color);
		HXP.tween(b, {y: y}, 0.4 + Math.random()/5, {ease: bounceEase});
		add(b);
	}

	public function bounceEase (t:Float) : Float {
		var peak = 0.7;
		if (t < peak)
			return 1.2 * Math.sin(Math.PI*t / 1.6);
		else {
			var phase = (t - peak) / (1 - peak); // [0, 1]
			return 1.2 - 0.1 * (1 - Math.cos(Math.PI * phase));
		}
	}

	function getLeft () : Float { return (HXP.width - width) / 2; }
	function getRight () : Float { return (HXP.width + width) / 2; }
	function getTop () : Float { return HXP.height - height; }
	function getBottom () : Float { return HXP.height; }
}
