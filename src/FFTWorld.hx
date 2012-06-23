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
	private var micBytes:ByteArray;
	private var micSound:Sound;
	
	private var player:Paddle;
	
	private var fft:FFT2;
	private var ifft:FFT2;
	
	private var tmp:Vector<Float>;
	private var tmp2:Vector<Float>;
	private var real:Vector<Float>;
	private var imaginary:Vector<Float>;
	private var buffer:Vector<Float>;
	private var m_win:Vector<Float>;
	
	private static var SAMPLE_RATE:Float = 11025/2;	// Actual microphone sample rate (Hz)
	private static var LOGN:UInt = 11;				// Log2 FFT length
	private static var N:UInt = 1 << LOGN;			// FFT Length
	private static var BUF_LEN:UInt = N;				// Length of buffer for mic audio
	
	
	public static inline var MIN_VALUE = untyped __global__ ["Number"].MIN_VALUE;
	
	public function new () : Void {
		super();
		
		fft = new FFT2();
		fft.init(LOGN);
		
		ifft = new FFT2();
		ifft.init(Std.int(LOGN/2));
		
		heights = new ByteArray();
		pitches = [];
		micBytes = new ByteArray();
		micSound = new Sound();

		G.mic.setLoopBack(false);
		G.mic.gain = 60;
		G.mic.rate = Std.int(SAMPLE_RATE/1000);

		G.mic.addEventListener(SampleDataEvent.SAMPLE_DATA,
		                       micSampleDataHandler);
		/*micSound.addEventListener(SampleDataEvent.SAMPLE_DATA,
		                           soundSampleDataHandler);*/
		
		player = new Paddle();
		
		add(player);
		
		real = new Vector<Float>(N, true);
		imaginary = new Vector<Float>(N, true);
		buffer = new Vector<Float>(N, true);
		m_win = new Vector<Float>(N, true);
		tmp = new Vector<Float>(N, true);
		
		var i;
		for (i in 0 ... N) {
			buffer[i] = 0.0;
			m_win[i] = (4.0/N) * 0.5*(1-Math.cos(2*Math.PI*i/N));
		}
	}
	
	override public function update () : Void {
		super.update();
		
		var i;
		
		
	}

	override public function render () : Void {
		super.render();

		// We calculate pitch by simply getting the highest-intensity
		// band after excluding the lowest ones (which always seem to be
		// high-intensity). This shouldn't work, but it seems to anyway.

		//SoundMixer.computeSpectrum(heights, true, 1);
		
		var i = 0;
		var pos:UInt = m_writePos;
		
		for (i in 0 ... N) {
			real[i] = m_win[i]*buffer[pos];
			imaginary[i] = 0.0;
			pos = (pos+1)%BUF_LEN;
		}
		
		fft.run(real, imaginary);

		var total = 0;
		var pitch = 0;
		var maxIntensity = 0.0;
		
		var SCALE = 20/Math.log(10);
		
		i = 0;
		while (i < Std.int(N)) {
			tmp[i] = Math.sqrt(real[i]*real[i] + imaginary[i]*imaginary[i]);
			tmp[i] = SCALE*Math.log( tmp[i] + MIN_VALUE ) + 60;
			
			if (tmp[i] < 0) tmp[i] = 0;
			i++;
		}
	
		i = 0;
		
		while (i < Std.int(N)) {
			var intensity = tmp[i];
			
			var height = Std.int(intensity);
			var x = 2*i + 64;
			var y = 350;

			Draw.line(x, y, x, y-height, 0xFFFFFF);
			Draw.line(x+1, y, x+1, y-height, 0xFFFFFF);
			
			i++;
		}
		
		pitch = findCorrelation();
		
		i = 0;
		while (i < Std.int(N)) {
			//real[i] = Math.sqrt(real[i]*real[i] + imaginary[i]*imaginary[i]);
			//real[i] = SCALE*Math.log( real[i] + MIN_VALUE ) + 60;
			
			//if (real[i] < 0) real[i] = 0;
			i++;
		}
	
		var j;
		
		i = 0;
		
		while (i < Std.int(N)) {
			var intensity = real[i];//Math.sqrt(real[i]*real[i] + imaginary[i]*imaginary[i]);
			/*intensity = SCALE*Math.log( intensity + MIN_VALUE ) + 60;
			
			if (intensity < 0) intensity = 0;*/
			
			var height = Std.int(intensity*1000);
			var x = 2*i + 64;
			var y = 200;

			Draw.line(x, y, x, y-height, 0xFFFFFF);
			Draw.line(x+1, y, x+1, y-height, 0xFFFFFF);
			
			/*if (i > 8) {
				pitch += i * height;
				total += height;
			}*/

			i++;

			/*if (i > 1 && intensity > maxIntensity) {
				pitch = i;
				maxIntensity = intensity;
			}*/
		}
		
		//pitch = Std.int(pitch / total);

		Draw.line(pitch*2 + 64, 200, pitch*2+64, 200-100, 0xFF0000);
		
		pitches.push(pitch);
		if (pitches.length > 15)
			pitches.shift();

		/*Draw.line(80, 330, 170, 330, 0x00FF00);
		
		var total = 0;

		for (i in 0 ... pitches.length) {
			total += pitches[i];
			var color = 0x110000 * (i+1);
			var height = pitches[i]*2;
			Draw.line(100, 400-height, 150, 400-height, color);
			Draw.line(100, 401-height, 150, 401-height, color);
		}*/
		
		var value:Float = pitch;
		
		trace(value);
		
		if (value > 20) {
			if (value < 50) value = 50;
			if (value > 90) value = 90;
		
			value -= 70;
		
			player.vel += value * 0.1;
			
			if (player.vel < -10) player.vel = -10;
			if (player.vel > 10) player.vel = 10;
			
			//if (player.x < 0) player.x = 0;
			//if (player.x > 600 - 50) player.x = 550;
		}
		
		Draw.line(300, 400, 300, Std.int(400 - G.mic.activityLevel), 0xFFFFFFFF);
	}
	
	private function findCorrelation (): UInt
	{
		var i;
		var len = Std.int(N);
		
		for (i in 0 ... len) {
			tmp[i] = Math.sqrt(real[i] * real[i] + imaginary[i]*imaginary[i]);
		}
		
		for (i in 0 ... len) {
			real[i] = tmp[i];
			imaginary[i] = 0.0;
		}
		
		ifft.run(real, imaginary, true);
		
		for (i in 10 ... Std.int(len/2)) {
			if (real[i] > 0.004) return i;
		}
		
		return 0;
	}
	
	/*private function findCorrelation (a:Vector<Float>): UInt
	{
		var len:Int = Std.int(a.length/2);
		var i;
		var j;
		
		var prevDx = 0.0;
		var prevDiff=0.0;
		var maxDiff=0.0;
		
		for ( i in 0 ... len ) {
			var diff = 0.0;
			for ( j in 0 ... len ) {
				diff += Math.abs(a[j]-a[i+j]);
			}

			//graph1.add(diff);

			var dx = prevDiff-diff;

			// change of sign in dx
			if ( dx < 0 && prevDx > 0 ) {
				// only look for troughs that drop to less than 10% of peak
				if ( diff < (0.1*maxDiff) ) {
					//graph1.mark(i-1);
					
					return i - 1;
				}
			}

			prevDx = dx;
			prevDiff=diff;
			maxDiff=Math.max(diff,maxDiff);
		}
		
		return 0;
	}*/
	
	private var m_writePos:UInt;
	
	private function micSampleDataHandler(event:SampleDataEvent) : Void {
		// Get number of available input samples
		var len = Std.int(event.data.length/4);
		
		// Read the input data and stuff it into 
		// the circular buffer
		var i;
		for (i in 0 ... len)
		{
			buffer[m_writePos] = event.data.readFloat();
			m_writePos = (m_writePos+1)%BUF_LEN;
		}
        }
}
