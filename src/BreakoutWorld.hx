import com.haxepunk.World;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;

class BreakoutWorld extends World {
	public var width:Int;
	public var height:Int;
	public var left(getLeft, null):Float;
	public var right(getRight, null):Float;
	public var top(getTop, null):Float;
	public var bottom(getBottom, null):Float;

	override public function begin () : Void {
		add(new Paddle());
		add(new Ball());
		width = 550;
		height = 450;

		addBricks();
	}

	override public function render () : Void {
		Draw.rect(Std.int( (HXP.width - width)/2 ),
		          HXP.height - height,
		          width, height,
		          0xCCCCFF);

		super.render();
	}

	public function addBricks () : Void {
		for (i in 0 ... 8) {
			for (j in 0 ... 11 - i%2) {
				add(new Brick(left + 25 + j*50 + (i%2)*25,
				              top + 10 + i*20,
				              Std.random(0x1000000)));
			}
		}
	}

	function getLeft () : Float { return (HXP.width - width) / 2; }
	function getRight () : Float { return (HXP.width + width) / 2; }
	function getTop () : Float { return HXP.height - height; }
	function getBottom () : Float { return HXP.height; }
}
