package hxop.engine;

import haxe.macro.Expr;
import haxe.macro.Type;

enum UnopExt
{
	Unop(op:haxe.macro.Expr.Unop);
	OpNew;
}

enum BinopExt
{
	Binop(op:haxe.macro.Expr.Binop);
	OpArray;
}

typedef BaseFunc = {
	operator: String,
	lhs: Type,
	field: Expr,
	noAssign: Bool
};

typedef UnopFunc = {
	> BaseFunc,
	prefix: Bool,
	postfix: Bool,
}

typedef BinopFunc = {
	> BaseFunc,
	rhs: Type,
	commutative: Bool
}

typedef NewFunc = {
	> BaseFunc,
	args: Array<{t:Type, opt:Bool, name:String}>
}

typedef IdentDef = Array<{ name : String, type : Null<ComplexType>, expr : Null<Expr> }>; 