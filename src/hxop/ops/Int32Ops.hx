package hxop.ops;
import haxe.Int32;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

class Int32Ops
{


	@op("+") inline static public var add = Int32.add;

	@op("+", true) inline static public function addInt(a:Int32, b:Int):Int32
	{
		return Int32.add(a, Int32.ofInt(b));
	}
	
	@op("-") inline static public var sub = Int32.sub;
	
	@op("-") inline static public function subInt(a:Int32, b:Int):Int32
	{
		return Int32.sub(a, Int32.ofInt(b));
	}
	
	@op("*") inline static public var mult = Int32.mul;
	
	@op("*", true) inline static public function multInt(a:Int32, b:Int):Int32
	{
		return Int32.mul(a, Int32.ofInt(b));
	}
	
	@op("/") inline static public var div = Int32.div;
	
	@op("/") inline static public function divInt(a:Int32, b:Int):Int32
	{
		return Int32.div(a, Int32.ofInt(b));
	}
	
	@op("%") inline static public var mod = Int32.mod;
	
	@op("%") inline static public function modInt(a:Int32, b:Int):Int32
	{
		return Int32.mod(a, Int32.ofInt(b));
	}
	
	@op("+=") inline static public var iadd = Int32.add;
	
	@op("+=") inline static public function iaddInt(a:Int32, b:Int):Int32
	{
		return Int32.add(a, Int32.ofInt(b));
	}
	
	@op("-=") inline static public var isub = Int32.sub;
	
	@op("-=") inline static public function isubInt(a:Int32, b:Int):Int32
	{
		return Int32.sub(a, Int32.ofInt(b));
	}
	
	@op("*=") inline static public var imult = Int32.mul;
	
	@op("*=") inline static public function imultInt(a:Int32, b:Int):Int32
	{
		return Int32.mul(a, Int32.ofInt(b));
	}
	
	@op("/=") inline static public var idiv = Int32.div;
	
	@op("/=") inline static public function idivInt(a:Int32, b:Int):Int32
	{
		return Int32.div(a, Int32.ofInt(b));
	}
	
	@op("%=") inline static public var imod = Int32.mod;
	
	@op("%=") inline static public function imodInt(a:Int32, b:Int):Int32
	{
		return Int32.mod(a, Int32.ofInt(b));
	}
	
	@op("<<", true) inline static public var shl = Int32.shl;
	@op("<<=", true) inline static public var ishl = Int32.shl;

	@op(">>", true) inline static public var shr = Int32.shr;
	@op(">>=", true) inline static public var ishr = Int32.shr;
	@op(">>>", true) inline static public var ushr = Int32.ushr;
	@op(">>>=", true) inline static public var iushr = Int32.ushr;
	
	@op("&") inline static public var and = Int32.and;
	@op("&=") inline static public var iand = Int32.and;
	@op("|") inline static public var or = Int32.or;
	@op("|=") inline static public var ior = Int32.or;
	@op("^") inline static public var xor = Int32.xor;
	@op("^=") inline static public var ixor = Int32.xor;
	
	@op("-") inline static public var neg = Int32.neg;
	
	@op("++") inline static public function inc(a:Int32)
	{
		return Int32.add(a, Int32.ofInt(1));
	}

	@op("--") inline static public function dec(a:Int32):Int32
	{
		return Int32.sub(a, Int32.ofInt(1));
	}

	@op(">") inline static public function gt(a:Int32, b:Int32):Bool
	{
		return Int32.compare(a, b) > 0;
	}
	
	@op(">=") inline static public function gte(a:Int32, b:Int32):Bool
	{
		return Int32.compare(a, b) >= 0;
	}
	
	@op("<") inline static public function lt(a:Int32, b:Int32):Bool
	{
		return Int32.compare(a, b) < 0;
	}
	
	@op("<=") inline static public function lte(a:Int32, b:Int32):Bool
	{
		return Int32.compare(a, b) <= 0;
	}
	
	@op("==") inline static public function eq(a:Int32, b:Int32):Bool
	{
		return Int32.compare(a, b) == 0;
	}
	
	@op("==", true) inline public static function eqInt(a:Int32, b:Int):Bool
	{
		return Int32.compare(a, Int32.ofInt(b)) == 0;
	}
	
	@op("!=") inline static public function neq(a:Int32, b:Int32):Bool
	{
		return Int32.compare(a, b) != 0;
	}
	
	@op("!=", true) inline public static function neqInt(a:Int32, b:Int):Bool
	{
		return Int32.compare(a, Int32.ofInt(b)) != 0;
	}
	
	inline static public function abs(a:Int32):Int32
	{
		if (Int32.isNeg(a))
			return Int32.neg(a);
		return a;
	}
}