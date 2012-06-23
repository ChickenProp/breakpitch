import com.haxepunk.Entity;
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

		this.color = color;
	}

	override public function render () : Void {
		super.render();

		Draw.rect(Std.int(x - halfWidth), Std.int(y - halfHeight),
		          width, height, color);
	}
}
