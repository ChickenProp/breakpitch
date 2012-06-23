class FFTElement
{
	public var re:Float;			// Real component
	public var im:Float;			// Imaginary component
	public var next:FFTElement;	// Next element in linked list
	public var revTgt:UInt;				// Target position post bit-reversal
	
	public function new (): Void
	{
		re = 0.0;
		im = 0.0;
	}
}

