import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;

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

		var min = arrmin(pitches);
		var max = arrmax(pitches);
		if (max - min <= 3 && min > 0) {
			G.paddle.calibrate(Math.round(avg(pitches)));
			G.paddle.active = true;
			world.remove(this);
		}
	}

	function arrmin (a:Array<Int>) {
		var m:Int = a[0];
		for (i in 1...a.length)
			if (a[i] < m)
				m = a[i];

		return m;
	}

	function arrmax (a:Array<Int>) {
		var m:Int = a[0];
		for (i in 1...a.length)
			if (a[i] > m)
				m = a[i];

		return m;
	}

	function avg (a:Array<Int>) : Float {
		var s = 0;
		for (i in 0...a.length)
			s += a[i];
		return s / a.length;
	}
}
