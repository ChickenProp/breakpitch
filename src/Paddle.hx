import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;

class Paddle extends Entity {
	public function new () {
		super();

		x = HXP.width / 2;
		y = HXP.height - 50;
		width = 40;
		height = 10;
		centerOrigin();
	}

	override public function render () : Void {
		super.render();

		Draw.rect(Std.int(x - halfWidth), Std.int(y - halfHeight),
		          width, height, 0x0000CC);
	}
}
