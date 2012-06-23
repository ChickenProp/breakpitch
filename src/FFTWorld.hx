import com.haxepunk.World;
import com.haxepunk.utils.Draw;
import flash.media.SoundMixer;
import flash.utils.ByteArray;
import flash.events.SampleDataEvent;
import flash.media.Sound;

class FFTWorld extends World {
	public var heights:ByteArray;
	private var micBytes:ByteArray;
	private var micSound:Sound;
	public function new () : Void {
		super();
		heights = new ByteArray();
		micBytes = new ByteArray();
		micSound = new Sound();

		G.mic.setLoopBack(false);
		G.mic.rate = 44;
		G.mic.gain = 60;

		G.mic.addEventListener(SampleDataEvent.SAMPLE_DATA,
		                       micSampleDataHandler);
		micSound.addEventListener(SampleDataEvent.SAMPLE_DATA,
		                           soundSampleDataHandler);
	}

	override public function render () : Void {
		super.render();

		SoundMixer.computeSpectrum(heights, true);

		var i = 0;
		while (heights.bytesAvailable != 0 && i < 256) {
			var height = heights.readFloat();
			Draw.line(i + 180, 300,
			          i+180, Std.int(300-100*height),
			          0xFFFFFF);
			i++;
		}
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
