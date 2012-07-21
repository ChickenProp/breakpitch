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

		for (i in 0...30) {
			var px = left + Math.random()*width;
			var py = top + Math.random()*height;
			var vx = (px - ball.x)*0.1 + ball.vel.x * 0.2;
			var vy = (py - ball.y)*0.1 + ball.vel.y * 0.2;
			MyParticle.add(px, py, vx, vy, color);
		}
	}
}
