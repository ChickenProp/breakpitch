import com.haxepunk.Entity;
import com.haxepunk.World;
import com.haxepunk.utils.Draw;
import com.haxepunk.graphics.Image;
import flash.media.SoundMixer;
import flash.utils.ByteArray;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.Vector;

class FFTWorld extends World {
	public var heights:ByteArray;
	public var pitches:Array<Int>;

	private var player:Paddle;

	public static inline var MIN_VALUE = untyped __global__ ["Number"].MIN_VALUE;

	public function new () : Void {
		super();
		heights = new ByteArray();
		pitches = [];

		player = new Paddle();
		add(player);
	}

	override public function render () : Void {
		super.render();

		var fft = Pitch.getFFT();
		var correl = Pitch.getCorrelation();

		for (i in 0 ... Pitch.NUM_SAMPLES) {
			var height = Std.int(intensity(fft[i]));
			var x = 2*i + 64;
			var y = 200;

			Draw.line(x, y, x, y-height, 0xFFFFFF);
			Draw.line(x+1, y, x+1, y-height, 0xFFFFFF);

			height = Std.int(intensity(correl[i]));
			y = 250;
			Draw.line(x, y, x, y+height, 0xFFFFFF);
			Draw.line(x+1, y, x+1, y+height, 0xFFFFFF);
		}

		var pitch = Pitch.getPitch();

		pitches.push(pitch);
		if (pitches.length > 15)
			pitches.shift();

		for (i in 0 ... pitches.length) {
			var x = pitches[i] * 2 + 64;
			Draw.line(x, 200, x, 250, 0x110000 * i);
		}

		Draw.line(300, 400, 300, Std.int(400 - G.mic.activityLevel), 0xFFFFFFFF);
	}

	function intensity (x:Float) : Float {
		var SCALE = 20/Math.log(10);
		var intensity = SCALE * Math.log(x + MIN_VALUE) + 60;
		return Math.max(intensity, 0);
	}
}
