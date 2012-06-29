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

	private static var SAMPLE_RATE:Float = 11025/2;	// Actual microphone sample rate (Hz)
	private static var LOGN:UInt = 11;				// Log2 FFT length
	private static var N:UInt = 1 << LOGN;			// FFT Length
	private static var BUF_LEN:UInt = N;				// Length of buffer for mic audio
	
	
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

		var SCALE = 20/Math.log(10);

		for (i in 0 ... Std.int(N)) {
			var intensity = SCALE * Math.log(fft[i]+MIN_VALUE) + 60;
			if (intensity < 0)
				intensity = 0;

			var height = Std.int(intensity);
			var x = 2*i + 64;
			var y = 200;

			Draw.line(x, y, x, y-height, 0xFFFFFF);
			Draw.line(x+1, y, x+1, y-height, 0xFFFFFF);
		}

		var pitch = Pitch.getPitch();
		Draw.line(pitch*2 + 64, 200, pitch*2+64, 250, 0xFF0000);

		pitches.push(pitch);
		if (pitches.length > 15)
			pitches.shift();

		Draw.line(300, 400, 300, Std.int(400 - G.mic.activityLevel), 0xFFFFFFFF);
	}
}
