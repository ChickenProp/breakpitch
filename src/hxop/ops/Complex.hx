package hxop.ops;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

class Complex 
{

	public var re:Float;
	public var im:Float;
	
	public function new(re:Float = 0, im:Float = 0) 
	{
		this.re = re;
		this.im = im;
	}
	
	public function toString()
	{
		return "[Complex: " + re + ", " + im + "]";
	}
	
	inline public function clone()
	{
		return new Complex(re, im);
	}
	
	public inline function equals(c2:Complex)
		return floatEquals(c2.re, re) && floatEquals(c2.im, im)
		
	static public function floatEquals(lhs:Float, rhs:Float) return Math.abs(lhs - rhs) < 0.00000001
}