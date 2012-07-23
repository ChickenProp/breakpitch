import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.World;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
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

	private var text:Text;

	public function new () : Void {
		super();
		heights = new ByteArray();
		pitches = [];

		player = new Paddle();
		add(player);

		text = new Text("", 250, 350, 200, 25,
		                {size: 24, color: 0xFFFFFF});
		addGraphic(text);
	}

	override public function render () : Void {
		super.render();

		for (x in [Paddle.maxIgnoredPitch,
		           Paddle.minPitch,
		           Paddle.maxPitch])
		{
			Draw.line(Std.int(x + 64), 150, Std.int(x + 64), 300,
			          0x00FF00);
		}

		var fft = Pitch.getFFT();
		var correl = Pitch.getCorrelation();
		var max = Pitch.getMaxIFFTVal();

		var mini = Std.int(intensity(max/4));
		Draw.line(64, 250+mini, 1000, 250+mini, 0x00FF00);

		for (i in 0 ... Std.int(Pitch.NUM_SAMPLES/2)) {
			var height = Std.int(intensity(fft[i]));
			var x = i + 64;
			var y = 200;

			Draw.line(x, y, x, y-height, 0xFFFFFF);

			height = Std.int(intensity(correl[i]));
			y = 250;
			Draw.line(x, y, x, y+height, 0xFFFFFF);
		}

		var pitch = Pitch.getPitch();

		pitches.push(pitch);
		if (pitches.length > 15)
			pitches.shift();

		for (i in 0 ... pitches.length) {
			var x = pitches[i] + 64;
			Draw.line(x, 200, x, 250, 0x110000 * i);
		}

		Draw.line(300, 400, 300, Std.int(400 - G.mic.activityLevel), 0xFFFFFFFF);
	}

	function intensity (x:Float) : Float {
		var SCALE = 20/Math.log(10);
		var intensity = SCALE * Math.log(x + MIN_VALUE) + 60;
		return Math.max(intensity, 0);
	}

	override public function update () : Void {
		super.update();
		if (Input.pressed(Key.SPACE))
			printPitch();
	}

	function printPitch () : Void {
		var p = Std.int(Pitch.getPitch() * 2.45);
		text.text = Std.format("$p kHz");
	}
}
