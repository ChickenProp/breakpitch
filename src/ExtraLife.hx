import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.tweens.misc.MultiVarTween;

class ExtraLife extends Entity {
	var tween:MultiVarTween;
	public static var count = 0;
	public function new () {
		super();

		x = 20*count + 10;
		y = -10;
		graphic = Image.createRect(10, 10, 0xFF0000);

		tween = HXP.tween(this, {y: 10}, 0.4 + Math.random()/5,
		                  { ease: G.bounceEase });
		count++;
	}

	public function die () {
		count--;
		tween.active = false; // It would interfere.
		var self = this;
		HXP.tween(this, {y: HXP.height}, 0.5,
		          { ease: function (t:Float) { return t*t; },
		            complete: function () { world.remove(self); } });
	}
}
