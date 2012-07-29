import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Draw;

class Activator extends Entity {
	var pitches:Array<Int>;
	public function new () {
		super();

		graphic = new Text("Sing a medium-pitched note to launch.",
		                   HXP.width/2, 350, 0, 0,
		                   { color: 0x000000 });
		cast(graphic, Text).centerOO();

		pitches = [];
		for (i in 0...15)
			pitches.push(0);
	}

	override public function update () : Void {
		pitches.shift();
		pitches.push(Pitch.getPitch());

		if (samplesNeeded() == 0) {
			G.paddle.calibrate(Math.round(avg(pitches)));

			// Remove next frame, because it looks weird if the bar
			// doesn't completely fill up.
			var self = this;
			HXP.tween(this, {}, 0.01, { complete: function () { world.remove(self); } });
		}
	}

	override public function render () : Void {
		super.render();

		var cx = Std.int(HXP.width/2);
		Draw.rect(cx-32, 375, 64, 14, 0x000000);
		Draw.rect(cx-30, 377, 60, 10, 0xFFFFFF);
		Draw.rect(cx-30, 377, (15 - samplesNeeded())*4, 10, 0xFF0000);
	}

	function samplesNeeded () : Int {
		var min = Math.POSITIVE_INFINITY;
		var max = Math.NEGATIVE_INFINITY;
		for (ii in 0...15) {
			var i = 14 - ii;
			var p = pitches[i];
			if (p == 0)
				return i+1;
			if (p < min)
				min = p;
			if (p > max)
				max = p;
			if (max - min > 3)
				return i+1;
		}
		return 0;
	}

	function avg (a:Array<Int>) : Float {
		var s = 0;
		for (i in 0...a.length)
			s += a[i];
		return s / a.length;
	}
}
