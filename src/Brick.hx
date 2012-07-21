import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.utils.Draw;

class Brick extends Entity {
	public var color:Int;
	public function new (x:Float, y:Float, color:Int) {
		super();
		this.x = x;
		this.y = y;

		width = 50;
		height = 20;
		centerOrigin();
		type = "solid";

		var image = new Image("gfx/brick.png");
		this.color = color;
		image.color = color;
		image.centerOO();
		
		graphic = image;
	}

	public function hit () : Void {
		type = "dying";
		var self = this;
		HXP.tween(graphic, {scale: 0}, 0.2,
		          {complete: function () { world.remove(self); }});

		var ball = cast(world, BreakoutWorld).ball;
		var score = 10 * ball.combo;
		G.score += score;
		world.add(new TextParticle(Std.string(score), x, y,
		                           ball.vel.x/10, ball.vel.y/10, 1.2));

		/*
		var pt = G.emitter.getParticleType("block").copy();
		var angle = Math.atan2(ball.vel.y, ball.vel.x);
		pt._angle = angle - pt._angleRange / 2;
		pt.setColor(color, color);
		for (i in 0...100)
			G.emitter.emitInRectangle(pt, left, top, width, height);
		*/

		MyParticle.add(x, y, ball.vel.x, ball.vel.y, color);
	}
}
