import flash.utils.ByteArray;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.Vector;

class Pitch {
	private static var needFft:Bool;

	private static var fft:FFT2;
	private static var ifft:FFT2;
	
	private static var real:Vector<Float>;
	private static var imaginary:Vector<Float>;
	private static var buffer:Vector<Float>;
	private static var m_win:Vector<Float>;
	
	private static var micBytes:ByteArray;
	private static var m_writePos:UInt;
	
	private static var SAMPLE_RATE:Float = 11025/2;	// Actual microphone sample rate (Hz)
	private static var LOGN:UInt = 11;				// Log2 FFT length
	private static var N:UInt = 1 << LOGN;			// FFT Length
	private static var BUF_LEN:UInt = N;				// Length of buffer for mic audio
	
	
	public static inline var MIN_VALUE = untyped __global__ ["Number"].MIN_VALUE;
	
	public static function init ():Void
	{
		needFft = true;

		fft = new FFT2();
		fft.init(LOGN);
		
		ifft = new FFT2();
		ifft.init(Std.int(LOGN/2));
		
		micBytes = new ByteArray();

		G.mic.setLoopBack(false);
		G.mic.gain = 60;
		G.mic.rate = Std.int(SAMPLE_RATE/1000);

		G.mic.addEventListener(SampleDataEvent.SAMPLE_DATA,
		                       micSampleDataHandler);
		
		real = new Vector<Float>(N, true);
		imaginary = new Vector<Float>(N, true);
		buffer = new Vector<Float>(N, true);
		m_win = new Vector<Float>(N, true);

		var i;
		for (i in 0 ... N) {
			buffer[i] = 0.0;
			m_win[i] = (4.0/N) * 0.5*(1-Math.cos(2*Math.PI*i/N));
		}
	}

	public static function runFFT () : Void {
		if (! needFft)
			return;

		var i = 0;
		var pos:UInt = m_writePos;

		for (i in 0 ... N) {
			real[i] = m_win[i]*buffer[pos];
			imaginary[i] = 0.0;
			pos = (pos+1)%BUF_LEN;
		}

		fft.run(real, imaginary);

		var len = Std.int(N);

		for (i in 0 ... len) {
			real[i] = Math.sqrt(real[i] * real[i] + imaginary[i]*imaginary[i]);
			imaginary[i] = 0.0;
			//trace(Std.format("$i: ${real[i]}"));
		}

		needFft = false;
	}

	public static function getPitch (): Int
	{
		runFFT();

		ifft.run(real, imaginary, true);
		
		for (i in 10 ... Std.int(N/2)) {
			if (real[i] > 0.004) return i;
		}
		
		return 0;
	}

	public static function getFFT () : Vector<Float> {
		runFFT();
		return real;
	}

	private static function micSampleDataHandler(event:SampleDataEvent) : Void {
		trace("hi1");
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

		needFft = true;
		trace("hi");
        }
}


