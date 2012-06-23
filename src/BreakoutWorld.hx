import com.haxepunk.World;

class BreakoutWorld extends World {
	override public function begin () : Void {
		add(new Paddle());
	}
}
