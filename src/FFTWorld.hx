import com.haxepunk.Entity;
import com.haxepunk.World;
import com.haxepunk.utils.Draw;
import com.haxepunk.graphics.Image;
import flash.media.SoundMixer;
import flash.utils.ByteArray;
import flash.events.SampleDataEvent;
import flash.media.Sound;

class FFTWorld extends World {
	public var heights:ByteArray;
	public var pitches:Array<Int>;
	private var micBytes:ByteArray;
	private var micSound:Sound;
	
	private var player:Paddle;
	
	public function new () : Void {
		super();
		heights = new ByteArray();
		pitches = [];
		micBytes = new ByteArray();
		micSound = new Sound();

		G.mic.setLoopBack(false);
		G.mic.rate = 44;
		G.mic.gain = 60;

		G.mic.addEventListener(SampleDataEvent.SAMPLE_DATA,
		                       micSampleDataHandler);
		micSound.addEventListener(SampleDataEvent.SAMPLE_DATA,
		                           soundSampleDataHandler);
		
		player = new Paddle();
		
		add(player);
	}

	override public function render () : Void {
		super.render();

		// We calculate pitch by simply getting the highest-intensity
		// band after excluding the lowest ones (which always seem to be
		// high-intensity). This shouldn't work, but it seems to anyway.

		SoundMixer.computeSpectrum(heights, true, 1);

		var total = 0;
		var pitch = 0;
		var maxIntensity = 0.0;
		var i = 0;
		while (heights.bytesAvailable != 0 && i < 256) {
			var intensity = heights.readFloat();
			var height = Std.int(100 * intensity);
			var x = 2*i + 64;
			var y = 200;

			Draw.line(x, y, x, y-height, 0xFFFFFF);
			Draw.line(x+1, y, x+1, y-height, 0xFFFFFF);
			
			pitch += i * height;
			total += height;

			i++;

			/*if (i > 1 && intensity > maxIntensity) {
				pitch = i;
				maxIntensity = intensity;
			}*/
		}
		
		pitch = Std.int(pitch / total);

		pitches.push(pitch);
		if (pitches.length > 15)
			pitches.shift();

		Draw.line(80, 330, 170, 330, 0x00FF00);
		
		var total = 0;

		for (i in 0 ... pitches.length) {
			total += pitches[i];
			var color = 0x110000 * (i+1);
			var height = pitches[i]*2;
			Draw.line(100, 400-height, 150, 400-height, color);
			Draw.line(100, 401-height, 150, 401-height, color);
		}
		
		var value:Float = pitch;
		
		trace(value);
		
		if (value > 0) {
			if (value < 10) value = 10;
			if (value > 14) value = 14;
		
			value -= 12;
		
			player.vel += value;
			
			if (player.vel < -15) player.vel = -15;
			if (player.vel > 15) player.vel = 15;
			
			//if (player.x < 0) player.x = 0;
			//if (player.x > 600 - 50) player.x = 550;
		}
		
		Draw.line(300, 400, 300, Std.int(400 - G.mic.activityLevel), 0xFFFFFFFF);
	}

	private function micSampleDataHandler(event:SampleDataEvent) : Void {
		micBytes = event.data;
		// I'm not sure why, but this needs to be called every frame.
		micSound.play();
        }

	private function soundSampleDataHandler(event:SampleDataEvent):Void {
		var i = 0;
		while (micBytes.bytesAvailable != 0 && i < 8192) {
			var sample = micBytes.readFloat();
			event.data.writeFloat(sample);
			event.data.writeFloat(sample);
			i++;
		}
	}
}
