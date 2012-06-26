import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.utils.Draw;

class Brick extends Entity {
	public function new (x:Float, y:Float, color:Int) {
		super();
		this.x = x;
		this.y = y;

		width = 50;
		height = 20;
		centerOrigin();
		type = "solid";

		var image = new Image("gfx/brick.png");
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
		world.add(new TextParticle(Std.string(score), x, y,
		                           ball.vel.x/10, ball.vel.y/10, 0.3));
	}
}
