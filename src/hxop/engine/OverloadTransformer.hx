package hxop.engine;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import tink.macro.build.MemberTransformer;

import hxop.engine.Types;

using tink.core.types.Outcome;
using tink.macro.tools.ExprTools;
using tink.macro.tools.MetadataTools;
using tink.macro.tools.TypeTools;

#end

class OverloadTransformer
{	
	static var finishedClasses = new Hash();
	
	@:macro static public function build(?opsClass:String):Array<Field>
	{
		var cl = Context.getLocalClass().get();
		
		var signature = Context.signature(cl);
		if (finishedClasses.exists(signature))
			return finishedClasses.get(signature);

		if (cl.meta.has("noOverload") || cl.isExtern || cl.isInterface)
			return Context.getBuildFields();

		if (opsClass != null)
			findOperators(Context.getType(opsClass));
		
		try
		{
			new MemberTransformer().build([getOperators]);
		} catch (e:Dynamic)
		{
			if (opsClass == null)
				Context.error("Must implement hxop.Overload or call hxop.engine.OverloadTransformer with an argument.", Context.currentPos());
		}

		
		var fields = new MemberTransformer().build([overload]);
		finishedClasses.set(signature, fields);
		return fields;
	}
	
	#if macro
	
	static var operatorManager = new OperatorManager();

	static function overload(ctx:ClassBuildContext)
	{
		var env = [];
		
		if (ctx.cls.superClass != null)
			getMembers(ctx.cls.superClass.t.get(), env);
			
		for (field in ctx.members)
		{
			switch(field.kind)
			{
				case FVar(t, e):
					env.push( { name:field.name, type:t, expr:null } );
				case FProp(g, s, t, e):
					env.push( { name:field.name, type:t, expr:null } );
				case FFun(func):
					if (func.ret == null)
						continue;
					var tfArgs = [];
					for (arg in func.args)
						tfArgs.push(arg.type);
					env.push( { name:field.name, type:TFunction(tfArgs, func.ret), expr:null } );				
			}
		}

		for (member in ctx.members)
		{
			if (member.meta.exists("noOverload")) continue;
			switch(member.kind)
			{
				case FFun(func):
					var innerCtx = env.copy();
					for (arg in func.args)
						innerCtx.push( { name:arg.name, type:arg.type, expr: null } );					
					func.expr = transform(func.expr, innerCtx);
				case FVar(t, e):
					var innerCtx = env.copy();
					if (e != null)
						e.expr = transform(e, innerCtx).expr;
				default:
			}
		}
	}
	
	static function getMembers(cls:ClassType, ctx:IdentDef)
	{
		for (field in cls.fields.get())
			ctx.push( { name:field.name, type:monofy(field.type.reduce()).toComplex(), expr: null } );
		if (cls.superClass != null)
			getMembers(cls.superClass.t.get(), ctx);
	}
	
	static function getOperators(ctx:ClassBuildContext)
	{
		for (i in ctx.cls.interfaces)
			if (i.t.get().name == "Overload")
				findOperators(i.params[0].reduce());
	}
	
	static function transform(expr:Expr, initCtx:IdentDef, lValue:Bool = false)
	{
		return expr.map(function(e, ctx)
		{
			var e = switch(e.expr)
			{
				case ENew(tp, params):
					var tParams = [];
					for (param in params)
						tParams.push(transform(param, ctx));
					switch(operatorManager.findNew(tp, tParams, ctx, e.pos))
					{
						case None:
							e;					
						case Some(opFunc):
							opFunc;
					}
				case EArray(lhs, rhs):
					lhs = transform(lhs, ctx, lValue);
					rhs = transform(rhs, ctx);
					switch(operatorManager.findBinop(OpArray, lhs, rhs, lValue, ctx, e.pos))
					{
						case None:
							e;
						case Some(opFunc):
							lValue && !opFunc.noAssign ? lhs.assign(opFunc.func) : opFunc.func;
					}					
				case EBinop(op, lhs, rhs):
					var info = switch(op)
					{
						case OpAssignOp(op2):
							{ op:op2, assign: true };
						default:
							{ op:op, assign: false };
					}
					lhs = transform(lhs, ctx, info.assign || info.op == OpAssign);
					rhs = transform(rhs, ctx);
					switch(operatorManager.findBinop(Binop(info.op), lhs, rhs, info.assign, ctx, e.pos))
					{
						case None:
							e;
						case Some(opFunc):
							info.assign && !opFunc.noAssign ? lhs.assign(opFunc.func) : opFunc.func;
					}
				case EUnop(op, postFix, lhs):
					var assign = (op == OpIncrement || op == OpDecrement);
					lhs = transform(lhs, ctx, assign);
					switch(operatorManager.findUnop(Unop(op), postFix, lhs, ctx, e.pos))
					{
						case None:
							e;
						case Some(opFunc):
							if (!assign || opFunc.noAssign)
								opFunc.func;
							else if (!postFix)
								lhs.assign(opFunc.func, lhs.pos);
							else
							{
								[ "tmp".define(lhs, lhs.pos),
								lhs.assign(opFunc.func, lhs.pos),
								"tmp".resolve(lhs.pos)
								].toBlock();
							}
					}
				default:
					e;
			};
			lValue = false;
			return e;
		}, initCtx);
	}

	static function findOperators(type:Type)
	{
		var fields = switch(type.getStatics())
		{
			case Success(fields):
				fields;
			case Failure(e):
				Context.error(e, Context.currentPos());
		}
		
		for (field in fields)
		{
			if (!field.meta.has("op"))
				continue;

			for (meta in field.meta.get().getValues("op"))
			{
				var operator = switch(meta[0].getString())
				{
					case Success(operator):
						operator;
					case Failure(_):
						Context.warning("First argument to @op must be String.", meta[0].pos);
						continue;
				}

				var commutative = meta.length == 1 ? false : switch(meta[1].getIdent())
				{
					case Success(b):
						switch(b)
						{
							case "true": true;
							case "false": false;
							default:
								Context.warning("Second argument to @op must be Bool.", meta[0].pos);
								true;
						}
					case Failure(f):
						Context.warning("Second argument to @op must be Bool.", meta[0].pos);
						true;
				}
				
				buildOperatorFunc(field, type, operator, commutative);
			}
		}
	}

	static function buildOperatorFunc(field:ClassField, type:Type, operator:String, commutative:Bool)
	{
		var args = switch(field.type.reduce())
		{
			case TFun(args, ret):
				if (operator == "new")
				{
					var tArgs = [];
					for (arg in args)
						tArgs.push( { name:arg.name, opt:arg.opt, t:monofy(arg.t) } );
					operatorManager.addNew({
						operator: "new",
						lhs: monofy(ret.reduce()),
						field: type.getID().resolve().field(field.name),
						args: tArgs,
						noAssign: false
					});	
					return;
				}
				args;
			default:
				Context.warning("Only functions can be used as operators.", field.pos);
				return;						
		};
		
		if (args.length > 2 || args.length == 0)
		{
			Context.warning("Only unary and binary operators are supported.", field.pos);
			return;
		}
			
		var noAssign = field.meta.has("noAssign");
		
		if (args.length == 1)
		{
			if (noAssign && (operator == "--" || operator == "++"))
				Context.error("Combination of @noAssign and " +operator + " is invalid, use x" +operator + " or " +operator + "x to define a postfix or prefix operation.", field.pos);
				
			var postfix = true;
			var prefix = true;
			if (operator.charAt(0) == "x")
			{
				prefix = false;
				operator = operator.substr(1);
			}
			else if (operator.charAt(operator.length - 1) == "x")
			{
				postfix = false;
				operator = operator.substr(0, -1);
			}

			operatorManager.addUnop( {
				prefix: prefix,
				postfix: postfix,
				operator: operator,
				lhs: args[0].t,
				field: type.getID().resolve().field(field.name),
				noAssign: noAssign
			});
		}
		else
		{
			if (commutative && args[0].t.isSubTypeOf(args[1].t).isSuccess())
			{
				Context.warning("Found commutative definition, but types are equal.", field.pos);
				commutative = false;
			}

			operatorManager.addBinop({
				operator: operator,
				lhs: monofy(args[0].t),
				field: type.getID().resolve().field(field.name),
				rhs: monofy(args[1].t),
				commutative: commutative,
				noAssign: noAssign
			});
		}
	}
	
	static function monofy(t:Type)
	{
		return switch(t)
		{
			case TInst(cl, params):
				if (cl.get().kind == KTypeParameter)
					TPath({ name: "Dynamic", pack: [], params: [], sub: null }).toType().sure();
				else
				{
					var newParams = [];
					for (param in params)
						newParams.push(monofy(param));
					TInst(cl, newParams);
				}
			case TFun(args, ret):
				var newArgs = [];
				for (arg in args)
					newArgs.push( { name:arg.name, opt:arg.opt, t:monofy(arg.t) } );
				TFun(newArgs, monofy(ret));
			default:
				t;
		}
	}

	#end
}