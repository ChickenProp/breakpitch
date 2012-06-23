import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;

class Brick extends Entity {
	public var color:Int;
	public var size:Float;
	public function new (x:Float, y:Float, color:Int) {
		super();
		this.x = x;
		this.y = y;

		width = 50;
		height = 20;
		centerOrigin();
		type = "solid";

		this.color = color;
		size = 1;
	}

	public function hit () : Void {
		type = "dying";
		var self = this;
		HXP.tween(this, {size: 0}, 0.2,
		          {complete: function () { world.remove(self); }});
	}

	override public function render () : Void {
		super.render();

		Draw.rect(Std.int(x - halfWidth*size),
		          Std.int(y - halfHeight*size),
		          Std.int(width*size),
		          Std.int(height*size),
		          color);
	}
}
