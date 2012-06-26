import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;
import nme.geom.Point;

class TextParticle extends Entity {
	var vel:Point;
	var alpha:Float;
	public function new (text:String, x:Float, y:Float,
	                     vx:Float, vy:Float, time:Float)
	{
		super();

		this.x = x;
		this.y = y;
		centerOrigin();
		this.vel = new Point(vx, vy);

		var image = new Text(text);
		image.centerOO();
		image.color = 0x000000;
		graphic = image;

		// We can't tween image.alpha because it uses a getter/setter,
		// so we have to use our own property instead.
		alpha = 1;
		var self = this;
		HXP.tween(this, {alpha: 0}, time,
		          {complete: function () { world.remove(self); }});
	}

	override public function update () : Void {
		x += vel.x;
		y += vel.y;
		cast(graphic, Text).alpha = alpha;
	}
}







