package hxop.ops;

typedef ReflectionFunc = ?Dynamic -> Dynamic;

class ReflectionOps
{
	static inline function access(base:Dynamic, access:String, ?value:Dynamic)
	{
		if (value == null)
			return Reflect.field(base, access);
		else
		{
			Reflect.setField(base, access, value);
			return value;
		}
	}
	
	@op("[]") static public inline function read(base:Dynamic, access:String):Dynamic
	{
		return Reflect.field(base, access);
	}
	
	@op("[]=") @noAssign static public function write(base:Dynamic, access:String):ReflectionFunc
	{
		return callback(ReflectionOps.access, base, access);
	}
		
	@op("=") static public inline function assign(lhs:ReflectionFunc, rhs:Dynamic):Dynamic
	{
		return lhs( rhs );
	}
	
	@op("+=") @noAssign static public inline function assignAdd(lhs:ReflectionFunc, rhs:Dynamic):Dynamic
	{
		return lhs( lhs() + rhs );
	}
	
	@op("-=") @noAssign static public inline function assignSub(lhs:ReflectionFunc, rhs:Dynamic):Dynamic
	{
		return lhs( lhs() - rhs );
	}
	
	@op("*=") @noAssign static public inline function assignMul(lhs:ReflectionFunc, rhs:Dynamic):Dynamic
	{
		return lhs( lhs() * rhs );
	}
	
	@op("/=") @noAssign static public inline function assignDiv(lhs:ReflectionFunc, rhs:Dynamic):Dynamic
	{
		return lhs( lhs() / rhs );
	}
	
	@op("++x") @noAssign static public inline function incPre(lhs:ReflectionFunc):Dynamic
	{
		return lhs(lhs() + 1);
	}
	
	@op("x++") @noAssign static public inline function incPost(lhs:ReflectionFunc):Dynamic
	{
		var old = lhs();
		lhs(lhs() + 1);
		return old;
	}	
	
	@op("--x") @noAssign static public inline function decPre(lhs:ReflectionFunc):Dynamic
	{
		return lhs(lhs() - 1);
	}
	
	@op("x--") @noAssign static public inline function decPost(lhs:ReflectionFunc):Dynamic
	{
		var old = lhs();
		lhs(lhs() - 1);
		return old;
	}		
}