import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Draw;

class Activator extends Entity {
	var pitches:Array<Int>;
	var remove:Bool;
	public function new () {
		super();

		graphic = new Text("Sing a medium-pitched note to launch.",
		                   HXP.width/2, 380, 0, 0,
		                   { color: 0x000000 });
		cast(graphic, Text).centerOO();

		pitches = [];
		for (i in 0...15)
			pitches.push(0);

		remove = false;
	}

	override public function update () : Void {
		if (remove) {
			HXP.tween(G.paddle, {lineWidth:2}, 0.2);
			world.remove(this);
			return;
		}
		pitches.shift();
		pitches.push(Pitch.getPitch());
		G.paddle.lineWidth = 2 + (G.paddle.width - 6)*(15-samplesNeeded())/15;

		// We tell it to remove next frame, because it looks weird if
		// the bar never fills all the way up. I think actually this
		// means we get two frames of being full because it doesn't
		// actually get removed until the end of the frame that remove
		// is called. At any rate, it looks nicer.
		if (samplesNeeded() == 0) {
			G.paddle.calibrate(Math.round(avg(pitches)));
			remove = true;
		}
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
